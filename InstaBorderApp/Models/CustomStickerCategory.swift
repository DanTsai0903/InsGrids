import SwiftUI

// MARK: - Custom Sticker Category
// Organizes custom stickers into browsable categories

/// Categories for organizing custom sticker assets
struct CustomStickerCategory: Identifiable {
    let id = UUID()
    let name: String
    let localizedKey: String
    let stickers: [String]  // Array of asset names from Assets.xcassets
    
    /// All available custom sticker categories
    /// Initially empty - expand as custom stickers are added
    static let allCategories: [CustomStickerCategory] = [
        CustomStickerCategory(
            name: "animals",
            localizedKey: "sticker.category.animals",
            stickers: ["003-flamingo", "034-rhinoceros", "025-fox", "012-wild-boar", "038-elephant", "010-rabbit", "002-buffalo", "040-hippopotamus", "033-lion", "011-antelope", "009-fox", "001-crocodile", "018-bison", "035-giraffe", "006-cow", "014-bear", "030-hippopotamus", "021-tiger", "020-goat", "039-giraffe", "031-cheetah", "032-goat", "022-elephant", "023-rabbit", "037-lion", "036-zebra", "017-lynx", "013-reindeer", "024-crocodile", "005-horse", "016-panda-bear", "019-llama", "004-sheep", "027-deer", "028-bear", "026-squirrel", "007-pig", "008-hedgehog", "015-alpaca", "029-raccoon"]
        ),
        CustomStickerCategory(
            name: "birthday",
            localizedKey: "sticker.category.birthday",
            stickers: ["003-gift", "015-birthday", "006-birthday-cake", "014-gift", "001-birthday", "012-ice-cream", "004-birthday-cake", "019-birthday", "007-cupcake", "018-birthday", "010-birthday-cake", "008-birthday", "016-balloons", "009-birthday", "005-cupcake", "017-birthday-cake", "013-cupcake", "020-birthday", "002-birthday", "011-gift"]
        ),
        CustomStickerCategory(
            name: "christmas",
            localizedKey: "sticker.category.christmas",
            stickers: ["014-christmas-tree", "001-snowman", "008-holly", "011-reindeer", "020-cookie", "018-ho-ho-ho", "015-ho-ho-ho", "019-christmas-sock", "004-merry-christmas", "002-cookies", "012-snow", "006-cat", "016-mistletoe", "003-merry-christmas", "007-holly", "005-elf", "017-merry-christmas", "010-hot-chocolate", "013-merry-christmas", "009-santa-claus"]
        ),
        CustomStickerCategory(
            name: "creativity",
            localizedKey: "sticker.category.creativity",
            stickers: ["019-rocket", "006-creativity", "009-creativity", "008-creativity", "016-brainstorm", "007-creativity", "020-learning", "018-creativity", "005-creativity", "010-tool", "012-paint", "002-creativity", "001-drawing-tablet", "003-creativity", "011-think-different", "004-creativity", "015-light-bulb", "014-book", "013-paint-tube", "017-drawing"]
        ),
        CustomStickerCategory(
            name: "days-of-the-week-months-and-seasons",
            localizedKey: "sticker.category.days-of-the-week-months-and-seasons",
            stickers: ["004-june", "016-monday", "005-july", "015-summer", "021-saturday", "007-september", "023-february", "017-tuesday", "003-may", "002-april", "019-thursday", "020-friday", "018-wednesday", "012-autumn", "013-winter", "009-november", "022-january", "008-october", "010-december", "011-sunday", "006-august", "014-spring", "001-march"]
        ),
        CustomStickerCategory(
            name: "food",
            localizedKey: "sticker.category.food",
            stickers: ["001-cake", "017-bowl", "010-cake", "011-vegetables", "012-tea-pot", "002-frappe", "016-pizza", "020-pancakes", "018-fast-food", "013-grocery-bag", "009-tea-pot", "003-cake", "004-gyoza", "014-grocery-bag", "005-noodles", "006-sushi", "015-grocery-bag", "008-coffee-mug", "007-ramen", "019-breakfast"]
        ),
        CustomStickerCategory(
            name: "home",
            localizedKey: "sticker.category.home",
            stickers: ["019-window", "020-stay-home", "006-relax", "011-reading-book", "012-reading", "013-stay-home", "005-teapot", "001-home", "010-stay-home", "017-reading", "016-coffee-mug", "004-coffee-mug", "015-meditation", "003-books", "002-armchair", "014-stretching", "018-stay-home", "007-coffee-mug", "008-stay-home", "009-baking"]
        ),
        CustomStickerCategory(
            name: "love",
            localizedKey: "sticker.category.love",
            stickers: ["016-be-mine", "002-chocolate-box", "004-stamp", "010-love-message", "006-cookies", "001-coffee-cup", "003-valentines-day", "013-love-birds", "015-love", "011-love-message", "005-cassette-tape", "009-love", "008-love-song", "018-you-have-the-key", "012-bee", "007-love-letter", "019-i-love-you", "017-got-you", "020-cupid", "014-i-love-you"]
        ),
        CustomStickerCategory(
            name: "nature",
            localizedKey: "sticker.category.nature",
            stickers: ["004-mouse", "007-butterfly", "015-butterflies", "003-dragonfly", "013-flower", "006-bee", "001-bird", "019-flowers", "017-flowers", "002-bee", "016-whale", "010-nature", "011-mushrooms", "005-cactus", "009-bees", "020-nature", "018-flowers", "012-duck", "008-bird", "014-flowers"]
        ),
        CustomStickerCategory(
            name: "new-year",
            localizedKey: "sticker.category.new-year",
            stickers: ["010-happy-new-year", "009-new-year", "015-happy-new-year", "016-new-year", "018-happy-new-year", "008-happy-new-year", "003-new-year", "004-new-year", "020-new-year", "005-new-year", "002-new-year", "017-new-year", "007-new-year", "012-new-year", "014-new-year", "013-new-year", "006-new-year", "019-new-year", "011-happy-new-year", "001-happy-new-year"]
        )
    ]

    /// Search stickers across all categories
    static func searchStickers(_ query: String) -> [String] {
        guard !query.isEmpty else { return [] }
        let lowercasedQuery = query.lowercased()
        return allCategories.flatMap { $0.stickers }
            .filter { $0.lowercased().contains(lowercasedQuery) }
    }
}
