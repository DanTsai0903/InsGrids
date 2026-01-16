import SwiftUI

// MARK: - Canvas Element Types

/// Unified model for all canvas element types (images, text, stickers)
/// Provides type-safe element handling with shared transform properties
enum CanvasElement: Identifiable {
    case image(ImageElement)
    case text(TextElement)
    case sticker(StickerElement)
    
    // MARK: - Unified ID Access
    var id: UUID {
        switch self {
        case .image(let element): return element.id
        case .text(let element): return element.id
        case .sticker(let element): return element.id
        }
    }
    
    // MARK: - Unified Transform Access
    var position: CGPoint {
        get {
            switch self {
            case .image(let element): return element.position
            case .text(let element): return element.position
            case .sticker(let element): return element.position
            }
        }
        set {
            switch self {
            case .image(var element):
                element.position = newValue
                self = .image(element)
            case .text(var element):
                element.position = newValue
                self = .text(element)
            case .sticker(var element):
                element.position = newValue
                self = .sticker(element)
            }
        }
    }
    
    var scale: CGFloat {
        get {
            switch self {
            case .image(let element): return element.scale
            case .text(let element): return element.scale
            case .sticker(let element): return element.scale
            }
        }
        set {
            switch self {
            case .image(var element):
                element.scale = newValue
                self = .image(element)
            case .text(var element):
                element.scale = newValue
                self = .text(element)
            case .sticker(var element):
                element.scale = newValue
                self = .sticker(element)
            }
        }
    }
    
    var rotation: Angle {
        get {
            switch self {
            case .image(let element): return element.rotation
            case .text(let element): return element.rotation
            case .sticker(let element): return element.rotation
            }
        }
        set {
            switch self {
            case .image(var element):
                element.rotation = newValue
                self = .image(element)
            case .text(var element):
                element.rotation = newValue
                self = .text(element)
            case .sticker(var element):
                element.rotation = newValue
                self = .sticker(element)
            }
        }
    }
}

// MARK: - Image Element

/// Wraps image data with transform properties for canvas placement
struct ImageElement: Identifiable {
    var id = UUID()
    var image: UIImage
    var position: CGPoint = .zero
    var scale: CGFloat = 1.0
    var rotation: Angle = .zero
    var adjustments: PhotoAdjustments = PhotoAdjustments()
    
    /// Create from existing CanvasImage for migration
    init(from canvasImage: CanvasImage) {
        self.id = canvasImage.id
        self.image = canvasImage.image
        self.position = canvasImage.position
        self.scale = canvasImage.scale
        self.rotation = canvasImage.rotation
        self.adjustments = canvasImage.adjustments
    }
    
    init(image: UIImage, position: CGPoint = .zero) {
        self.image = image
        self.position = position
    }
}

// MARK: - Text Element

/// Text element with formatting properties for canvas placement
struct TextElement: Identifiable {
    var id = UUID()
    var text: String
    var font: String = "SF Pro Text"
    var fontSize: CGFloat = 24
    var color: Color = .black
    var alignment: TextAlignment = .center
    var backgroundColor: Color? = nil
    var backgroundOpacity: Double = 1.0
    
    // Transform properties
    var position: CGPoint = .zero
    var scale: CGFloat = 1.0
    var rotation: Angle = .zero
    
    /// Available system fonts
    static let availableFonts: [String] = [
        "SF Pro Text",
        "Helvetica Neue",
        "Georgia",
        "Courier New",
        "Times New Roman",
        "Arial",
        "Menlo",
        // Custom Fonts - CJK
        "CactusClassicalSerif-Regular",
        "ChocolateClassicalSans-Regular",
        "ChironHeiHK-Regular",
        "ChironSungHK-Regular",
        "ChironGoRoundTC-Regular",
        "LXGWWenKaiTC-Regular",
        "LXGWWenKaiMonoTC-Regular",
        "LXGWWenKaiTC-Bold",
        "LXGWWenKaiMonoTC-Bold"
    ]
    
