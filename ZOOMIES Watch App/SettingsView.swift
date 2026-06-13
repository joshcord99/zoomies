import SwiftUI

struct SettingsView: View {
    @Binding var screen: GameScreen
    @AppStorage("selectedControlMode") private var controlMode = ControlMode.screenButton.rawValue
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true
    @AppStorage("yoloMode") private var yoloMode = false
    @AppStorage("yoloBestDistance") private var yoloBestDistance = 0.0
    @AppStorage("distanceUnit") private var distanceUnit = DistanceUnit.metric.rawValue
    @State private var showingStats = false

    private var units: DistanceUnit {
        DistanceUnit(rawValue: distanceUnit) ?? .metric
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    if showingStats {
                        showingStats = false
                    } else {
                        screen = .home
                    }
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

            if showingStats {
                CharacterStatsView()
            } else {
                Form {
                    Section("Jump Control") {
                        Picker("Control", selection: $controlMode) {
                            ForEach(ControlMode.allCases) { mode in
                                Text(mode.title).tag(mode.rawValue)
                            }
                        }
                    }
                    Section("Game") {
                        Picker("Distance Units", selection: $distanceUnit) {
                            ForEach(DistanceUnit.allCases) { unit in
                                Text(unit.title).tag(unit.rawValue)
                            }
                        }
                        Toggle("Sound", isOn: $soundEnabled)
                        Toggle("Haptics", isOn: $hapticsEnabled)
                        Toggle("YOLO Mode", isOn: $yoloMode)
                        if yoloMode {
                            Text("One hit • 2× score • best \(units.format(meters: yoloBestDistance))")
                                .font(.caption2)
                                .foregroundStyle(.red)
                        }
                    }
                    Section {
                        Button {
                            showingStats = true
                        } label: {
                            Label("Character Stats", systemImage: "chart.bar.fill")
                        }
                    }
                }
                .padding(.top, 10)
            }
        }
    }
}

private struct CharacterStatsView: View {
    @AppStorage("distanceUnit") private var distanceUnit = DistanceUnit.metric.rawValue

    private var units: DistanceUnit {
        DistanceUnit(rawValue: distanceUnit) ?? .metric
    }

    var body: some View {
        List {
            Section("Farthest Distance") {
                ForEach(CharacterType.allCases) { character in
                    HStack(spacing: 8) {
                        CharacterBadge(character: character, size: 30)
                        Text(character.name)
                            .bold()
                        Spacer()
                        Text(units.format(meters: PersistenceManager.characterBest(for: character)))
                            .font(.caption.bold())
                            .foregroundStyle(.green)
                    }
                }
            }
        }
        .padding(.top, 6)
    }
}
