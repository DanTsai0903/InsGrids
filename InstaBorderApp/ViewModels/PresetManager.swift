import SwiftUI
import Combine

class PresetManager: ObservableObject {
    @Published var presets: [Preset] = []
    
    private let userDefaultsKey = "savedPresets"
    
    init() {
        loadPresets()
    }
    
    func loadPresets() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey) {
            if let decoded = try? JSONDecoder().decode([Preset].self, from: data) {
                self.presets = decoded.sorted(by: { $0.createdAt > $1.createdAt })
                return
            }
        }
        self.presets = []
    }
    
    func savePreset(name: String, config: BorderConfiguration) {
        let newPreset = Preset(name: name, configuration: config)
        presets.insert(newPreset, at: 0)
        persist()
    }
    
    func deletePreset(_ preset: Preset) {
        if let index = presets.firstIndex(where: { $0.id == preset.id }) {
            presets.remove(at: index)
            persist()
        }
    }
    
    private func persist() {
        if let encoded = try? JSONEncoder().encode(presets) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
}
