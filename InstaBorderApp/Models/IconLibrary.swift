import SwiftUI

// MARK: - Icon Library
// Provides SF Symbol icons organized by categories for sticker picker

/// Icon library containing SF Symbols organized by category
struct IconLibrary {
    /// All available icon categories
    static var categories: [StickerCategory] {
        StickerCategory.allCategories
    }
    
    /// Get all icons for a specific category
    static func icons(for categoryName: String) -> [String] {
        categories.first { $0.name == categoryName }?.symbols ?? []
    }
    
    /// Search icons across all categories
    static func search(_ query: String) -> [String] {
        StickerCategory.searchSymbols(query)
    }
    
    /// Check if a symbol name is valid
    static func isValidSymbol(_ name: String) -> Bool {
        UIImage(systemName: name) != nil
    }
    
    /// Get a fallback symbol if requested one doesn't exist
    static func safeSymbol(_ name: String) -> String {
        isValidSymbol(name) ? name : "questionmark.circle.fill"
    }
}
