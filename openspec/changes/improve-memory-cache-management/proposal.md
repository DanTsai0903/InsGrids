# Change: Improve Memory and Cache Management

## Why
Analysis of the current codebase reveals several memory and cache management issues that could lead to memory accumulation, resource leaks, and potential crashes:

1. **PhotoEditorEngine Misuse**: Tile rendering creates new PhotoEditorEngine instances instead of reusing the shared singleton, wasting resources
2. **Incomplete Cache Cleanup**: Auto-save cleanup only purges autosave_images folder but leaves orphaned original images accumulating in Caches
3. **Missing Lifecycle Hooks**: No cleanup when app backgrounds or terminates, allowing stale cache files to persist indefinitely
4. **Cache Synchronization Gap**: Auto-save cleanup runs every 5 seconds but only cleans one folder, not both (autosave_images vs original_images)
5. **No Cache Size Monitoring**: No tracking or limits on total cache size, which could grow unbounded with heavy usage

## What Changes
- Fix PhotoEditorEngine instantiation to use shared singleton (GridViewModel.swift:773)
- Extend auto-save cleanup to purge both autosave_images AND original_images folders together
- Add app lifecycle observers (ScenePhase) to clean up caches when app backgrounds/terminates
- Add cache size monitoring and enforce soft limit (e.g., 500MB threshold triggers aggressive cleanup)
- Add cache integrity check on app launch to remove corrupted or orphaned files
- Document memory management guarantees in code comments

## Impact
- Affected specs: `freeform-grid` (memory management requirement)
- Affected code:
  - InstaBorderApp/ViewModels/GridViewModel.swift (lines 773, 324-330, 398-413)
  - InstaBorderApp/Utilities/PhotoEditorEngine.swift (usage pattern)
  - InstaBorderApp/InstaBorderApp.swift (app lifecycle hooks)
- **Performance**: Reduced memory footprint during tile export
- **Reliability**: Prevents cache bloat and out-of-memory crashes on long-running sessions
- **Storage**: Automatic cleanup prevents wasted disk space from orphaned files
