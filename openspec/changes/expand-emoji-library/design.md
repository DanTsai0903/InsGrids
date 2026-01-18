# Design: Expand Emoji Library with Search

## Overview

This change expands the emoji picker from 160 to ~1,800 emojis and adds search functionality. The implementation involves:
1. **Data expansion** - Replace hardcoded emoji arrays with comprehensive lists
2. **Keyword mapping** - Create searchable metadata for each emoji
3. **Search UI** - Add search bar above category tabs
4. **Search logic** - Implement real-time filtering across all categories

## Current State

### `EmojiPickerView.swift` Current Implementation

```swift
private let emojis: [(String, [String])] = [
    ("😀", [20 smiley emojis]),
    ("❤️", [20 heart emojis]),
    ("🎉", [20 celebration emojis]),
    ("⭐", [20 star/symbol emojis]),
    ("👍", [20 hand gesture emojis]),
    ("🍕", [20 food emojis]),
    ("🐱", [20 animal emojis]),
    ("🌸", [20 nature emojis])
]
```

**Total**: 8 categories × 20 emojis = 160 emojis  
**No search functionality**

### Integration Context

`EmojiPickerView` is used by `StickerPickerView` as the "Emoji" tab.

## Proposed Solution

### 1. Data Structure Changes

#### Emoji Categories (No Change to Structure)
Keep the existing `[(String, [String])]` format for backward compatibility:

```swift
private let emojis: [(String, [String])] = [
    ("😀", [~500 Smileys & People]),
    ("🐱", [~150 Animals & Nature]),
    ("🍕", [~130 Food & Drink]),
    ("⚽", [~90 Activity]),
    ("🚗", [~120 Travel & Places]),
    ("💡", [~250 Objects]),
    ("❤️", [~280 Symbols]),
    ("🏳️", [~270 Flags])
]
```

#### New: Emoji Keyword Mapping

Add dictionary to support search:

```swift
private let emojiKeywords: [String: [String]] = [
    "😀": ["grinning", "smile", "happy", "face"],
    "❤️": ["heart", "love", "red", "romance"],
    "🍕": ["pizza", "food", "slice", "italian"],
    "🐱": ["cat", "kitty", "pet", "animal", "feline"],
    // ... ~1,800 entries total
]

private let categoryKeywords: [Int: [String]] = [
    0: ["smiley", "face", "people", "person", "emotion"],
    1: ["animal", "nature", "plant", "weather"],
    2: ["food", "drink", "beverage", "meal"],
    3: ["activity", "sport", "game", "hobby"],
    4: ["travel", "place", "transport", "vehicle", "building"],
    5: ["object", "thing", "tool", "technology"],
    6: ["symbol", "shape", "sign", "arrow", "heart"],
    7: ["flag", "country", "nation"]
]
```

### 2. UI Changes

#### Search Bar Layout

```
┌────────────────────────────────────┐
│ 🔍  Search Emoji            ×      │ ← NEW: Search bar
├────────────────────────────────────┤
│ 😀  🐱  🍕  ⚽  🚗  💡  ❤️  🏳  │ ← Category tabs
├────────────────────────────────────┤
│                                    │
│    😀  😃  😄  😁  😅             │
│    😂  🤣  😊  😇  🥰             │ ← Emoji grid
│    ...                             │
│                                    │
└────────────────────────────────────┘
```

**Search Active State:**

```
┌────────────────────────────────────┐
│ 🔍  heart                   ×      │ ← Active search
├────────────────────────────────────┤
│ Search Results                     │ ← Results header (optional)
│                                    │
│    ❤️  🧡  💛  💚  💙             │
│    💜  🖤  🤍  🤎  💔             │ ← Filtered results
│    ❣️  💕  💞  💓  💗             │
│    ...                             │
└────────────────────────────────────┘
```

#### SwiftUI Implementation

```swift
struct EmojiPickerView: View {
    // ... existing properties
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 16) {
            // Title
            HStack { /* ... existing title ... */ }
            
            // NEW: Search bar
            searchBar
            
            // Category tabs (hidden when searching)
            if searchText.isEmpty {
                categoryTabs
            }
            
            // Emoji grid
            emojiGrid
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField(
                NSLocalizedString("Search Emoji", comment: "Search placeholder"),
                text: $searchText
            )
            .textFieldStyle(.plain)
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private var emojiGrid: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                ForEach(filteredEmojis, id: \.self) { emoji in
                    // ... emoji button
                }
            }
        }
    }
    
    private var filteredEmojis: [String] {
        guard !searchText.isEmpty else {
            // Show selected category
            return emojis[selectedCategory].1
        }
        
        // Search across all emojis
        return searchEmojis(query: searchText)
    }
}
```

### 3. Search Algorithm

#### Search Function Implementation

```swift
private func searchEmojis(query: String) -> [String] {
    let lowercased = query.lowercased().trimmingCharacters(in: .whitespaces)
    guard !lowercased.isEmpty else { return [] }
    
    var results: [String] = []
    
    // Search by emoji keywords
    for (emoji, keywords) in emojiKeywords {
        if keywords.contains(where: { $0.contains(lowercased) }) {
            results.append(emoji)
        }
    }
    
    // Search by category name (add all category emojis if match)
    for (categoryIndex, keywords) in categoryKeywords {
        if keywords.contains(where: { $0.contains(lowercased) }) {
            results.append(contentsOf: emojis[categoryIndex].1)
        }
    }
    
    // Remove duplicates while preserving order
    return Array(NSOrderedSet(array: results)) as! [String]
}
```

