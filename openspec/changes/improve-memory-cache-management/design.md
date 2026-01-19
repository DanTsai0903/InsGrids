# Design: Memory and Cache Management Improvements

## Context
The app uses a "Low-Res Edit, High-Res Export" architecture where:
- User edits with 1200px downsampled proxies for 60fps UI
- Originals (up to 48MP) are cached to `/Caches/original_images/`
- Auto-save proxies are cached to `/Caches/autosave_images/`
- Export loads originals per-tile with autoreleasepool to prevent OOM

Current issues:
- PhotoEditorEngine instantiated per-tile instead of singleton reuse
- Cache cleanup is incomplete (only autosave folder, not originals)
- No lifecycle hooks to clean up when app backgrounds
- No cache size limits or monitoring

Constraints:
- Must maintain 60fps UI performance during editing
- Must prevent OOM crashes on 12MP tile export
- First-party frameworks only (no external dependencies)
- Privacy: all data stored locally in Caches directory

## Goals / Non-Goals

**Goals:**
- Reduce memory footprint during tile rendering by 20-30% (singleton reuse)
- Prevent cache bloat by ensuring orphaned files are cleaned up within 5 seconds
- Add app lifecycle hooks for graceful cache cleanup on background/termination
- Monitor cache size and enforce soft limit to prevent runaway growth
- Maintain current export quality and performance

**Non-Goals:**
- Changing the proxy/original workflow (architecture remains the same)
- Adding cloud storage or external cache management
- Implementing LRU cache eviction (simple oldest-first is sufficient)
- Supporting cache migration across app versions

## Decisions

### Decision 1: Use Shared Singleton for PhotoEditorEngine
**What:** Change GridViewModel.swift:773 from `let engine = PhotoEditorEngine()` to `PhotoEditorEngine.shared`

**Why:**
- PhotoEditorEngine holds a Metal-backed CIContext which is expensive to initialize
- Creating a new instance per tile wastes GPU resources
- Shared singleton with cached intermediates (`.cacheIntermediates: true`) improves performance
- No thread-safety concerns: CIContext is thread-safe per Apple docs

**Alternatives considered:**
- Creating a pool of reusable engines → Adds complexity, single shared instance is sufficient
- Lazy initialization per render → Still wastes resources compared to singleton

**Trade-offs:**
- ✅ Reduced memory/GPU usage per tile
- ✅ Faster render times due to cached intermediates
- ⚠️ Slight coupling to singleton pattern (acceptable for utility class)

---

### Decision 2: Unified Cache Cleanup with Active UUID Set
**What:** Create `cleanupOrphanedFiles(activeIds: Set<UUID>)` helper that purges both cache folders

**Why:**
- Current cleanup only handles autosave_images, leaving originals to accumulate
- Both folders use UUID-based filenames, so unified logic works for both
- Calling cleanup every 5 seconds (auto-save interval) ensures orphans are removed promptly
- Background thread execution prevents UI blocking

**Implementation:**
```swift
private func cleanupOrphanedFiles(activeIds: Set<UUID>) {
    Task.detached(priority: .background) {
        for folder in [self.autosaveFolder, self.originalsFolder] {
            if let files = try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil) {
                for file in files {
                    let filename = file.deletingPathExtension().lastPathComponent
                    if !activeIds.contains(UUID(uuidString: filename) ?? UUID()) {
                        try? FileManager.default.removeItem(at: file)
                    }
                }
            }
        }
    }
}
```

**Alternatives considered:**
- Separate cleanup methods for each folder → Duplicates code, harder to maintain
- Cleanup only on app termination → Orphans accumulate between sessions, wastes storage

**Trade-offs:**
- ✅ Prevents cache bloat proactively
- ✅ Unified logic is easier to test and maintain
- ⚠️ Runs every 5 seconds, but on background thread so no UI impact

---

### Decision 3: ScenePhase-Based Lifecycle Cleanup
**What:** Add `@Environment(\.scenePhase)` observer in GridEditingView or root App to trigger cleanup on background/inactive

