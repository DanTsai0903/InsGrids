import SwiftUI

/// Sticker picker view with Icon and Sticker tabs
struct StickerPickerView: View {
    var onSelect: (StickerElement) -> Void
    var canvasCenter: CGPoint
    var onDismiss: (() -> Void)? = nil
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedTab = 0
    @State private var searchText = ""
    @State private var selectedColor: Color = .primary
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab selector
                Picker("", selection: $selectedTab) {
                    Text(NSLocalizedString("Icon", comment: "Icon tab")).tag(0)
                    Text(NSLocalizedString("Sticker", comment: "Sticker tab")).tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Content based on selected tab
                if selectedTab == 0 {
                    iconTab
                } else {
                    stickerTab
                }
            }
            .navigationTitle(NSLocalizedString("Add Sticker", comment: "Sticker picker title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("Cancel", comment: "Cancel button")) {
                        if let onDismiss = onDismiss {
                            onDismiss()
                        } else {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Icon Tab (SF Symbols)
    
    private var iconTab: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField(NSLocalizedString("Search Stickers", comment: "Search stickers placeholder"), text: $searchText)
                    .textFieldStyle(.plain)
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.bottom, 8)
            
            // Color picker for SF Symbols
            HStack {
                Text(NSLocalizedString("Color", comment: "Color label"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                ColorPicker("", selection: $selectedColor)
                    .labelsHidden()
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            
            // Symbol grid
            ScrollView {
                if searchText.isEmpty {
                    // Show categories
                    ForEach(StickerCategory.allCategories) { category in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(NSLocalizedString(category.localizedKey, comment: category.name))
                                .font(.headline)
                                .padding(.horizontal)
                            
                            symbolGrid(symbols: category.symbols)
                        }
                        .padding(.vertical, 8)
                    }
                } else {
                    // Show search results
                    let results = StickerCategory.searchSymbols(searchText)
                    if results.isEmpty {
                        Text(NSLocalizedString("No results", comment: "No search results"))
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        symbolGrid(symbols: results)
                            .padding()
                    }
                }
            }
        }
    }
    
    // MARK: - Sticker Tab (Custom Stickers)
    
    private var stickerTab: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField(NSLocalizedString("Search Stickers", comment: "Search stickers placeholder"), text: $searchText)
                    .textFieldStyle(.plain)
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.bottom, 8)
            
            // Sticker grid
            ScrollView {
                if searchText.isEmpty {
                    // Show categories or placeholder
                    if CustomStickerCategory.allCategories.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)
                            Text(NSLocalizedString("sticker.comingSoon", comment: "Custom stickers coming soon"))
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                    } else {
                        ForEach(CustomStickerCategory.allCategories) { category in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(category.name.capitalized)
                                    .font(.headline)
                                    .padding(.horizontal)
                                                                customStickerGrid(stickers: category.stickers)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                } else {
                    // Show search results
                    let results = CustomStickerCategory.searchStickers(searchText)
                    if results.isEmpty {
                        Text(NSLocalizedString("No results", comment: "No search results"))
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        customStickerGrid(stickers: results)
                            .padding()
                    }
                }
            }
        }
    }
    
    private func customStickerGrid(stickers: [CustomSticker]) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
            ForEach(stickers) { sticker in
                Button {
                    let stickerElement = StickerElement.customSticker(sticker.name, at: canvasCenter)
                    onSelect(stickerElement)
                    // Parent controls dismissal
                } label: {
                    Image(sticker.name)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func symbolGrid(symbols: [String]) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
            ForEach(symbols, id: \.self) { symbol in
                Button {
                    let sticker = StickerElement.sfSymbol(symbol, color: selectedColor, at: canvasCenter)
                    onSelect(sticker)
                    // Parent controls dismissal
                } label: {
                    Image(systemName: symbol)
                        .font(.system(size: 28))
                        .foregroundColor(selectedColor)
                        .frame(width: 50, height: 50)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal)
    }
}