    /// Create default text element
    static func createDefault(at position: CGPoint) -> TextElement {
        TextElement(
            text: NSLocalizedString("Double tap to edit", comment: "Default text for new text element"),
            position: position
        )
    }
}

// MARK: - Sticker Element

/// Sticker type - emoji or SF Symbol
enum StickerType: String, Codable {
    case emoji
    case sfSymbol
}

/// Sticker element (emoji or SF Symbol) for canvas placement
struct StickerElement: Identifiable {
    var id = UUID()
    var type: StickerType
    var content: String  // Emoji character or SF Symbol name
    var color: Color? = nil  // Only used for SF Symbols
    var size: CGFloat = 64  // Base size before scale
    
    // Transform properties
    var position: CGPoint = .zero
    var scale: CGFloat = 1.0
    var rotation: Angle = .zero
    
    /// Create emoji sticker
    static func emoji(_ emoji: String, at position: CGPoint) -> StickerElement {
        StickerElement(type: .emoji, content: emoji, position: position)
    }
    
    /// Create SF Symbol sticker
    static func sfSymbol(_ name: String, color: Color = .primary, at position: CGPoint) -> StickerElement {
        StickerElement(type: .sfSymbol, content: name, color: color, position: position)
    }
}

// MARK: - Codable Conformance

extension CanvasElement: Codable {
    enum CodingKeys: String, CodingKey {
        case type
        case element
    }
    
    enum ElementType: String, Codable {
        case image
        case text
        case sticker
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ElementType.self, forKey: .type)
        
        switch type {
        case .image:
            // ImageElement decoding handled specially - only metadata saved
            let saved = try container.decode(SavedImageElement.self, forKey: .element)
            // Image data loaded separately by ViewModel
            self = .image(ImageElement(from: saved))
        case .text:
            let element = try container.decode(TextElement.self, forKey: .element)
            self = .text(element)
        case .sticker:
            let element = try container.decode(StickerElement.self, forKey: .element)
            self = .sticker(element)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .image(let element):
            try container.encode(ElementType.image, forKey: .type)
            try container.encode(SavedImageElement(from: element), forKey: .element)
        case .text(let element):
            try container.encode(ElementType.text, forKey: .type)
            try container.encode(element, forKey: .element)
        case .sticker(let element):
            try container.encode(ElementType.sticker, forKey: .type)
            try container.encode(element, forKey: .element)
        }
    }
}

// MARK: - Saved Image Element (Metadata only)

/// Codable metadata for ImageElement - image binary saved separately
struct SavedImageElement: Codable {
    let id: UUID
    let positionX: CGFloat
    let positionY: CGFloat
    let scale: CGFloat
    let rotationDegrees: Double
    let adjustments: PhotoAdjustments
    
    init(from element: ImageElement) {
        self.id = element.id
        self.positionX = element.position.x
        self.positionY = element.position.y
        self.scale = element.scale
        self.rotationDegrees = element.rotation.degrees
        self.adjustments = element.adjustments
    }
}

extension ImageElement {
    init(from saved: SavedImageElement) {
        self.id = saved.id
        self.image = UIImage()  // Placeholder - loaded by ViewModel
        self.position = CGPoint(x: saved.positionX, y: saved.positionY)
        self.scale = saved.scale
        self.rotation = Angle(degrees: saved.rotationDegrees)
        self.adjustments = saved.adjustments
    }
}

// MARK: - TextElement Codable

extension TextElement: Codable {
    enum CodingKeys: String, CodingKey {
        case id, text, font, fontSize, color, alignmentString
        case backgroundColor, backgroundOpacity
        case positionX, positionY, scale, rotationDegrees
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
        font = try container.decode(String.self, forKey: .font)
        fontSize = try container.decode(CGFloat.self, forKey: .fontSize)
        backgroundOpacity = try container.decode(Double.self, forKey: .backgroundOpacity)
        
