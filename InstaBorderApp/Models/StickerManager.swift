import SwiftUI

// MARK: - Sticker Manager
// Manages sticker element creation and SF Symbol/custom sticker library access

/// Manager for creating and handling sticker elements
class StickerManager: ObservableObject {
    static let shared = StickerManager()
    
    /// Available SF Symbol sticker categories
    var categories: [StickerCategory] {
        StickerCategory.allCategories
    }
    
    /// Available custom sticker categories
    var customCategories: [CustomStickerCategory] {
        CustomStickerCategory.allCategories
    }
    
    /// Create SF Symbol sticker element at specified position
    func createSymbolSticker(_ symbolName: String, color: Color = .primary, at position: CGPoint) -> StickerElement {
        let safeName = IconLibrary.safeSymbol(symbolName)
        return StickerElement.sfSymbol(safeName, color: color, at: position)
    }
    
    /// Create custom sticker element at specified position
    func createCustomSticker(_ assetName: String, at position: CGPoint) -> StickerElement {
        StickerElement.customSticker(assetName, at: position)
    }
    
    /// Search for symbols matching query
    func searchSymbols(_ query: String) -> [String] {
        IconLibrary.search(query)
    }
    
    /// Search for custom stickers matching query
    func searchCustomStickers(_ query: String) -> [CustomSticker] {
        CustomStickerCategory.searchStickers(query)
    }
}