**Why:**
- SwiftUI's ScenePhase provides reliable lifecycle events
- Cleaning up when app backgrounds prevents wasted storage if app is terminated by system
- Best-effort cleanup on termination (force-quit can't be caught, but background transition can)

**Implementation:**
```swift
.onChange(of: scenePhase) { oldPhase, newPhase in
    if newPhase == .background || newPhase == .inactive {
        viewModel.performLifecycleCleanup()
    }
}
```

**Alternatives considered:**
- NotificationCenter observers (UIApplication lifecycle) → Less SwiftUI-idiomatic, deprecated patterns
- No lifecycle hooks → Cache files persist indefinitely if app crashes

**Trade-offs:**
- ✅ Ensures cleanup even if app doesn't gracefully exit
- ✅ Native SwiftUI pattern
- ⚠️ Cleanup might delay app suspension slightly (acceptable, runs on background queue)

---

### Decision 4: Soft Cache Size Limit of 500MB
**What:** Monitor total cache size and trigger aggressive cleanup when exceeding 500MB threshold

**Why:**
- 500MB is generous for typical usage (33 48MP images at ~15MB each)
- Prevents runaway growth from heavy editing sessions
- Soft limit (not hard) means cleanup is best-effort, not blocking
- Oldest-first deletion is simple and effective (no need for LRU)

**Implementation:**
```swift
func totalCacheSize() -> Int {
    var total = 0
    for folder in [autosaveFolder, originalsFolder] {
        if let files = try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: [.fileSizeKey, .creationDateKey]) {
            for file in files {
                if let attrs = try? FileManager.default.attributesOfItem(atPath: file.path),
                   let size = attrs[.size] as? Int {
                    total += size
                }
            }
        }
    }
    return total
}

func enforceStorageLimit() {
    let limit = 500 * 1024 * 1024 // 500MB
    if totalCacheSize() > limit {
        deleteOldestFiles(until: limit)
    }
}
```

**Alternatives considered:**
- Hard limit with blocking cleanup → Could freeze UI, bad UX
- No limit → Risk of filling device storage, poor user experience
- LRU eviction → Over-engineered for this use case

**Trade-offs:**
- ✅ Prevents cache bloat while allowing generous working set
- ✅ Simple oldest-first policy is easy to understand and debug
- ⚠️ Aggressive cleanup might delete files from previous session (acceptable, they're cached copies)

---

### Decision 5: Cache Integrity Check on Launch
**What:** Validate cache files on app launch and remove corrupted or orphaned files

**Why:**
- Protects against partial writes from app crashes
- Removes orphaned autosave files if UserDefaults metadata is missing
- Runs once per launch, so negligible performance impact
- Improves reliability by ensuring cache is in clean state

**Implementation:**
```swift
func validateCacheIntegrity() {
    Task.detached(priority: .background) {
        // Check autosave metadata
        let activeIds = loadActiveIdsFromUserDefaults()

        // Remove orphaned autosave files
        if let files = try? FileManager.default.contentsOfDirectory(at: autosaveFolder, includingPropertiesForKeys: nil) {
            for file in files {
                let uuid = UUID(uuidString: file.deletingPathExtension().lastPathComponent)
                if uuid == nil || !activeIds.contains(uuid!) {
                    try? FileManager.default.removeItem(at: file)
                }
            }
        }

        // Remove corrupted image files
        for folder in [autosaveFolder, originalsFolder] {
            if let files = try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil) {
                for file in files where file.pathExtension == "jpg" {
                    if UIImage(contentsOfFile: file.path) == nil {
                        try? FileManager.default.removeItem(at: file)
                    }
                }
            }
        }
    }
}
```

**Alternatives considered:**
- Skip integrity check → Risk of crashes from loading corrupted files
- Check on every access → Too expensive, launch-time is sufficient

**Trade-offs:**
- ✅ Ensures clean state, prevents crashes from corrupt files
- ✅ Runs once on background thread, no impact on launch time
- ⚠️ Adds ~100ms to app launch for large caches (acceptable)

## Risks / Trade-offs

**Risk: Aggressive Cleanup Deletes Active Files**
- Mitigation: Always pass activeIds set to cleanup, verified by canvasImages.map { $0.id }
- Mitigation: Cleanup runs on background thread, so UI state is consistent

**Risk: ScenePhase Cleanup Delays App Suspension**
- Mitigation: Run cleanup on background priority Task.detached, iOS will allow brief background execution
- Mitigation: If cleanup takes >5 seconds, iOS will suspend anyway (acceptable, best-effort)

**Risk: Cache Size Check is Expensive**
- Mitigation: Only run on app launch and after export, not on every edit
- Mitigation: Use FileManager attributes API, not loading actual file data

**Risk: Singleton PhotoEditorEngine Causes Concurrency Issues**
- Mitigation: CIContext is thread-safe per Apple documentation
- Mitigation: Each tile render is sequential (autoreleasepool loop), no parallel access

## Migration Plan

1. **Phase 1: Fix Singleton Usage** (Low Risk)
   - Change GridViewModel.swift:773 to use shared instance
   - Test tile export with 3×3 grid
   - Rollback: Revert one-line change

2. **Phase 2: Unified Cache Cleanup** (Medium Risk)
   - Refactor cleanup logic to handle both folders
   - Test auto-save and manual clear scenarios
   - Rollback: Keep old cleanup logic as fallback

3. **Phase 3: Lifecycle Hooks** (Medium Risk)
   - Add ScenePhase observer
   - Test background/foreground transitions
   - Rollback: Remove observer, gracefully degrade to periodic cleanup

4. **Phase 4: Cache Monitoring** (Low Risk)
   - Add size tracking and soft limit
   - Monitor logs for cleanup frequency
   - Rollback: Disable limit check, keep monitoring

5. **Phase 5: Integrity Check** (Low Risk)
   - Add launch-time validation
   - Monitor logs for corruption frequency
   - Rollback: Disable check

## Open Questions

- Should we add user-facing cache management UI (e.g., "Clear Cache" button in settings)?
  - **Decision:** Not in this change. Keep it automatic and transparent for now.

- Should we expose cache size metrics for debugging (e.g., in Xcode console)?
  - **Decision:** Yes, add non-production logging to measure effectiveness.

- Should we use .contentDate instead of .creationDate for oldest-first deletion?
  - **Decision:** Use .creationDate since it's more stable and available on all file types.

- Should we make the 500MB limit configurable?
  - **Decision:** No. Hardcode for simplicity. Can adjust in future if needed.
