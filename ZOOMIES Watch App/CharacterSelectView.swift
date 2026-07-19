import SwiftUI

struct CharacterSelectView: View {
    @Binding var screen: GameScreen
    @Binding var selectedCharacter: String
    @Binding var selectedMap: String
    @AppStorage("unlockedCharacters") private var unlocked = CharacterType.allCases.map(\.rawValue).joined(separator: ",")

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    screen = .home
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline.bold())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Back")
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.top, 3)

            List {
                Section {
                    ForEach(CharacterType.allCases) { character in
                        let isUnlocked = unlocked.split(separator: ",").contains(Substring(character.rawValue))
                        Button {
                            guard isUnlocked else { return }
                            selectedCharacter = character.rawValue
                            screen = .home
                        } label: {
                            HStack(spacing: 8) {
                                CharacterBadge(character: character, size: 38)
                                Text(character.name)
                                    .bold()
                                Spacer()
                                if selectedCharacter == character.rawValue {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                }
                                if !isUnlocked { Image(systemName: "lock.fill") }
                            }
                        }
                    }
                }
            }
        }
    }
}
