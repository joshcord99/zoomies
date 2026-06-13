import SwiftUI

struct MapSelectView: View {
    @Binding var screen: GameScreen
    @Binding var selectedMap: String
    @Binding var selectedCharacter: String

    private var character: CharacterType {
        CharacterType(rawValue: selectedCharacter) ?? .cappi
    }

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
                    ForEach(MapType.allCases, id: \.self) { map in
                        let isCompatible = map.supports(character)
                        Button {
                            guard isCompatible else { return }
                            selectedMap = map.rawValue
                            screen = .home
                        } label: {
                            HStack {
                                Image(systemName: map.propSymbol)
                                    .frame(width: 30, height: 30)
                                    .background(map.sky.gradient, in: Circle())
                                VStack(alignment: .leading) {
                                    Text(map.name).bold()
                                    Text("Playable: \(map.compatibilityLabel)")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: isCompatible ? (selectedMap == map.rawValue ? "checkmark.circle.fill" : "chevron.right") : "lock.fill")
                                    .foregroundStyle(selectedMap == map.rawValue ? .green : .secondary)
                            }
                        }
                        .disabled(!isCompatible)
                    }
                }
            }
        }
    }
}
