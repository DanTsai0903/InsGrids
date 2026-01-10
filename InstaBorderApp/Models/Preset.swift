import SwiftUI

struct Preset: Identifiable, Codable {
    var id = UUID()
    var name: String
    var configuration: BorderConfiguration
    var createdAt: Date = Date()
}
