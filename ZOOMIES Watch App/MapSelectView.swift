import SwiftUI

struct MapSelectView: View {
    @Binding var screen: GameScreen
    @Binding var selectedMap: String
    @Binding var selectedCharacter: String

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
                        Button {
                            selectedMap = map.rawValue
                            screen = .home
                        } label: {
                            HStack {
                                Image(systemName: map.propSymbol)
                                    .frame(width: 30, height: 30)
                                    .background(map.sky.gradient, in: Circle())
                                VStack(alignment: .leading) {
                                    Text(map.name).bold()
                                }
                                Spacer()
                                Image(systemName: selectedMap == map.rawValue ? "checkmark.circle.fill" : "chevron.right")
                                    .foregroundStyle(selectedMap == map.rawValue ? .green : .secondary)
                            }
                        }
                    }
                }
            }
        }
    }
}