**Performance**: O(n) where n = number of emojis (~1,800)  
**Expected time**: <10ms for typical searches

#### Search Optimizations

1. **Debouncing** (optional): Wait 50ms after last keystroke before searching
2. **Caching**: Store last search results to avoid re-computation on category switch
3. **Early termination**: Stop after finding N results (e.g., 100 max)

### 4. Emoji Keyword Sourcing

#### Keyword Generation Strategy

1. **Emoji Name**: Unicode CLDR short name (e.g., "grinning face" → ["grinning", "face"])
2. **Synonyms**: Common alternatives (e.g., "happy", "smile")
3. **Category**: Category name as keyword
4. **Localization**: Add Chinese translations where applicable

**Example Mapping**:
```swift
"😀": ["grinning", "smile", "happy", "face", "笑臉"], // with Chinese
"🍕": ["pizza", "food", "slice", "italian", "披薩"],
"❤️": ["heart", "love", "red", "romance", "愛心"]
```

#### Keyword Sources
- [Unicode CLDR Emoji Annotations](https://cldr.unicode.org/index/cldr-spec/emoji-annotations)
- [Emojipedia](https://emojipedia.org/) - Community descriptions
- Manual curation for common synonyms

### 5. Localization

#### New Localization Strings

**English (`en.lproj/Localizable.strings`)**:
```
"Search Emoji" = "Search Emoji";
"No results found" = "No results found";
```

**Traditional Chinese (`zh-Hant.lproj/Localizable.strings`)**:
```
"Search Emoji" = "搜尋表情符號";
"No results found" = "找不到結果";
```

## Technical Implementation Details

### File Changes

**Modified**: `InstaBorderApp/Views/Components/EmojiPickerView.swift`
- Add `emojis` array with ~1,800 emojis (~1,500 LOC)
- Add `emojiKeywords` dictionary (~1,800 entries, ~2,000 LOC)
- Add `categoryKeywords` dictionary (8 entries, ~20 LOC)
- Add `searchText` state variable
- Add search bar UI (~30 LOC)
- Add `searchEmojis()` function (~20 LOC)
- Update `filteredEmojis` computed property (~10 LOC)

**Total LOC**: ~3,600 lines (mostly data)

**Modified**: Localization files
- `en.lproj/Localizable.strings` - Add 2 strings
- `zh-Hant.lproj/Localizable.strings` - Add 2 strings

### Performance Considerations

| Aspect | Expected Impact |
|--------|-----------------|
| **Memory** | +20-30 KB for emoji data, +15-20 KB for keywords (~50 KB total) |
| **Initial load** | No impact (data is static) |
| **Search latency** | <10ms per keystroke (linear scan of 1,800 items) |
| **Grid rendering** | No impact (LazyVGrid only renders visible) |

### Edge Cases

1. **Empty search results**: Show "No results found" message
2. **Single character search**: Broad results (e.g., "a" matches many)
3. **Special characters**: Search handles emoji input (e.g., searching "❤️") - match exact emoji
4. **Whitespace**: Trim before searching
5. **Very long queries**: Limit search input to 50 characters

## Testing Strategy

### Unit Testing (Future)

```swift
func testEmojiSearch() {
    // Test keyword matching
    let results = searchEmojis(query: "heart")
    XCTAssertTrue(results.contains("❤️"))
    XCTAssertTrue(results.contains("💛"))
    
    // Test case insensitivity
    XCTAssertEqual(searchEmojis(query: "HEART"), searchEmojis(query: "heart"))
    
    // Test empty query
    XCTAssertEqual(searchEmojis(query: ""), [])
    
    // Test category search
    let foodResults = searchEmojis(query: "food")
    XCTAssertTrue(foodResults.contains("🍕"))
}
```

### Manual Testing

1. **Search accuracy**: Verify "heart" finds all heart emojis
2. **Search performance**: Type rapidly, ensure no lag
3. **Clear button**: Verify X button appears and works
4. **Empty state**: Search for nonsense, verify message  
5. **Category fallback**: Clear search, verify categories reappear
6. **Localization**: Test search in both English and Chinese

## Risks and Mitigations

| Risk | Mitigation |
|------|-----------|
| **Keyword coverage gaps** | Manual review of top 100 emojis, community feedback |
| **Search performance** | Profile with Instruments, optimize to <100ms threshold |
| **Keyword maintenance** | Document keyword update process, consider JSON extraction later |
| **False positives** | Be conservative with keywords, avoid over-matching |
| **Localization drift** | Sync English/Chinese keywords during data preparation |

## Future Enhancements (Out of Scope)

- **Fuzzy search** - Match misspellings (e.g., "hreat" → "heart")
- **Search history** - Show recent searches
- **Suggested searches** - Auto-complete as user types
- **Recently used section** - Track frequently used emojis
- **Favorites** - Star emojis for quick access
- **Dynamic keyword loading** - Load from JSON file instead of hardcoding

## References

- [Unicode CLDR Emoji Annotations](https://cldr.unicode.org/index/cldr-spec/emoji-annotations)
- [Emojipedia](https://emojipedia.org/) - Emoji descriptions and keywords
- [Swift String Performance](https://developer.apple.com/documentation/swift/string) - Optimization guide