        // Decode alignment from string
        let alignmentStr = try container.decode(String.self, forKey: .alignmentString)
        switch alignmentStr {
        case "leading": alignment = .leading
        case "center": alignment = .center
        case "trailing": alignment = .trailing
        default: alignment = .center
        }
        
        // Decode position
        let posX = try container.decode(CGFloat.self, forKey: .positionX)
        let posY = try container.decode(CGFloat.self, forKey: .positionY)
        position = CGPoint(x: posX, y: posY)
        scale = try container.decode(CGFloat.self, forKey: .scale)
        let rotDegrees = try container.decode(Double.self, forKey: .rotationDegrees)
        rotation = Angle(degrees: rotDegrees)
        
        // Decode colors using UIColor archiver
        let colorData = try container.decode(Data.self, forKey: .color)
        if let uiColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
            color = Color(uiColor)
        } else {
            color = .black
        }
        
        if let bgData = try container.decodeIfPresent(Data.self, forKey: .backgroundColor),
           let uiColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: bgData) {
            backgroundColor = Color(uiColor)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encode(font, forKey: .font)
        try container.encode(fontSize, forKey: .fontSize)
        try container.encode(backgroundOpacity, forKey: .backgroundOpacity)
        
        // Encode alignment as string
        let alignmentStr: String
        switch alignment {
        case .leading: alignmentStr = "leading"
        case .center: alignmentStr = "center"
        case .trailing: alignmentStr = "trailing"
        }
        try container.encode(alignmentStr, forKey: .alignmentString)
        
        // Encode position
        try container.encode(position.x, forKey: .positionX)
        try container.encode(position.y, forKey: .positionY)
        try container.encode(scale, forKey: .scale)
        try container.encode(rotation.degrees, forKey: .rotationDegrees)
        
        // Encode colors
        let colorData = try NSKeyedArchiver.archivedData(withRootObject: UIColor(color), requiringSecureCoding: false)
        try container.encode(colorData, forKey: .color)
        
        if let bgColor = backgroundColor {
            let bgData = try NSKeyedArchiver.archivedData(withRootObject: UIColor(bgColor), requiringSecureCoding: false)
            try container.encode(bgData, forKey: .backgroundColor)
        }
    }
}

// MARK: - StickerElement Codable

extension StickerElement: Codable {
    enum CodingKeys: String, CodingKey {
        case id, type, content, color, size
        case positionX, positionY, scale, rotationDegrees
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        type = try container.decode(StickerType.self, forKey: .type)
        content = try container.decode(String.self, forKey: .content)
        size = try container.decode(CGFloat.self, forKey: .size)
        
        // Decode position
        let posX = try container.decode(CGFloat.self, forKey: .positionX)
        let posY = try container.decode(CGFloat.self, forKey: .positionY)
        position = CGPoint(x: posX, y: posY)
        scale = try container.decode(CGFloat.self, forKey: .scale)
        let rotDegrees = try container.decode(Double.self, forKey: .rotationDegrees)
        rotation = Angle(degrees: rotDegrees)
        
        // Decode optional color
        if let colorData = try container.decodeIfPresent(Data.self, forKey: .color),
           let uiColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
            color = Color(uiColor)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(content, forKey: .content)
        try container.encode(size, forKey: .size)
        
        // Encode position
        try container.encode(position.x, forKey: .positionX)
        try container.encode(position.y, forKey: .positionY)
        try container.encode(scale, forKey: .scale)
        try container.encode(rotation.degrees, forKey: .rotationDegrees)
        
        // Encode optional color
        if let stickerColor = color {
            let colorData = try NSKeyedArchiver.archivedData(withRootObject: UIColor(stickerColor), requiringSecureCoding: false)
            try container.encode(colorData, forKey: .color)
        }
    }
}
