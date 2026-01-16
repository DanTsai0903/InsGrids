import SwiftUI

/// Emoji picker component for adding emoji to grid cells
struct EmojiPickerView: View {
    var onSelect: (String) -> Void
    var onClear: () -> Void
    @Environment(\.dismiss) var dismiss
    
    // Popular emoji categories
    private let emojis: [(String, [String])] = [
        ("😀", ["😀", "😃", "😄", "😁", "😅", "😂", "🤣", "😊", "😇", "🥰", "😍", "🤩", "😘", "😗", "😚", "😋", "😛", "😜", "🤪", "😎"]),
        ("❤️", ["❤️", "🧡", "💛", "💚", "💙", "💜", "🖤", "🤍", "🤎", "💔", "❣️", "💕", "💞", "💓", "💗", "💖", "💝", "💘", "💌", "🫶"]),
        ("🎉", ["🎉", "🎊", "🎈", "🎁", "🎀", "🪅", "🎄", "🎃", "🎆", "🎇", "✨", "🎵", "🎶", "🎤", "🎧", "🎼", "🎹", "🥁", "🎸", "🎺"]),
        ("⭐", ["⭐", "🌟", "💫", "✨", "🔥", "💥", "💯", "🏆", "🥇", "🥈", "🥉", "🎖️", "🏅", "👑", "💎", "🔮", "🌈", "☀️", "🌙", "⚡"]),
        ("👍", ["👍", "👎", "👏", "🙌", "🤝", "👋", "✌️", "🤞", "🤟", "🤘", "🤙", "💪", "🙏", "👆", "👇", "👈", "👉", "☝️", "✋", "🤚"]),
        ("🍕", ["🍕", "🍔", "🍟", "🌭", "🍿", "🧁", "🍰", "🎂", "🍩", "🍪", "🍫", "🍬", "🍭", "🍮", "☕", "🍵", "🧋", "🥤", "🍺", "🍷"]),
        ("🐱", ["🐱", "🐶", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐨", "🐯", "🦁", "🐮", "🐷", "🐸", "🐵", "🦄", "🐝", "🦋", "🐢", "🐬"]),
        ("🌸", ["🌸", "🌺", "🌷", "🌹", "🥀", "🌻", "🌼", "💐", "🌿", "🍀", "🍁", "🍂", "🌴", "🌵", "🎍", "🎋", "🌱", "🪴", "🎄", "🌲"])
    ]
    
    @State private var selectedCategory = 0
    
    var body: some View {
        VStack(spacing: 16) {
            // Title with clear button
            HStack {
                Text(NSLocalizedString("emoji.picker.title", comment: "Add Emoji"))
                    .font(.headline)
                
                Spacer()
                
                Button {
                    onClear()
                    // Parent controls dismissal
                } label: {
                    Text(NSLocalizedString("emoji.picker.clear", comment: "Clear"))
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            // Category tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(0..<emojis.count, id: \.self) { index in
                        Button {
                            selectedCategory = index
                        } label: {
                            Text(emojis[index].0)
                                .font(.title)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedCategory == index ? Color.blue.opacity(0.2) : Color.clear)
                                )
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Emoji grid
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                    ForEach(emojis[selectedCategory].1, id: \.self) { emoji in
                        Button {
                            onSelect(emoji)
                            // Parent controls dismissal
                        } label: {
                            Text(emoji)
                                .font(.system(size: 36))
                                .frame(width: 50, height: 50)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
    }
}
