import SwiftUI

// MARK: - Sticker Category
// Note: StickerElement is defined in CanvasElement.swift

/// Categories for organizing SF Symbol stickers
struct StickerCategory: Identifiable {
    let id = UUID()
    let name: String
    let localizedKey: String
    let symbols: [String]
    
    /// All available sticker categories with SF Symbols
    static let allCategories: [StickerCategory] = [
        StickerCategory(
            name: "Arrows",
            localizedKey: "Arrows",
            symbols: [
                "arrow.up", "arrow.down", "arrow.left", "arrow.right",
                "arrow.up.circle.fill", "arrow.down.circle.fill",
                "arrow.left.circle.fill", "arrow.right.circle.fill",
                "arrow.turn.up.right", "arrow.turn.down.left",
                "arrow.uturn.backward", "arrow.uturn.forward",
                "arrow.clockwise", "arrow.counterclockwise",
                "chevron.up", "chevron.down"
            ]
        ),
        StickerCategory(
            name: "Shapes",
            localizedKey: "Shapes",
            symbols: [
                "circle.fill", "square.fill", "triangle.fill",
                "heart.fill", "star.fill", "diamond.fill",
                "hexagon.fill", "octagon.fill", "shield.fill",
                "flag.fill", "bookmark.fill", "cloud.fill",
                "moon.fill", "sun.max.fill", "sparkle"
            ]
        ),
        StickerCategory(
            name: "Communication",
            localizedKey: "Communication",
            symbols: [
                "message.fill", "phone.fill", "envelope.fill",
                "paperplane.fill", "bubble.left.fill", "bubble.right.fill",
                "ellipsis.bubble.fill", "quote.bubble.fill",
                "text.bubble.fill", "exclamationmark.bubble.fill",
                "questionmark.bubble.fill", "mic.fill",
                "speaker.wave.2.fill", "bell.fill", "video.fill"
            ]
        ),
        StickerCategory(
            name: "Weather",
            localizedKey: "Weather",
            symbols: [
                "sun.max.fill", "cloud.fill", "cloud.rain.fill",
                "cloud.snow.fill", "cloud.bolt.fill", "moon.stars.fill",
                "sparkles", "wind", "tornado",
                "hurricane", "snowflake", "thermometer.sun.fill",
                "thermometer.snowflake", "drop.fill", "humidity.fill"
            ]
        ),
        StickerCategory(
            name: "Nature",
            localizedKey: "Nature",
            symbols: [
                "leaf.fill", "flame.fill", "drop.fill",
                "snowflake", "sparkles", "tree.fill",
                "mountain.2.fill", "sunrise.fill", "sunset.fill",
                "moon.fill", "star.fill", "cloud.sun.fill",
                "cloud.moon.fill", "rainbow", "allergens"
            ]
        ),
        StickerCategory(
            name: "Objects",
            localizedKey: "Objects",
            symbols: [
                "lightbulb.fill", "camera.fill", "music.note",
                "gift.fill", "book.fill", "bookmark.fill",
                "graduationcap.fill", "briefcase.fill", "hammer.fill",
                "wrench.fill", "paintbrush.fill", "cup.and.saucer.fill",
                "cart.fill", "bag.fill", "key.fill"
            ]
        )
    ]
    
    /// Search symbols across all categories
    static func searchSymbols(_ query: String) -> [String] {
        guard !query.isEmpty else { return [] }
        let lowercasedQuery = query.lowercased()
        return allCategories.flatMap { $0.symbols }
            .filter { $0.lowercased().contains(lowercasedQuery) }
    }
}
