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

    @Environment(\.dismiss) var dismiss

    private let groupedTemplates: [(slotCount: Int, templates: [LayoutTemplate])] = {
        let grouped = Dictionary(grouping: LayoutTemplate.allTemplates, by: { $0.slotCount })
        return grouped.sorted(by: { $0.key < $1.key }).map { (slotCount: $0.key, templates: $0.value) }
    }()

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

                // Template List
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        ForEach(groupedTemplates, id: \.slotCount) { group in
                            VStack(alignment: .leading, spacing: 12) {
                                Text("\(group.slotCount) Photos")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 20)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
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
