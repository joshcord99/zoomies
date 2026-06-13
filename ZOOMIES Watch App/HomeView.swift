import SwiftUI

struct HomeView: View {
    @Binding var screen: GameScreen
    @AppStorage("bestDistance") private var bestDistance = 0.0
    @AppStorage("totalCoins") private var totalCoins = 0
    @AppStorage("yoloMode") private var yoloMode = false
    @AppStorage("selectedCharacter") private var selectedCharacter = CharacterType.cappi.rawValue
    @AppStorage("distanceUnit") private var distanceUnit = DistanceUnit.metric.rawValue

    private var character: CharacterType {
        CharacterType(rawValue: selectedCharacter) ?? .cappi
    }

    private var units: DistanceUnit {
        DistanceUnit(rawValue: distanceUnit) ?? .metric
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 7) {
                VStack(spacing: 3) {
                    HomeMascot(character: character)
                    Text(character.name)
                        .font(.caption.bold())
                        .foregroundStyle(character.color)
                }

                Button {
                    screen = .playing
                } label: {
                    Label(yoloMode ? "PLAY YOLO" : "PLAY", systemImage: "play.fill")
                        .font(.headline)
                }
                .tint(yoloMode ? .red : .green)

                HStack(spacing: 5) {
                    MiniNavButton(title: "", icon: "pawprint.fill") { screen = .characters }
                    MiniNavButton(title: "", icon: "map.fill") { screen = .maps }
                    MiniNavButton(title: "", icon: "gearshape.fill") { screen = .settings }
                }

                HStack {
                    Label(units.format(meters: bestDistance), systemImage: "flag.checkered")
                    Spacer()
                    Label("\(totalCoins)", systemImage: "circle.fill")
                        .foregroundStyle(.yellow)
                }
                .font(.caption2.bold())
                .padding(.horizontal, 4)
            }
            .padding(.horizontal, 5)
        }
    }
}

private struct HomeMascot: View {
    let character: CharacterType

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let cycle = time.truncatingRemainder(dividingBy: 4.0)
            let bounce = abs(sin(time * 3.2)) * -7
            let wiggle = sin(time * 4.5) * 7
            let trickProgress = max(0, min(1, (cycle - 2.3) / 0.9))
            let trickAngle = trickProgress * 360

            ZStack {
                ForEach(0..<3, id: \.self) { index in
                    Image(systemName: "sparkles")
                        .font(.system(size: 12))
                        .foregroundStyle(index.isMultiple(of: 2) ? .yellow : .cyan)
                        .offset(
                            x: cos(time * 2 + Double(index) * 2.1) * 48,
                            y: sin(time * 2 + Double(index) * 2.1) * 28
                        )
                        .opacity(0.55 + sin(time * 4 + Double(index)) * 0.35)
                }

                CharacterBadge(character: character, size: 72, running: true)
                    .rotationEffect(.degrees(wiggle + trickAngle))
                    .rotation3DEffect(
                        .degrees(cycle > 1.0 && cycle < 1.8 ? sin((cycle - 1) * .pi / 0.8) * 360 : 0),
                        axis: (x: 0, y: 1, z: 0)
                    )
                    .scaleEffect(1 + sin(time * 3.2) * 0.035)
                    .offset(y: bounce)
                    .shadow(color: character.color.opacity(0.7), radius: 8, y: 5)
            }
            .frame(height: 82)
        }
    }
}

private struct MiniNavButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                if !title.isEmpty {
                    Text(title).font(.system(size: 9, weight: .bold))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.roundedRectangle(radius: 10))
    }
}
