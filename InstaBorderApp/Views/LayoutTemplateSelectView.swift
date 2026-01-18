import SwiftUI
import PhotosUI

/// Wrapper to pass template + images to editor
private struct EditorData: Identifiable {
    let id = UUID()
    let template: LayoutTemplate
    let images: [UIImage]
}

struct LayoutTemplateSelectView: View {
    @State private var pickerTemplate: LayoutTemplate?
    @State private var editorData: EditorData?
    @State private var selectedFilter: Int? = nil // nil = "All", otherwise slot count
    @State private var showCustomGridSheet = false

    @Environment(\.dismiss) var dismiss

    private let groupedTemplates: [(slotCount: Int, templates: [LayoutTemplate])] = {
        let grouped = Dictionary(grouping: LayoutTemplate.allTemplates, by: { $0.slotCount })
        return grouped.sorted(by: { $0.key < $1.key }).map { (slotCount: $0.key, templates: $0.value) }
    }()

    private var filteredTemplates: [(slotCount: Int, templates: [LayoutTemplate])] {
        if let filter = selectedFilter {
            return groupedTemplates.filter { $0.slotCount == filter }
        }
        return groupedTemplates
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                    }
                    Spacer()
                    Text(NSLocalizedString("layout.selectTemplate", comment: "Select Template"))
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 12)
                .padding(.top, 4)
                .padding(.bottom, 8)

                // Filter Bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        // "All" button
                        FilterButton(
                            title: NSLocalizedString("layout.filter.all", comment: "All"),
                            isSelected: selectedFilter == nil,
                            action: { selectedFilter = nil }
                        )

                        // Number buttons (1-6)
                        ForEach(1...6, id: \.self) { count in
                            FilterButton(
                                title: "\(count)",
                                isSelected: selectedFilter == count,
                                action: { selectedFilter = count }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 12)

                // Template List
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Custom Grid Card (always visible at top)
                        VStack(alignment: .leading, spacing: 12) {
                            Text(NSLocalizedString("customGrid.section", comment: "Custom"))
                                .font(.headline)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 20)
                            
                            CustomGridCard()
                                .padding(.horizontal, 20)
                                .onTapGesture {
                                    showCustomGridSheet = true
                                }
                        }
                        
                        // Predefined Templates
                        ForEach(filteredTemplates, id: \.slotCount) { group in
                            VStack(alignment: .leading, spacing: 12) {
                                Text("\(group.slotCount) Photos")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 20)

                                LazyVGrid(columns: [
                                    GridItem(.flexible(), spacing: 12),
                                    GridItem(.flexible(), spacing: 12),
                                    GridItem(.flexible(), spacing: 12)
                                ], spacing: 12) {
                                    ForEach(group.templates) { template in
                                        TemplatePreviewCard(template: template)
                                            .onTapGesture {
                                                pickerTemplate = template
                                            }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    .padding(.vertical, 20)
                }
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(item: $pickerTemplate) { template in
            LayoutPhotoPickerView(
                requiredCount: template.slotCount,
                templateName: template.name,
                onConfirm: { images in
                    let data = EditorData(template: template, images: images)
                    pickerTemplate = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        editorData = data
                    }
                },
                onCancel: {
                    pickerTemplate = nil
                }
            )
        }
        .fullScreenCover(item: $editorData) { data in
            LayoutEditorView(template: data.template, images: data.images)
        }
        .sheet(isPresented: $showCustomGridSheet) {
            NavigationView {
                CustomGridInputSheet(isPresented: $showCustomGridSheet) { template in
                    pickerTemplate = template
                }
            }
        }
    }
}

struct CustomGridCard: View {
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Color.gray.opacity(0.2)
                
                VStack(spacing: 8) {
                    Image(systemName: "square.grid.3x3")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.blue)
                    
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.blue)
                }
            }
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.blue.opacity(0.5), lineWidth: 2)
            )
            
            Text(NSLocalizedString("template.customGrid", comment: "Custom Grid"))
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 100)
        }
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.3))
                .clipShape(Capsule())
        }
    }
}

struct TemplatePreviewCard: View {
    let template: LayoutTemplate
    
    var body: some View {
        GeometryReader { geometry in
            let size = CGSize(width: geometry.size.width, height: geometry.size.height)
            
            ZStack {
                Color.gray.opacity(0.2)
                
                ForEach(0..<template.slots.count, id: \.self) { index in
                    let shape = template.slots[index].path(in: size, inset: 2, cornerRadius: 4)
                    shape
                        .stroke(Color.white, lineWidth: 1.5)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .frame(width: 100, height: 100)
    }
}
