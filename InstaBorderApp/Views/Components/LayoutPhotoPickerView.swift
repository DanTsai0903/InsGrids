import SwiftUI
import Photos

/// Custom photo picker for layout that shows selection order and allows duplicates
struct LayoutPhotoPickerView: View {
    let requiredCount: Int
    let templateName: String
    let onConfirm: ([UIImage]) -> Void
    let onCancel: () -> Void

    @State private var selectedAssets: [PHAsset] = []
    @State private var allAssets: PHFetchResult<PHAsset>?
    @State private var thumbnails: [String: UIImage] = [:]
    @State private var isLoading = false

    private let imageManager = PHCachingImageManager()
    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                headerView

                // Photo Grid
                if let assets = allAssets {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 2) {
                            ForEach(0..<assets.count, id: \.self) { index in
                                let asset = assets.object(at: index)
                                PhotoGridCell(
                                    asset: asset,
                                    thumbnail: thumbnails[asset.localIdentifier],
                                    selectionIndices: indicesFor(asset: asset)
                                )
                                .onTapGesture {
                                    selectAsset(asset)
                                }
                            }
                        }
                    }
                } else {
                    Spacer()
                    ProgressView()
                        .tint(.white)
                    Text(NSLocalizedString("status.loading", comment: "Loading..."))
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                    Spacer()
                }
            }

            // Loading overlay
            if isLoading {
                Color.black.opacity(0.7).ignoresSafeArea()
                VStack(spacing: 12) {
                    ProgressView().tint(.white).scaleEffect(1.5)
                    Text(NSLocalizedString("status.icloudDownload", comment: ""))
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            requestAccess()
        }
    }

    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                }

                Spacer()

                VStack(spacing: 2) {
                    Text("Select \(requiredCount) Photos")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                    Text(templateName)
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                Button(action: confirmSelection) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(canConfirm ? .white : .gray)
                        .frame(width: 44, height: 44)
                }
                .disabled(!canConfirm)
            }
            .padding(.horizontal, 8)

            // Selection counter
            HStack {
                Text("\(selectedAssets.count) / \(requiredCount)")
                    .font(.subheadline.bold())
                    .foregroundColor(canConfirm ? .blue : .gray)

                if selectedAssets.count > 0 {
                    Button(action: clearSelection) {
                        Text("Clear")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    .padding(.leading, 8)
                }
            }
            .padding(.bottom, 8)
        }
        .background(Color.black)
    }

    private var canConfirm: Bool {
        selectedAssets.count == requiredCount
    }

    private func indicesFor(asset: PHAsset) -> [Int] {
        selectedAssets.enumerated()
            .filter { $0.element.localIdentifier == asset.localIdentifier }
            .map { $0.offset + 1 }
    }

    private func selectAsset(_ asset: PHAsset) {
        if selectedAssets.count < requiredCount {
            selectedAssets.append(asset)
        }
    }

    private func clearSelection() {
        selectedAssets.removeAll()
    }

    private func requestAccess() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                if status == .authorized || status == .limited {
                    fetchPhotos()
                }
            }
        }
    }

    private func fetchPhotos() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        allAssets = PHAsset.fetchAssets(with: .image, options: options)

        // Pre-fetch thumbnails for visible photos
        if let assets = allAssets {
            let targetSize = CGSize(width: 200, height: 200)
            let options = PHImageRequestOptions()
            options.deliveryMode = .opportunistic
            options.isNetworkAccessAllowed = true

            for i in 0..<min(100, assets.count) {
                let asset = assets.object(at: i)
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { image, _ in
                    if let image = image {
                        DispatchQueue.main.async {
                            thumbnails[asset.localIdentifier] = image
                        }
                    }
                }
            }
        }
    }

    private func confirmSelection() {
        guard canConfirm else { return }

        isLoading = true

        Task {
            var images: [UIImage] = []

            for asset in selectedAssets {
                if let image = await loadHighResImage(for: asset) {
                    images.append(image)
                }
            }

            await MainActor.run {
                isLoading = false
                if images.count == requiredCount {
                    onConfirm(images)
                }
            }
        }
    }

    private func loadHighResImage(for asset: PHAsset) async -> UIImage? {
        await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            options.isSynchronous = false

            var hasResumed = false

            imageManager.requestImage(
                for: asset,
                targetSize: PHImageManagerMaximumSize,
                contentMode: .aspectFit,
                options: options
            ) { image, info in
                // Only resume once with the final image
                let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
                if !isDegraded && !hasResumed {
                    hasResumed = true
                    continuation.resume(returning: image)
                }
            }
        }
    }
}

struct PhotoGridCell: View {
    let asset: PHAsset
    let thumbnail: UIImage?
    let selectionIndices: [Int]

    @State private var loadedThumbnail: UIImage?

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topTrailing) {
                // Photo thumbnail
                if let image = thumbnail ?? loadedThumbnail {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.width)
                        .clipped()
                } else {
                    Color.gray.opacity(0.3)
                        .onAppear { loadThumbnail() }
                }

                // Selection badges
                if !selectionIndices.isEmpty {
                    // Dim overlay
                    Color.black.opacity(0.3)

                    // Multiple badges for duplicate selections
                    HStack(spacing: 4) {
                        ForEach(selectionIndices, id: \.self) { index in
                            Text("\(index)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 24, height: 24)
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                    }
                    .padding(4)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func loadThumbnail() {
        let manager = PHCachingImageManager()
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true

        manager.requestImage(
            for: asset,
            targetSize: CGSize(width: 200, height: 200),
            contentMode: .aspectFill,
            options: options
        ) { image, _ in
            if let image = image {
                DispatchQueue.main.async {
                    loadedThumbnail = image
                }
            }
        }
    }
}
