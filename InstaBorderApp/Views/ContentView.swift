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
                // Premium Dark Background
                Color.black.ignoresSafeArea()
                
                // Subtle gradient accent
                VStack {
                    LinearGradient(
                        colors: [Color.blue.opacity(0.15), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
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
                                .font(.headline)
                            Text(NSLocalizedString("button.selectPhotos", comment: ""))
                                .font(.headline)
                        }
                        .foregroundColor(.black)
                        .frame(width: 220, height: 56)
                        .background(Color.white)
                        .cornerRadius(28)
                        .shadow(color: .white.opacity(0.2), radius: 20, x: 0, y: 10)
                    }
                    .onChange(of: selectedItems) { _, newItems in
                        loadImages(from: newItems)
                    }
                    
                    // Freeform Grid Button
                    NavigationLink(destination: GridEditingView()) {
                        HStack(spacing: 12) {
                            Image(systemName: "square.grid.3x3")
                                .font(.headline)
                            Text(NSLocalizedString("button.freeformGrid", comment: ""))
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(width: 220, height: 56)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(28)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                    }
                    
                    // Layout Button
                    NavigationLink(destination: LayoutTemplateSelectView()) {
                        HStack(spacing: 12) {
                            Image(systemName: "square.grid.2x2")
                                .font(.headline)
                            Text(NSLocalizedString("button.layout", comment: ""))
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(width: 220, height: 56)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(28)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                    }
                    
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
                    Color.black.opacity(0.7).ignoresSafeArea()
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
