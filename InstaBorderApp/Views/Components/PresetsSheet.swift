import SwiftUI

struct PresetsSheet: View {
    @ObservedObject var presetManager: PresetManager
    @Binding var currentConfig: BorderConfiguration
    var onApply: (BorderConfiguration) -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var showingSaveAlert = false
    @State private var newPresetName = ""
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button(action: { showingSaveAlert = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                            Text(NSLocalizedString("presets.saveCurrent", comment: ""))
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Section(header: Text(NSLocalizedString("my.presets", value: "My Presets", comment: ""))) {
                    if presetManager.presets.isEmpty {
                        Text(NSLocalizedString("presets.empty", comment: ""))
                            .foregroundColor(.gray)
                            .italic()
                    } else {
                        ForEach(presetManager.presets) { preset in
                            Button(action: {
                                onApply(preset.configuration)
                                dismiss()
                            }) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(preset.name)
                                            .font(.headline)
                                        Text(formatConfig(preset.configuration))
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    // Preview dot
                                    Circle()
                                        .fill(preset.configuration.borderColor)
                                        .frame(width: 20, height: 20)
                                        .overlay(Circle().stroke(Color.gray, lineWidth: 0.5))
                                }
                            }
                        }
                        .onDelete(perform: deletePreset)
                    }
                }
            }
            .navigationTitle(NSLocalizedString("presets.title", comment: ""))
            .navigationBarItems(trailing: Button(NSLocalizedString("button.done", comment: "")) { dismiss() })
            .alert(NSLocalizedString("presets.save", comment: ""), isPresented: $showingSaveAlert) {
                TextField(NSLocalizedString("presets.name", comment: ""), text: $newPresetName)
                Button(NSLocalizedString("button.cancel", comment: ""), role: .cancel) { }
                Button(NSLocalizedString("button.save", comment: "")) {
                    if !newPresetName.isEmpty {
                        presetManager.savePreset(name: newPresetName, config: currentConfig)
                        newPresetName = ""
                    }
                }
            } message: {
                Text(NSLocalizedString("presets.enterName", comment: ""))
            }
        }
    }
    
    private func deletePreset(at offsets: IndexSet) {
        offsets.map { presetManager.presets[$0] }.forEach(presetManager.deletePreset)
    }
    
    private func formatConfig(_ config: BorderConfiguration) -> String {
        let ratio: String
        if abs(config.aspectRatio - 1.0) < 0.01 { ratio = "1:1" }
        else if abs(config.aspectRatio - 0.8) < 0.01 { ratio = "4:5" }
        else if abs(config.aspectRatio - 16.0/9.0) < 0.01 { ratio = "16:9" }
        else if abs(config.aspectRatio - 9.0/16.0) < 0.01 { ratio = "9:16" }
        else { ratio = String(format: "%.2f", config.aspectRatio) }
        
        return "\(ratio) • \(Int(config.imageScale * 100))%"
    }
}
