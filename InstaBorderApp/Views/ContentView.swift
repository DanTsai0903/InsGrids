import SwiftUI
import PhotosUI

struct ContentView: View {
    @StateObject private var viewModel = PhotoEditorViewModel()
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var showEditor = false
    @State private var isLoadingPhotos = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // iOS 26 Liquid Glass Background
                ThemeColors.background.ignoresSafeArea()

                // Subtle gradient accent with material
                VStack {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.2), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 300)
                        .ignoresSafeArea()
                    Spacer()
                }
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Logo
                    VStack(spacing: 20) {
                        Image("Logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 22))
                        
                        Text(NSLocalizedString("app.title", comment: ""))
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .tracking(1)
                        
                        Text(NSLocalizedString("app.tagline", comment: ""))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .tracking(0.5)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.5)
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    // Main Action Button
                    PhotosPicker(selection: $selectedItems, matching: .images, photoLibrary: .shared()) {
                        HStack(spacing: 12) {
                            Image(systemName: "square.dashed")
                            Text(NSLocalizedString("button.selectPhotos", comment: ""))
                        }
                    }
                    .buttonStyle(.glassPrimary)
                    .onChange(of: selectedItems) { _, newItems in
                        loadImages(from: newItems)
                    }

                    // Freeform Grid Button
                    NavigationLink(destination: GridEditingView()) {
                        HStack(spacing: 12) {
                            Image(systemName: "square.grid.3x3")
                            Text(NSLocalizedString("button.freeformGrid", comment: ""))
                        }
                    }
                    .buttonStyle(.glassSecondary)

                    // Layout Button
                    NavigationLink(destination: LayoutTemplateSelectView()) {
                        HStack(spacing: 12) {
                            Image(systemName: "square.grid.2x2")
                            Text(NSLocalizedString("button.layout", comment: ""))
                        }
                    }
                    .buttonStyle(.glassSecondary)
                    
                    // Footer
                    Text(NSLocalizedString("footer.features", comment: ""))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.3))
                        .padding(.bottom, 40)
                }
                .padding()
            }
            .navigationDestination(isPresented: $showEditor) {
                EditingView(viewModel: viewModel)
            }
            .overlay {
                if isLoadingPhotos {
                    ZStack {
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .ignoresSafeArea()
                        VStack(spacing: 12) {
                            ProgressView().tint(.white).scaleEffect(1.3)
                            Text(NSLocalizedString("status.icloudDownload", comment: ""))
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
    }
    
    private func loadImages(from items: [PhotosPickerItem]) {
        guard !items.isEmpty else { return }

        isLoadingPhotos = true

        Task {
            defer {
                Task { @MainActor in
                    isLoadingPhotos = false
                    selectedItems = []
                }
            }

            var loadedImages: [UIImage] = []

            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    loadedImages.append(image)
                }
            }

            if !loadedImages.isEmpty {
                await MainActor.run {
                    viewModel.clearAll()
                    viewModel.addImages(loadedImages)
                    showEditor = true
                }
            }
        }
    }
}
