import SwiftUI

// MARK: - Sticker Manager
// Manages sticker element creation and emoji/icon library access

/// Manager for creating and handling sticker elements
class StickerManager: ObservableObject {
    static let shared = StickerManager()
    
    /// Available sticker categories
    var categories: [StickerCategory] {
        StickerCategory.allCategories
    }
    
    /// Create emoji sticker element at specified position
    func createEmojiSticker(_ emoji: String, at position: CGPoint) -> StickerElement {
        StickerElement.emoji(emoji, at: position)
    }
    
    /// Create SF Symbol sticker element at specified position
    func createSymbolSticker(_ symbolName: String, color: Color = .primary, at position: CGPoint) -> StickerElement {
        let safeName = IconLibrary.safeSymbol(symbolName)
        return StickerElement.sfSymbol(safeName, color: color, at: position)
    }
    
    /// Search for symbols matching query
    func searchSymbols(_ query: String) -> [String] {
        IconLibrary.search(query)
    }
}
