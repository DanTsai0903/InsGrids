import SwiftUI

// MARK: - Custom Sticker Category
// Organizes custom stickers into browsable categories

/// Individual custom sticker with labels for search
struct CustomSticker: Identifiable, Codable, Hashable {
    var id = UUID()
    let name: String
    let labels: [String]
    
    init(name: String, labels: [String] = []) {
        self.name = name
        self.labels = labels
    }
}

/// Categories for organizing custom sticker assets
struct CustomStickerCategory: Identifiable {
    let id = UUID()
    let name: String
    let localizedKey: String
    let stickers: [CustomSticker]  // Updated to use CustomSticker struct
    
    /// All available custom sticker categories
    /// Initially empty - expand as custom stickers are added
    static let allCategories: [CustomStickerCategory] = [
        CustomStickerCategory(
            name: "animals",
            localizedKey: "sticker.category.animals",
            stickers: [
                CustomSticker(name: "019-bear", labels: ["bear", "animal", "wildlife", "grizzly", "forest", "predator", "mammal"]),
                CustomSticker(name: "010-ostrich", labels: ["ostrich", "bird", "animal", "wildlife", "savanna", "long neck", "feathers"]),
                CustomSticker(name: "011-cat", labels: ["cat", "animal", "pet", "feline", "kitty", "cute", "meow"]),
                CustomSticker(name: "003-nymph", labels: ["nymph", "dragonfly", "insect", "bug", "nature", "wings", "fly"]),
                CustomSticker(name: "008-hamster", labels: ["hamster", "animal", "pet", "rodent", "cute", "small", "cheeks"]),
                CustomSticker(name: "005-mouse", labels: ["mouse", "animal", "wildlife", "rodent", "cute", "small", "cheese"]),
                CustomSticker(name: "018-hammerhead", labels: ["hammerhead", "shark", "animal", "sea", "ocean", "marine", "fish"]),
                CustomSticker(name: "009-blowfish", labels: ["blowfish", "pufferfish", "fish", "sea", "ocean", "marine", "spikes"]),
                CustomSticker(name: "001-penguin", labels: ["penguin", "bird", "animal", "arctic", "snow", "ice", "cold"]),
                CustomSticker(name: "016-cheetah", labels: ["cheetah", "leopard", "animal", "wildlife", "fast", "spots", "cat"]),
                CustomSticker(name: "015-dog", labels: ["dog", "animal", "pet", "canine", "puppy", "cute", "loyal"]),
                CustomSticker(name: "006-walrus", labels: ["walrus", "animal", "sea", "ocean", "arctic", "tusks", "marine"]),
                CustomSticker(name: "007-dolphin", labels: ["dolphin", "sea", "ocean", "marine", "fish", "animal", "swim"]),
                CustomSticker(name: "014-gorilla", labels: ["gorilla", "ape", "animal", "wildlife", "jungle", "strong", "primate"]),
                CustomSticker(name: "020-chameleon", labels: ["chameleon", "lizard", "reptilian", "animal", "wildlife", "colorful", "camouflage"]),
                CustomSticker(name: "017-sea-turtle", labels: ["sea turtle", "turtle", "sea", "ocean", "marine", "reptilian", "animal"]),
                CustomSticker(name: "013-snail", labels: ["snail", "insect", "bug", "slow", "nature", "shell", "garden"]),
                CustomSticker(name: "012-butterfly", labels: ["butterfly", "insect", "bug", "wings", "colorful", "nature", "fly"]),
                CustomSticker(name: "002-rabbit", labels: ["rabbit", "bunny", "animal", "pet", "cute", "ears", "mammal"]),
                CustomSticker(name: "004-panda", labels: ["panda", "bear", "animal", "wildlife", "bamboo", "cute", "black and white"])
            ]
        ),
        CustomStickerCategory(
            name: "birthday",
            localizedKey: "sticker.category.birthday",
            stickers: [
                CustomSticker(name: "003-gift", labels: ["gift", "present", "birthday", "surprise", "celebration", "box", "ribbon"]),
                CustomSticker(name: "015-birthday", labels: ["birthday", "party", "celebration", "happy", "cake", "balloons"]),
                CustomSticker(name: "006-birthday-cake", labels: ["cake", "birthday", "dessert", "sweet", "candles", "party", "celebration"]),
                CustomSticker(name: "014-gift", labels: ["gift", "present", "birthday", "surprise", "celebration", "box", "ribbon"]),
                CustomSticker(name: "001-birthday", labels: ["birthday", "party", "celebration", "happy", "cake", "balloons"]),
                CustomSticker(name: "012-ice-cream", labels: ["ice cream", "dessert", "sweet", "cold", "birthday", "treat"]),
                CustomSticker(name: "004-birthday-cake", labels: ["cake", "birthday", "dessert", "sweet", "candles", "party", "celebration"]),
                CustomSticker(name: "019-birthday", labels: ["birthday", "party", "celebration", "happy", "cake", "balloons"]),
                CustomSticker(name: "007-cupcake", labels: ["cupcake", "dessert", "sweet", "cake", "birthday", "treat"]),
                CustomSticker(name: "018-birthday", labels: ["birthday", "party", "celebration", "happy", "cake", "balloons"]),
                CustomSticker(name: "010-birthday-cake", labels: ["cake", "birthday", "dessert", "sweet", "candles", "party", "celebration"]),
                CustomSticker(name: "008-birthday", labels: ["birthday", "party", "celebration", "happy", "cake", "balloons"]),
                CustomSticker(name: "016-balloons", labels: ["balloons", "party", "celebration", "birthday", "happy", "colorful"]),
                CustomSticker(name: "009-birthday", labels: ["birthday", "party", "celebration", "happy", "cake", "balloons"]),
                CustomSticker(name: "005-cupcake", labels: ["cupcake", "dessert", "sweet", "cake", "birthday", "treat"]),
                CustomSticker(name: "017-birthday-cake", labels: ["cake", "birthday", "dessert", "sweet", "candles", "party", "celebration"]),
                CustomSticker(name: "013-cupcake", labels: ["cupcake", "dessert", "sweet", "cake", "birthday", "treat"]),
                CustomSticker(name: "020-birthday", labels: ["birthday", "party", "celebration", "happy", "cake", "balloons"]),
                CustomSticker(name: "002-birthday", labels: ["birthday", "party", "celebration", "happy", "cake", "balloons"]),
                CustomSticker(name: "011-gift", labels: ["gift", "present", "birthday", "surprise", "celebration", "box", "ribbon"])
            ]
        ),
        CustomStickerCategory(
            name: "business",
            localizedKey: "sticker.category.business",
            stickers: [
                CustomSticker(name: "019-analysis", labels: ["analysis", "statistics", "chart", "data", "business", "report"]),
                CustomSticker(name: "010-deal", labels: ["deal", "agreement", "handshake", "business", "success", "partnership"]),
                CustomSticker(name: "002-balance", labels: ["balance", "scale", "justice", "business", "choice", "equality"]),
                CustomSticker(name: "009-business-idea", labels: ["idea", "light bulb", "business", "innovation", "creative", "start-up"]),
                CustomSticker(name: "007-bar-chart", labels: ["chart", "graph", "data", "analysis", "business", "growth"]),
                CustomSticker(name: "017-innovation", labels: ["innovation", "technology", "business", "idea", "creative", "future"]),
                CustomSticker(name: "016-deal", labels: ["deal", "agreement", "handshake", "business", "success", "partnership"]),
                CustomSticker(name: "014-analysis", labels: ["analysis", "statistics", "chart", "data", "business", "report"]),
                CustomSticker(name: "020-trophy", labels: ["trophy", "award", "success", "business", "winner", "achievement"]),
                CustomSticker(name: "004-searching", labels: ["search", "magnifying glass", "research", "audit", "business", "observation"]),
                CustomSticker(name: "001-management", labels: ["management", "leader", "business", "strategy", "team", "organization"]),
                CustomSticker(name: "008-briefcase", labels: ["briefcase", "bag", "business", "office", "work", "professional"]),
                CustomSticker(name: "011-target", labels: ["target", "goal", "business", "strategy", "focus", "success"]),
                CustomSticker(name: "015-bar-chart", labels: ["chart", "graph", "data", "analysis", "business", "growth"]),
                CustomSticker(name: "012-start-up", labels: ["start-up", "rocket", "business", "launch", "innovation", "growth"]),
                CustomSticker(name: "006-attract", labels: ["attract", "magnet", "business", "customers", "growth", "marketing"]),
                CustomSticker(name: "003-marketing", labels: ["marketing", "speaker", "megaphone", "announcement", "business", "promotion"]),
                CustomSticker(name: "005-thinking", labels: ["thinking", "brain", "business", "idea", "creative", "strategy"]),
                CustomSticker(name: "013-start-up", labels: ["start-up", "rocket", "business", "launch", "innovation", "growth"]),
                CustomSticker(name: "018-investment", labels: ["investment", "money", "business", "growth", "profit", "finance"])
            ]
        ),
        CustomStickerCategory(
            name: "christmas",
            localizedKey: "sticker.category.christmas",
            stickers: [
                CustomSticker(name: "014-christmas-tree", labels: ["tree", "christmas", "holiday", "winter", "celebration", "decoration"]),
                CustomSticker(name: "001-snowman", labels: ["snowman", "winter", "snow", "christmas", "holiday", "cold"]),
                CustomSticker(name: "008-holly", labels: ["holly", "plant", "christmas", "decoration", "winter", "berry"]),
                CustomSticker(name: "011-reindeer", labels: ["reindeer", "animal", "christmas", "winter", "holiday", "santa"]),
                CustomSticker(name: "020-cookie", labels: ["cookie", "gingerbread", "christmas", "sweet", "dessert", "holiday"]),
                CustomSticker(name: "018-ho-ho-ho", labels: ["ho ho ho", "santa", "christmas", "holiday", "happy", "greeting"]),
                CustomSticker(name: "015-ho-ho-ho", labels: ["ho ho ho", "santa", "christmas", "holiday", "happy", "greeting"]),
                CustomSticker(name: "019-christmas-sock", labels: ["stocking", "sock", "christmas", "gift", "holiday", "winter"]),
                CustomSticker(name: "004-merry-christmas", labels: ["merry christmas", "greeting", "christmas", "holiday", "happy", "celebration"]),
                CustomSticker(name: "002-cookies", labels: ["cookies", "gingerbread", "christmas", "sweet", "dessert", "holiday"]),
                CustomSticker(name: "012-snow", labels: ["snow", "snowflake", "winter", "cold", "christmas", "holiday"]),
                CustomSticker(name: "006-cat", labels: ["cat", "animal", "christmas", "holiday", "cute", "pet"]),
                CustomSticker(name: "016-mistletoe", labels: ["mistletoe", "plant", "christmas", "decoration", "kiss", "winter"]),
                CustomSticker(name: "003-merry-christmas", labels: ["merry christmas", "greeting", "christmas", "holiday", "happy", "celebration"]),
                CustomSticker(name: "007-holly", labels: ["holly", "plant", "christmas", "decoration", "winter", "berry"]),
                CustomSticker(name: "005-elf", labels: ["elf", "christmas", "worker", "santa helper", "holiday", "hat"]),
                CustomSticker(name: "017-merry-christmas", labels: ["merry christmas", "greeting", "christmas", "holiday", "happy", "celebration"]),
                CustomSticker(name: "010-hot-chocolate", labels: ["cocoa", "chocolate", "drink", "winter", "warm", "christmas", "mug"]),
                CustomSticker(name: "013-merry-christmas", labels: ["merry christmas", "greeting", "christmas", "holiday", "happy", "celebration"]),
                CustomSticker(name: "009-santa-claus", labels: ["santa claus", "santa", "christmas", "holiday", "gift", "happy"])
            ]
        ),
        CustomStickerCategory(
            name: "creativity",
            localizedKey: "sticker.category.creativity",
            stickers: [
                CustomSticker(name: "019-rocket", labels: ["rocket", "space", "launch", "creativity", "idea", "start-up"]),
                CustomSticker(name: "006-creativity", labels: ["creativity", "art", "design", "idea", "paint", "color"]),
                CustomSticker(name: "009-creativity", labels: ["creativity", "art", "design", "idea", "paint", "color"]),
                CustomSticker(name: "008-creativity", labels: ["creativity", "art", "design", "idea", "paint", "color"]),
                CustomSticker(name: "016-brainstorm", labels: ["brainstorming", "idea", "creativity", "mind", "thinking", "group"]),
                CustomSticker(name: "007-creativity", labels: ["creativity", "art", "design", "idea", "paint", "color"]),
                CustomSticker(name: "020-learning", labels: ["learning", "book", "education", "creativity", "study", "knowledge"]),
                CustomSticker(name: "018-creativity", labels: ["creativity", "art", "design", "idea", "paint", "color"]),
                CustomSticker(name: "005-creativity", labels: ["creativity", "art", "design", "idea", "paint", "color"]),
                CustomSticker(name: "010-tool", labels: ["tool", "wrench", "creativity", "fix", "build", "settings"]),
                CustomSticker(name: "012-paint", labels: ["paint", "palette", "art", "creativity", "color", "design"]),
                CustomSticker(name: "002-creativity", labels: ["creativity", "art", "design", "idea", "paint", "color"]),
                CustomSticker(name: "001-drawing-tablet", labels: ["tablet", "drawing", "art", "design", "digital", "creativity"]),
                CustomSticker(name: "003-creativity", labels: ["creativity", "art", "design", "idea", "paint", "color"]),
                CustomSticker(name: "011-think-different", labels: ["think", "idea", "different", "creative", "innovation", "brain"]),
                CustomSticker(name: "004-creativity", labels: ["creativity", "art", "design", "idea", "paint", "color"]),
                CustomSticker(name: "015-light-bulb", labels: ["light bulb", "idea", "creativity", "innovation", "light", "thinking"]),
                CustomSticker(name: "014-book", labels: ["book", "reading", "creativity", "education", "knowledge", "learning"]),
                CustomSticker(name: "013-paint-tube", labels: ["paint", "tube", "art", "creativity", "color", "design"]),
                CustomSticker(name: "017-drawing", labels: ["drawing", "art", "sketch", "creativity", "pencil", "design"])
            ]
        ),
        CustomStickerCategory(
            name: "time",
            localizedKey: "sticker.category.time",
            stickers: [
                CustomSticker(name: "004-june", labels: ["june", "month", "summer", "time", "calendar", "date"]),
                CustomSticker(name: "016-monday", labels: ["monday", "day", "week", "time", "calendar", "work"]),
                CustomSticker(name: "005-july", labels: ["july", "month", "summer", "time", "calendar", "date"]),
                CustomSticker(name: "015-summer", labels: ["summer", "season", "sun", "hot", "nature", "warm"]),
                CustomSticker(name: "021-saturday", labels: ["saturday", "weekend", "day", "week", "time", "party"]),
                CustomSticker(name: "007-september", labels: ["september", "month", "autumn", "time", "calendar", "date"]),
                CustomSticker(name: "023-february", labels: ["february", "month", "winter", "time", "calendar", "date"]),
                CustomSticker(name: "017-tuesday", labels: ["tuesday", "day", "week", "time", "calendar", "date"]),
                CustomSticker(name: "003-may", labels: ["may", "month", "spring", "time", "calendar", "date"]),
                CustomSticker(name: "002-april", labels: ["april", "month", "spring", "time", "calendar", "date"]),
                CustomSticker(name: "019-thursday", labels: ["thursday", "day", "week", "time", "calendar", "date"]),
                CustomSticker(name: "020-friday", labels: ["friday", "day", "week", "weekend", "time", "happy"]),
                CustomSticker(name: "018-wednesday", labels: ["wednesday", "day", "week", "time", "calendar", "date"]),
                CustomSticker(name: "012-autumn", labels: ["autumn", "fall", "season", "leaves", "nature", "orange"]),
                CustomSticker(name: "013-winter", labels: ["winter", "season", "snow", "cold", "nature", "white"]),
                CustomSticker(name: "009-november", labels: ["november", "month", "autumn", "time", "calendar", "date"]),
                CustomSticker(name: "022-january", labels: ["january", "month", "winter", "time", "calendar", "date"]),
                CustomSticker(name: "008-october", labels: ["october", "month", "autumn", "time", "calendar", "date"]),
                CustomSticker(name: "010-december", labels: ["december", "month", "winter", "christmas", "time", "date"]),
                CustomSticker(name: "011-sunday", labels: ["sunday", "weekend", "day", "week", "time", "relax"]),
                CustomSticker(name: "006-august", labels: ["august", "month", "summer", "time", "calendar", "date"]),
                CustomSticker(name: "014-spring", labels: ["spring", "season", "flowers", "nature", "green", "warm"]),
                CustomSticker(name: "001-march", labels: ["march", "month", "spring", "time", "calendar", "date"])
            ]
        ),
        CustomStickerCategory(
            name: "food",
            localizedKey: "sticker.category.food",
            stickers: [
                CustomSticker(name: "001-cake", labels: ["cake", "dessert", "sweet", "food", "party", "celebration"]),
                CustomSticker(name: "017-bowl", labels: ["bowl", "soup", "noodles", "food", "dinner", "lunch"]),
                CustomSticker(name: "010-cake", labels: ["cake", "dessert", "sweet", "food", "party", "celebration"]),
                CustomSticker(name: "011-vegetables", labels: ["vegetables", "healthy", "food", "green", "nature", "cooking"]),
                CustomSticker(name: "012-tea-pot", labels: ["tea pot", "tea", "drink", "warm", "breakfast", "relax"]),
                CustomSticker(name: "002-frappe", labels: ["frappe", "coffee", "drink", "cold", "sweet", "starbucks"]),
                CustomSticker(name: "016-pizza", labels: ["pizza", "fast food", "italian", "dinner", "lunch", "cheese"]),
                CustomSticker(name: "020-pancakes", labels: ["pancakes", "breakfast", "sweet", "food", "morning", "syrup"]),
                CustomSticker(name: "018-fast-food", labels: ["fast food", "burger", "fries", "junk food", "dinner", "lunch"]),
                CustomSticker(name: "013-grocery-bag", labels: ["grocery bag", "shopping", "food", "market", "ingredients", "buy"]),
                CustomSticker(name: "009-tea-pot", labels: ["tea pot", "tea", "drink", "warm", "breakfast", "relax"]),
                CustomSticker(name: "003-cake", labels: ["cake", "dessert", "sweet", "food", "party", "celebration"]),
                CustomSticker(name: "004-gyoza", labels: ["gyoza", "dumplings", "japanese", "asian food", "dinner", "lunch"]),
                CustomSticker(name: "014-grocery-bag", labels: ["grocery bag", "shopping", "food", "market", "ingredients", "buy"]),
                CustomSticker(name: "005-noodles", labels: ["noodles", "ramen", "asian food", "soup", "dinner", "lunch"]),
                CustomSticker(name: "006-sushi", labels: ["sushi", "japanese", "fish", "rice", "dinner", "lunch"]),
                CustomSticker(name: "015-grocery-bag", labels: ["grocery bag", "shopping", "food", "market", "ingredients", "buy"]),
                CustomSticker(name: "008-coffee-mug", labels: ["coffee", "mug", "drink", "warm", "morning", "breakfast"]),
                CustomSticker(name: "007-ramen", labels: ["ramen", "noodles", "asian food", "soup", "dinner", "lunch"]),
                CustomSticker(name: "019-breakfast", labels: ["breakfast", "egg", "bacon", "toast", "morning", "food"])
            ]
        ),
        CustomStickerCategory(
            name: "home",
            localizedKey: "sticker.category.home",
            stickers: [
                CustomSticker(name: "019-window", labels: ["window", "home", "house", "view", "glass", "building"]),
                CustomSticker(name: "020-stay-home", labels: ["stay home", "home", "safe", "house", "quarantine", "rest"]),
                CustomSticker(name: "006-relax", labels: ["relax", "home", "chill", "happy", "peaceful", "rest"]),
                CustomSticker(name: "011-reading-book", labels: ["reading", "book", "home", "education", "knowledge", "hobby"]),
                CustomSticker(name: "012-reading", labels: ["reading", "book", "home", "education", "knowledge", "hobby"]),
                CustomSticker(name: "013-stay-home", labels: ["stay home", "home", "safe", "house", "quarantine", "rest"]),
                CustomSticker(name: "005-teapot", labels: ["teapot", "tea", "home", "warm", "drink", "relax"]),
                CustomSticker(name: "001-home", labels: ["home", "house", "building", "stay home", "safety", "place"]),
                CustomSticker(name: "010-stay-home", labels: ["stay home", "home", "safe", "house", "quarantine", "rest"]),
                CustomSticker(name: "017-reading", labels: ["reading", "book", "home", "education", "knowledge", "hobby"]),
                CustomSticker(name: "016-coffee-mug", labels: ["coffee", "mug", "home", "warm", "drink", "morning"]),
                CustomSticker(name: "004-coffee-mug", labels: ["coffee", "mug", "home", "warm", "drink", "morning"]),
                CustomSticker(name: "015-meditation", labels: ["meditation", "yoga", "home", "relax", "peaceful", "mind"]),
                CustomSticker(name: "003-books", labels: ["books", "reading", "home", "education", "knowledge", "study"]),
                CustomSticker(name: "002-armchair", labels: ["armchair", "sofa", "home", "furniture", "relax", "chill"]),
                CustomSticker(name: "014-stretching", labels: ["stretching", "exercise", "home", "yoga", "fitness", "health"]),
                CustomSticker(name: "018-stay-home", labels: ["stay home", "home", "safe", "house", "quarantine", "rest"]),
                CustomSticker(name: "007-coffee-mug", labels: ["coffee", "mug", "home", "warm", "drink", "morning"]),
                CustomSticker(name: "008-stay-home", labels: ["stay home", "home", "safe", "house", "quarantine", "rest"]),
                CustomSticker(name: "009-baking", labels: ["baking", "cooking", "home", "cake", "kitchen", "food"])
            ]
        ),
        CustomStickerCategory(
            name: "love",
            localizedKey: "sticker.category.love",
            stickers: [
                CustomSticker(name: "013-love-potion", labels: ["love", "potion", "magic", "heart", "romance", "sweet"]),
                CustomSticker(name: "003-be-mine", labels: ["be mine", "love", "heart", "valentines", "romance", "happy"]),
                CustomSticker(name: "020-i-love-you", labels: ["i love you", "love", "heart", "greeting", "romance", "happy"]),
                CustomSticker(name: "015-love-yourself", labels: ["love yourself", "self care", "heart", "love", "happy", "positive"]),
                CustomSticker(name: "010-be-mine", labels: ["be mine", "love", "heart", "valentines", "romance", "happy"]),
                CustomSticker(name: "009-sending", labels: ["sending love", "heart", "love", "letter", "mail", "romance"]),
                CustomSticker(name: "004-glass", labels: ["glass", "drink", "love", "heart", "valentines", "romance"]),
                CustomSticker(name: "018-love-you-till-the-bones", labels: ["love", "bones", "skeleton", "forever", "romance", "heart"]),
                CustomSticker(name: "002-i-love-you", labels: ["i love you", "love", "heart", "greeting", "romance", "happy"]),
                CustomSticker(name: "011-love", labels: ["love", "heart", "romance", "happy", "Valentines", "celebration"]),
                CustomSticker(name: "005-love-is-in-the-air", labels: ["love", "air", "balloon", "heart", "romance", "happy"]),
                CustomSticker(name: "019-love-you", labels: ["love you", "love", "heart", "greeting", "romance", "happy"]),
                CustomSticker(name: "007-heart", labels: ["heart", "love", "romance", "happy", "valentines", "celebration"]),
                CustomSticker(name: "006-i-love-you", labels: ["i love you", "love", "heart", "greeting", "romance", "happy"]),
                CustomSticker(name: "012-cherry", labels: ["cherry", "fruit", "love", "heart", "sweet", "pair"]),
                CustomSticker(name: "014-i-love-you", labels: ["i love you", "love", "heart", "greeting", "romance", "happy"]),
                CustomSticker(name: "001-love", labels: ["love", "heart", "romance", "happy", "valentines", "celebration"]),
                CustomSticker(name: "008-i-love-you", labels: ["i love you", "love", "heart", "greeting", "romance", "happy"]),
                CustomSticker(name: "016-love", labels: ["love", "heart", "romance", "happy", "valentines", "celebration"]),
                CustomSticker(name: "017-love", labels: ["love", "heart", "romance", "happy", "valentines", "celebration"])
            ]
        ),
        CustomStickerCategory(
            name: "nature",
            localizedKey: "sticker.category.nature",
            stickers: [
                CustomSticker(name: "004-mouse", labels: ["mouse", "animal", "wildlife", "nature", "cute", "small"]),
                CustomSticker(name: "007-butterfly", labels: ["butterfly", "insect", "nature", "beautiful", "colorful", "wings"]),
                CustomSticker(name: "015-butterflies", labels: ["butterflies", "insects", "nature", "beautiful", "colorful", "wings"]),
                CustomSticker(name: "003-dragonfly", labels: ["dragonfly", "insect", "nature", "wings", "wildlife", "green"]),
                CustomSticker(name: "013-flower", labels: ["flower", "plant", "nature", "beautiful", "blossom", "spring"]),
                CustomSticker(name: "006-bee", labels: ["bee", "insect", "nature", "honey", "yellow", "wings"]),
                CustomSticker(name: "001-bird", labels: ["bird", "animal", "nature", "wildlife", "wings", "fly"]),
                CustomSticker(name: "019-flowers", labels: ["flowers", "plants", "nature", "beautiful", "bouquet", "spring"]),
                CustomSticker(name: "017-flowers", labels: ["flowers", "plants", "nature", "beautiful", "bouquet", "spring"]),
                CustomSticker(name: "002-bee", labels: ["bee", "insect", "nature", "honey", "yellow", "wings"]),
                CustomSticker(name: "016-whale", labels: ["whale", "ocean", "sea", "animal", "nature", "mammals"]),
                CustomSticker(name: "010-nature", labels: ["nature", "landscape", "outdoors", "beautiful", "peaceful", "trees"]),
                CustomSticker(name: "011-mushrooms", labels: ["mushrooms", "fungi", "nature", "forest", "plants", "wild"]),
                CustomSticker(name: "005-cactus", labels: ["cactus", "desert", "plant", "nature", "green", "spikes"]),
                CustomSticker(name: "009-bees", labels: ["bees", "insects", "nature", "honey", "yellow", "wings"]),
                CustomSticker(name: "020-nature", labels: ["nature", "landscape", "outdoors", "beautiful", "peaceful", "trees"]),
                CustomSticker(name: "018-flowers", labels: ["flowers", "plants", "nature", "beautiful", "bouquet", "spring"]),
                CustomSticker(name: "012-duck", labels: ["duck", "bird", "water", "nature", "animal", "wildlife"]),
                CustomSticker(name: "008-bird", labels: ["bird", "animal", "nature", "wildlife", "wings", "fly"]),
                CustomSticker(name: "014-flowers", labels: ["flowers", "plants", "nature", "beautiful", "bouquet", "spring"])
            ]
        ),
        CustomStickerCategory(
            name: "new-year",
            localizedKey: "sticker.category.new-year",
            stickers: [
                CustomSticker(name: "010-happy-new-year", labels: ["happy new year", "new year", "celebration", "happy", "party", "fireworks"]),
                CustomSticker(name: "009-new-year", labels: ["new year", "celebration", "countdown", "party", "happy", "holiday"]),
                CustomSticker(name: "015-happy-new-year", labels: ["happy new year", "new year", "celebration", "happy", "party", "fireworks"]),
                CustomSticker(name: "016-new-year", labels: ["new year", "celebration", "countdown", "party", "happy", "holiday"]),
                CustomSticker(name: "018-happy-new-year", labels: ["happy new year", "new year", "celebration", "happy", "party", "fireworks"]),
                CustomSticker(name: "008-happy-new-year", labels: ["happy new year", "new year", "celebration", "happy", "party", "fireworks"]),
                CustomSticker(name: "003-new-year", labels: ["new year", "celebration", "countdown", "party", "happy", "holiday"]),
                CustomSticker(name: "004-new-year", labels: ["new year", "celebration", "countdown", "party", "happy", "holiday"]),
                CustomSticker(name: "020-new-year", labels: ["new year", "celebration", "countdown", "party", "happy", "holiday"]),
                CustomSticker(name: "005-new-year", labels: ["new year", "celebration", "countdown", "party", "happy", "holiday"]),
                CustomSticker(name: "002-new-year", labels: ["new year", "celebration", "countdown", "party", "happy", "holiday"]),
                CustomSticker(name: "017-new-year", labels: ["new year", "celebration", "countdown", "party", "happy", "holiday"]),
                CustomSticker(name: "007-new-year", labels: ["new year", "celebration", "countdown", "party", "happy", "holiday"]),
                CustomSticker(name: "012-new-year", labels: ["new year", "celebration", "countdown", "party", "happy", "holiday"]),
                CustomSticker(name: "014-new-year", labels: ["new year", "celebration", "countdown", "party", "happy", "holiday"]),
                CustomSticker(name: "013-new-year", labels: ["new year", "celebration", "countdown", "party", "happy", "holiday"]),
                CustomSticker(name: "006-new-year", labels: ["new year", "celebration", "countdown", "party", "happy", "holiday"]),
                CustomSticker(name: "019-new-year", labels: ["new year", "celebration", "countdown", "party", "happy", "holiday"]),
                CustomSticker(name: "011-happy-new-year", labels: ["happy new year", "new year", "celebration", "happy", "party", "fireworks"]),
                CustomSticker(name: "001-happy-new-year", labels: ["happy new year", "new year", "celebration", "happy", "party", "fireworks"])
            ]
        ),
        CustomStickerCategory(
            name: "onomatopoeias",
            localizedKey: "sticker.category.onomatopoeias",
            stickers: [
                CustomSticker(name: "003-gulp", labels: ["gulp", "swallow", "sound", "drink", "comic", "cartoon"]),
                CustomSticker(name: "012-wow", labels: ["wow", "surprise", "amazing", "sound", "comic", "cartoon"]),
                CustomSticker(name: "010-zap", labels: ["zap", "energy", "electricity", "sound", "comic", "cartoon"]),
                CustomSticker(name: "014-crack", labels: ["crack", "break", "snap", "sound", "comic", "cartoon"]),
                CustomSticker(name: "008-pow", labels: ["pow", "hit", "punch", "sound", "comic", "cartoon"]),
                CustomSticker(name: "019-ouch", labels: ["ouch", "pain", "hurt", "sound", "comic", "cartoon"]),
                CustomSticker(name: "011-splash", labels: ["splash", "water", "liquid", "sound", "comic", "cartoon"]),
                CustomSticker(name: "004-crash", labels: ["crash", "break", "accident", "sound", "comic", "cartoon"]),
                CustomSticker(name: "006-bang", labels: ["bang", "explosion", "gun", "sound", "comic", "cartoon"]),
                CustomSticker(name: "013-snap", labels: ["snap", "break", "fast", "sound", "comic", "cartoon"]),
                CustomSticker(name: "017-woosh", labels: ["woosh", "wind", "move", "sound", "comic", "cartoon"]),
                CustomSticker(name: "009-boom", labels: ["boom", "explosion", "loud", "sound", "comic", "cartoon"]),
                CustomSticker(name: "001-ohh", labels: ["ohh", "surprise", "realization", "sound", "comic", "cartoon"]),
                CustomSticker(name: "016-slap", labels: ["slap", "hit", "hand", "sound", "comic", "cartoon"]),
                CustomSticker(name: "007-zzz", labels: ["zzz", "sleep", "snore", "sound", "comic", "cartoon"]),
                CustomSticker(name: "002-buzz", labels: ["buzz", "bee", "insect", "sound", "comic", "cartoon"]),
                CustomSticker(name: "015-ka-pow", labels: ["ka-pow", "hit", "punch", "sound", "comic", "cartoon"]),
                CustomSticker(name: "020-smash", labels: ["smash", "break", "hit", "sound", "comic", "cartoon"]),
                CustomSticker(name: "005-oops", labels: ["oops", "mistake", "surprise", "sound", "comic", "cartoon"]),
                CustomSticker(name: "018-haha", labels: ["haha", "laugh", "happy", "sound", "comic", "cartoon"])
            ]
        ),
        CustomStickerCategory(
            name: "pets",
            localizedKey: "sticker.category.pets",
            stickers: [
                CustomSticker(name: "007-dog", labels: ["dog", "animal", "pet", "puppy", "canine", "cute"]),
                CustomSticker(name: "001-ferret", labels: ["ferret", "animal", "pet", "weasel", "long", "cute"]),
                CustomSticker(name: "009-cat", labels: ["cat", "animal", "pet", "feline", "kitty", "cute"]),
                CustomSticker(name: "006-bird", labels: ["bird", "animal", "pet", "wildlife", "feathers", "fly"]),
                CustomSticker(name: "011-pig", labels: ["pig", "animal", "pet", "farm", "pink", "cute"]),
                CustomSticker(name: "008-hamster", labels: ["hamster", "animal", "pet", "rodent", "small", "cute"]),
                CustomSticker(name: "004-guinea-pig", labels: ["guinea pig", "animal", "pet", "rodent", "small", "cute"]),
                CustomSticker(name: "005-bunny", labels: ["bunny", "rabbit", "animal", "pet", "ears", "cute"]),
                CustomSticker(name: "019-parrot", labels: ["parrot", "bird", "animal", "pet", "colorful", "talk"]),
                CustomSticker(name: "016-cat", labels: ["cat", "animal", "pet", "feline", "kitty", "cute"]),
                CustomSticker(name: "018-dog", labels: ["dog", "animal", "pet", "puppy", "canine", "cute"]),
                CustomSticker(name: "010-fish", labels: ["fish", "animal", "pet", "water", "ocean", "bowl"]),
                CustomSticker(name: "003-dog", labels: ["dog", "animal", "pet", "puppy", "canine", "cute"]),
                CustomSticker(name: "013-dog", labels: ["dog", "animal", "pet", "puppy", "canine", "cute"]),
                CustomSticker(name: "014-cat", labels: ["cat", "animal", "pet", "feline", "kitty", "cute"]),
                CustomSticker(name: "015-bird", labels: ["bird", "animal", "pet", "wildlife", "feathers", "fly"]),
                CustomSticker(name: "017-fish", labels: ["fish", "animal", "pet", "water", "ocean", "bowl"]),
                CustomSticker(name: "020-mouse", labels: ["mouse", "animal", "pet", "rodent", "small", "cute"]),
                CustomSticker(name: "012-dog", labels: ["dog", "animal", "pet", "puppy", "canine", "cute"]),
                CustomSticker(name: "002-turtle", labels: ["turtle", "animal", "pet", "reptile", "slow", "shell"])
            ]
        ),
        CustomStickerCategory(
            name: "positive-expressions",
            localizedKey: "sticker.category.positive-expressions",
            stickers: [
                CustomSticker(name: "008-good-vibes-only", labels: ["good vibes", "positive", "happy", "mood", "energy", "support"]),
                CustomSticker(name: "010-fresh-start", labels: ["fresh start", "new", "positive", "growth", "change", "hope"]),
                CustomSticker(name: "001-make-it-happen", labels: ["make it happen", "motivation", "positive", "success", "action", "goal"]),
                CustomSticker(name: "002-stay-positive", labels: ["stay positive", "happy", "mood", "energy", "support", "optimistic"]),
                CustomSticker(name: "015-dont-give-up", labels: ["don't give up", "motivation", "persistent", "strong", "support", "positive"]),
                CustomSticker(name: "011-you-ve-got-this", labels: ["you got this", "motivation", "confidence", "support", "strength", "positive"]),
                CustomSticker(name: "003-just-be-happy", labels: ["be happy", "joy", "smile", "mood", "positive", "peace"]),
                CustomSticker(name: "018-you-are-stronger-than-you-think", labels: ["stronger", "motivation", "power", "support", "strong", "positive"]),
                CustomSticker(name: "012-you-re-doing-great", labels: ["doing great", "success", "motivation", "support", "praise", "positive"]),
                CustomSticker(name: "005-today-is-the-perfect-day", labels: ["today", "perfect", "happy", "positive", "joy", "memory"]),
                CustomSticker(name: "017-be-the-best-version-of-yourself", labels: ["best self", "growth", "motivation", "positive", "change", "success"]),
                CustomSticker(name: "006-wake-up-and-smile", labels: ["wake up", "smile", "morning", "happy", "positive", "joy"]),
                CustomSticker(name: "004-everything-will-be-ok", labels: ["everything ok", "hope", "comfort", "support", "reassurance", "positive"]),
                CustomSticker(name: "014-make-today-amazing", labels: ["today", "amazing", "happy", "positive", "joy", "action"]),
                CustomSticker(name: "020-positive-vibes", labels: ["positive vibes", "happy", "mood", "energy", "lifestyle", "support"]),
                CustomSticker(name: "013-focus-on-the-good", labels: ["focus", "good", "positive", "mindset", "peace", "happiness"]),
                CustomSticker(name: "009-the-time-is-now", labels: ["now", "time", "action", "motivation", "positive", "start"]),
                CustomSticker(name: "019-let-your-dreams-be-your-wings", labels: ["dreams", "wings", "motivation", "fly", "success", "future"]),
                CustomSticker(name: "016-enjoy-the-little-things", labels: ["little things", "gratitude", "happy", "positive", "peace", "joy"]),
                CustomSticker(name: "007-good-things-are-coming", labels: ["good things", "hope", "future", "positive", "waiting", "joy"])
            ]
        ),
        CustomStickerCategory(
            name: "stay-at-home",
            localizedKey: "sticker.category.stay-at-home",
            stickers: [
                CustomSticker(name: "015-video-calling", labels: ["video call", "home", "computer", "friends", "chat", "online"]),
                CustomSticker(name: "018-drinking", labels: ["drinking", "water", "home", "thirst", "health", "mug"]),
                CustomSticker(name: "007-stay-at-home", labels: ["stay home", "home", "house", "safety", "health", "care"]),
                CustomSticker(name: "009-watering-plants", labels: ["plants", "water", "home", "garden", "hobby", "nature"]),
                CustomSticker(name: "010-cooking", labels: ["cooking", "kitchen", "home", "food", "chef", "hobby"]),
                CustomSticker(name: "008-online-training", labels: ["training", "exercise", "home", "fitness", "computer", "coach"]),
                CustomSticker(name: "003-tea-time", labels: ["tea", "drink", "home", "relax", "break", "warm"]),
                CustomSticker(name: "020-reading", labels: ["reading", "book", "home", "hobby", "education", "study"]),
                CustomSticker(name: "013-laptop", labels: ["laptop", "computer", "work from home", "home", "office", "tech"]),
                CustomSticker(name: "014-chatting", labels: ["chatting", "phone", "friends", "home", "social", "talk"]),
                CustomSticker(name: "004-play-with-pet", labels: ["pet", "dog", "cat", "home", "play", "animal", "joy"]),
                CustomSticker(name: "012-guitar", labels: ["guitar", "music", "home", "hobby", "instrument", "play"]),
                CustomSticker(name: "006-video-calling", labels: ["video call", "home", "computer", "friends", "chat", "online"]),
                CustomSticker(name: "005-reading", labels: ["reading", "book", "home", "hobby", "education", "study"]),
                CustomSticker(name: "017-chatting", labels: ["chatting", "phone", "friends", "home", "social", "talk"]),
                CustomSticker(name: "011-coffee-time", labels: ["coffee", "drink", "home", "morning", "break", "energy"]),
                CustomSticker(name: "002-dumbbell", labels: ["dumbbell", "exercise", "home", "fitness", "health", "strong"]),
                CustomSticker(name: "019-bath", labels: ["bath", "shower", "home", "hygiene", "clean", "relax"]),
                CustomSticker(name: "016-listening", labels: ["listening", "music", "headphones", "home", "hobby", "sound"]),
                CustomSticker(name: "001-listening", labels: ["listening", "music", "headphones", "home", "hobby", "sound"])
            ]
        ),
        CustomStickerCategory(
            name: "support-letterings",
            localizedKey: "sticker.category.support-letterings",
            stickers: [
                CustomSticker(name: "002-take-care", labels: ["take care", "support", "love", "kindness", "health", "friend"]),
                CustomSticker(name: "012-world-aids-day", labels: ["world aids day", "health", "support", "awareness", "community", "red ribbon"]),
                CustomSticker(name: "020-get-well-soon", labels: ["get well", "health", "sickness", "support", "recovery", "friend"]),
                CustomSticker(name: "011-support-local-businesses", labels: ["local business", "support", "community", "shopping", "neighborhood", "help"]),
                CustomSticker(name: "007-love-wins", labels: ["love wins", "pride", "rainbow", "love", "support", "equality"]),
                CustomSticker(name: "004-happy-pride-day", labels: ["pride", "rainbow", "celebration", "support", "equality", "happy"]),
                CustomSticker(name: "010-stay-safe", labels: ["stay safe", "health", "caution", "protection", "support", "community"]),
                CustomSticker(name: "016-stay-at-home", labels: ["stay home", "home", "safety", "health", "community", "protection"]),
                CustomSticker(name: "001-stay-strong", labels: ["stay strong", "motivation", "power", "support", "strong", "positive"]),
                CustomSticker(name: "008-have-safe-sex", labels: ["safe sex", "health", "protection", "belt", "condom", "awareness"]),
                CustomSticker(name: "017-take-care-of-others", labels: ["help", "support", "kindness", "community", "care", "humanity"]),
                CustomSticker(name: "019-keep-your-distance", labels: ["distance", "spacing", "healthy", "community", "safety", "protection"]),
                CustomSticker(name: "015-support-local-businesses", labels: ["local business", "support", "community", "shopping", "neighborhood", "help"]),
                CustomSticker(name: "005-love-is-love", labels: ["love", "equality", "pride", "rainbow", "support", "heart"]),
                CustomSticker(name: "006-born-this-way", labels: ["born this way", "pride", "rainbow", "support", "identity", "love"]),
                CustomSticker(name: "009-no-glove-no-love", labels: ["safe sex", "health", "protection", "awareness", "belt", "condom"]),
                CustomSticker(name: "018-thanks-to-all-the-doctors", labels: ["doctors", "nurses", "heroes", "medical", "thank you", "support"]),
                CustomSticker(name: "014-shop-local", labels: ["shop local", "business", "support", "community", "neighborhood", "buy"]),
                CustomSticker(name: "013-shop-local", labels: ["shop local", "business", "support", "community", "neighborhood", "buy"]),
                CustomSticker(name: "003-best-wishes", labels: ["best wishes", "greeting", "support", "luck", "success", "happy"])
            ]
        ),
        CustomStickerCategory(
            name: "wedding",
            localizedKey: "sticker.category.wedding",
            stickers: [
                CustomSticker(name: "018-just-married", labels: ["just married", "wedding", "celebration", "love", "happy", "couple"]),
                CustomSticker(name: "015-bride", labels: ["bride", "wedding", "woman", "dress", "white", "romance"]),
                CustomSticker(name: "008-wedding", labels: ["wedding", "marriage", "event", "love", "ceremony", "celebration"]),
                CustomSticker(name: "007-save-the-date", labels: ["save the date", "wedding", "calendar", "invitation", "event", "love"]),
                CustomSticker(name: "010-will-you-marry-me", labels: ["proposal", "wedding", "marry", "love", "romance", "question"]),
                CustomSticker(name: "014-groom", labels: ["groom", "wedding", "man", "suit", "tuxedo", "marriage"]),
                CustomSticker(name: "020-happily-ever-after", labels: ["happily ever after", "wedding", "love", "forever", "romance", "story"]),
                CustomSticker(name: "019-just-married", labels: ["just married", "wedding", "celebration", "love", "happy", "couple"]),
                CustomSticker(name: "012-just-married", labels: ["just married", "wedding", "celebration", "love", "happy", "couple"]),
                CustomSticker(name: "002-will-you-marry-me", labels: ["proposal", "wedding", "marry", "love", "romance", "question"]),
                CustomSticker(name: "009-just-married", labels: ["just married", "wedding", "celebration", "love", "happy", "couple"]),
                CustomSticker(name: "004-save-the-date", labels: ["save the date", "wedding", "calendar", "invitation", "event", "love"]),
                CustomSticker(name: "006-bride", labels: ["bride", "wedding", "woman", "dress", "white", "romance"]),
                CustomSticker(name: "017-bride", labels: ["bride", "wedding", "woman", "dress", "white", "romance"]),
                CustomSticker(name: "011-bride", labels: ["bride", "wedding", "woman", "dress", "white", "romance"]),
                CustomSticker(name: "016-groom", labels: ["groom", "wedding", "man", "suit", "tuxedo", "marriage"]),
                CustomSticker(name: "013-save-the-date", labels: ["save the date", "wedding", "calendar", "invitation", "event", "love"]),
                CustomSticker(name: "003-wedding", labels: ["wedding", "marriage", "event", "love", "ceremony", "celebration"]),
                CustomSticker(name: "001-i-love-you", labels: ["i love you", "heart", "romance", "wedding", "love", "happy"]),
                CustomSticker(name: "005-groom", labels: ["groom", "wedding", "man", "suit", "tuxedo", "marriage"])
            ]
        )
    
    ]

    /// Search stickers across all categories
    static func searchStickers(_ query: String) -> [CustomSticker] {
        guard !query.isEmpty else { return [] }
        let lowercasedQuery = query.lowercased()
        
        let allStickers = allCategories.flatMap { $0.stickers }
        
        // Use a Set to avoid duplicates if same sticker is in multiple categories (though not common here)
        var results: [CustomSticker] = []
        var seenNames = Set<String>()
        
        for sticker in allStickers {
            if seenNames.contains(sticker.name) { continue }
            
            // Search in name
            if sticker.name.lowercased().contains(lowercasedQuery) {
                results.append(sticker)
                seenNames.insert(sticker.name)
                continue
            }
            
            // Search in labels
            if sticker.labels.contains(where: { $0.lowercased().contains(lowercasedQuery) }) {
                results.append(sticker)
                seenNames.insert(sticker.name)
            }
        }
        
        return results
    }
}



