import SwiftUI

struct ContentView: View {
    @State private var screen: GameScreen = .home
    @AppStorage("selectedCharacter") private var selectedCharacter = CharacterType.cappi.rawValue
    @AppStorage("selectedMap") private var selectedMap = MapType.meadow.rawValue

    var body: some View {
        Group {
            switch screen {
            case .home:
                HomeView(screen: $screen)
            case .characters:
                CharacterSelectView(
                    screen: $screen,
                    selectedCharacter: $selectedCharacter,
                    selectedMap: $selectedMap
                )
            case .maps:
                MapSelectView(
                    screen: $screen,
                    selectedMap: $selectedMap,
                    selectedCharacter: $selectedCharacter
                )
            case .settings:
                SettingsView(screen: $screen)
            case .playing:
                GameView(
                    screen: $screen,
                    character: CharacterType(rawValue: selectedCharacter) ?? .cappi,
                    map: MapType(rawValue: selectedMap) ?? .meadow
                )
            }
        }
        .animation(.easeInOut(duration: 0.2), value: screen)
    }
}
