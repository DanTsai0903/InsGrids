import SwiftUI
import PhotosUI

struct ContentView: View {
    @StateObject private var viewModel = PhotoEditorViewModel()
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var showEditor = false
    
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
                    
                    // Logo - Use Logo image set (same as App Icon)
                    VStack(spacing: 20) {
                        Image("Logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 22))
                        
                        Text("InsGrids")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .tracking(1)
                        
                        Text("為您的照片打造完美比例")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .tracking(0.5)
                    }
                    
                    Spacer()
                    
                    // Main Action Button
                    PhotosPicker(selection: $selectedItems, matching: .images, photoLibrary: .shared()) {
                        HStack(spacing: 12) {
                            Image(systemName: "plus")
                                .font(.headline)
                            Text("選擇照片")
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
                    
                    // Footer
                    Text("支援多張選取 • 智慧對齊")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.3))
                        .padding(.bottom, 40)
                }
                .padding()
            }
            .navigationDestination(isPresented: $showEditor) {
                EditingView(viewModel: viewModel)
            }
        }
    }
    
    private func loadImages(from items: [PhotosPickerItem]) {
        guard !items.isEmpty else { return }
        
        Task {
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
                    selectedItems = [] 
                }
            }
        }
    }
}
