import SwiftUI

struct GameView: View {
    @Binding var screen: GameScreen
    let character: CharacterType
    let map: MapType

    @StateObject private var game = GameEngine()
    @State private var crownValue = 0.0
    @AppStorage("selectedControlMode") private var controlMode = ControlMode.screenButton.rawValue
    @AppStorage("bestDistance") private var bestDistance = 0.0
    @AppStorage("yoloBestDistance") private var yoloBestDistance = 0.0
    @AppStorage("totalCoins") private var totalCoins = 0
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true
    @AppStorage("yoloMode") private var yoloMode = false
    @AppStorage("distanceUnit") private var distanceUnit = DistanceUnit.metric.rawValue
    private let controls = ControlManager()

    private var units: DistanceUnit {
        DistanceUnit(rawValue: distanceUnit) ?? .metric
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                BackgroundLayer(map: map, offset: game.worldOffset, size: geometry.size)
                ground(size: geometry.size)
                items(size: geometry.size)
                runner(size: geometry.size)
                hud(size: geometry.size)
                overlays

                if controlMode == ControlMode.screenButton.rawValue, game.phase == .running {
                    Button { jump() } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: GameLayout(size: geometry.size).jumpButtonSize))
                            .foregroundStyle(.white, .green)
                    }
                    .buttonStyle(.plain)
                    .position(
                        x: geometry.size.width - 27,
                        y: GameLayout(size: geometry.size).groundTop - 23
                    )
                }
            }
            .focusable(controlMode == ControlMode.digitalCrown.rawValue)
            .digitalCrownRotation($crownValue, from: -100, through: 100, sensitivity: .high, isContinuous: true)
            .onChange(of: crownValue) { _, value in
                guard controlMode == ControlMode.digitalCrown.rawValue, game.phase == .running else { return }
                controls.crownChanged(to: value) { jump() }
            }
            .onAppear {
                game.configure(character: character, map: map, yolo: yoloMode, sound: soundEnabled, haptics: hapticsEnabled)
                game.start(size: geometry.size)
            }
            .onDisappear { game.stop() }
            .onChange(of: game.phase) { _, phase in
                guard phase == .gameOver, !game.savedResults else { return }
                game.savedResults = true
                totalCoins += game.runCoins
                PersistenceManager.record(distance: game.distance, for: character)
                if yoloMode { yoloBestDistance = max(yoloBestDistance, game.distance) }
                else { bestDistance = max(bestDistance, game.distance) }
            }
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .navigationBar)
    }

    private func ground(size: CGSize) -> some View {
        let layout = GameLayout(size: size)
        return ZStack {
            Rectangle().fill(map.ground.gradient).frame(height: layout.groundHeight)
            if map == .meadow {
                HStack(spacing: 18) {
                    ForEach(0..<14, id: \.self) { index in
                        VStack(spacing: -1) {
                            Capsule().fill(.white.opacity(0.28)).frame(width: 3, height: 9)
                                .rotationEffect(.degrees(index.isMultiple(of: 2) ? -14 : 12))
                            Capsule().fill(.white.opacity(0.18)).frame(width: 2, height: 6)
                                .rotationEffect(.degrees(index.isMultiple(of: 2) ? 16 : -12))
                        }
                    }
                }
                .offset(x: game.worldOffset.truncatingRemainder(dividingBy: 30), y: -3)
            } else if map != .frost && map != .jungle {
                HStack(spacing: 16) {
                    ForEach(0..<14, id: \.self) { _ in
                        Capsule().fill(.white.opacity(0.3)).frame(width: 12, height: 3)
                    }
                }
                .offset(x: game.worldOffset.truncatingRemainder(dividingBy: 28))
            }
        }
        .position(x: size.width / 2, y: size.height - layout.groundHeight / 2)
    }

    private func items(size: CGSize) -> some View {
        let layout = GameLayout(size: size)
        return ZStack {
            ForEach(game.obstacles) { obstacle in
                ObstacleView(obstacle: obstacle)
                    .position(x: obstacle.x, y: layout.groundTop - obstacle.height / 2)
            }
            ForEach(game.coins) { coin in
                Image(systemName: "circle.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(.yellow)
                    .shadow(color: .orange, radius: 2)
                    .position(x: coin.x, y: layout.groundTop - coin.y)
            }
            ForEach(game.powerUps) { power in
                Image(systemName: power.type.symbol)
                    .font(.system(size: 18))
                    .foregroundStyle(.white)
                    .padding(3)
                    .background(.purple.gradient, in: Circle())
                    .shadow(color: .white, radius: 4)
                    .position(x: power.x, y: layout.groundTop - power.y)
            }
        }
    }

    private func runner(size: CGSize) -> some View {
        let layout = GameLayout(size: size)
        return CharacterBadge(
            character: character,
            size: layout.runnerSize,
            running: game.phase == .running,
            jumping: !game.player.isGrounded
        )
            .opacity(game.isFlashing ? 0.25 : 1)
            .rotationEffect(.degrees(game.hitShake))
            .position(x: layout.runnerCenterX, y: layout.runnerCenterY - game.player.y)
            .animation(.spring(duration: 0.15), value: game.player.y)
    }

    private func hud(size: CGSize) -> some View {
        VStack {
            HStack(spacing: 10) {
                Button { game.togglePause() } label: {
                    Image(systemName: game.phase == .paused ? "play.circle.fill" : "pause.circle.fill")
                        .font(.system(size: 23))
                        .foregroundStyle(.white, .blue)
                }
                .buttonStyle(.plain)

                Text(units.format(meters: game.distance))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Spacer(minLength: 0)

                Label("\(game.runCoins)", systemImage: "circle.fill")
                    .foregroundStyle(.yellow)

                Spacer(minLength: 0)

                livesIndicator
            }
            .font(.system(size: 11, weight: .black, design: .rounded))
            .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
            .padding(.horizontal, 9)
            .padding(.top, 30)

            if let label = game.effectLabel {
                Text(label)
                    .font(.caption2.bold())
                    .padding(4)
                    .background(.purple.opacity(0.8), in: Capsule())
                    .position(x: size.width / 2, y: 52)
            }
            Spacer()
        }
    }

    @ViewBuilder
    private var livesIndicator: some View {
        if game.yolo {
            Text("YOLO")
                .foregroundStyle(.red)
        } else {
            HStack(spacing: 2) {
                Text("♥")
                    .foregroundStyle(.pink)
                Text("\(game.player.lives)")
                    .foregroundStyle(.white)
            }
            .animation(.spring(duration: 0.25), value: game.player.lives)
        }
    }

    @ViewBuilder private var overlays: some View {
        switch game.phase {
        case .countdown(let number):
            Text("\(number)").font(.system(size: 60, weight: .black, design: .rounded)).foregroundStyle(.yellow)
        case .go:
            Text("GO!").font(.system(size: 48, weight: .black, design: .rounded)).foregroundStyle(.green)
        case .paused:
            pauseOverlay
        case .gameOver:
            gameOverOverlay
        case .running:
            EmptyView()
        }
    }

    private var pauseOverlay: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("PAUSED")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.8), radius: 2, y: 2)

                Text("\(units.format(meters: game.distance))  •  \(game.runCoins) coins")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: .black, radius: 2)

                HStack(spacing: 28) {
                    overlayButton(icon: "play.fill", color: .green) { game.togglePause() }
                    overlayButton(icon: "house.fill") { screen = .home }
                }
            }
            .padding(.top, 24)
        }
    }

    private var gameOverOverlay: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("GAME OVER")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(.red)
                    .shadow(color: .black.opacity(0.8), radius: 2, y: 2)

                Text("\(units.format(meters: game.distance))  •  \(game.runCoins) coins")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: .black, radius: 2)

                HStack(spacing: 28) {
                    overlayButton(icon: "arrow.clockwise") { game.restart() }
                    overlayButton(icon: "house.fill") { screen = .home }
                }
            }
            .padding(.top, 24)
        }
    }

    private func overlayButton(icon: String, color: Color = .blue, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 25, weight: .bold))
                .foregroundStyle(color)
                .frame(width: 58, height: 58)
                .background(.white, in: Circle())
                .shadow(color: .black.opacity(0.45), radius: 3, y: 2)
        }
        .buttonStyle(.plain)
    }

    private func modal(title: String, subtitle: String, button: String?, transparent: Bool, action: @escaping () -> Void) -> some View {
        VStack(spacing: 7) {
            Text(title)
                .font(.headline.bold())
                .foregroundStyle(transparent ? .red : .white)
            Text(subtitle)
                .font(.caption)
                .shadow(color: .black, radius: 2)
            if transparent {
                HStack(spacing: 28) {
                    Button(action: action) {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                    Button {
                        screen = .home
                    } label: {
                        Image(systemName: "house.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                }
            } else {
                HStack {
                    Button(button ?? "Resume", action: action)
                        .tint(.green)
                    Button {
                        screen = .home
                    } label: {
                        Image(systemName: "house.fill")
                    }
                    .tint(.gray)
                }
            }
        }
        .padding(12)
        .background(transparent ? .clear : .black.opacity(0.88), in: RoundedRectangle(cornerRadius: 18))
    }

    private func jump() {
        game.jump()
        HapticManager.play(.click, enabled: hapticsEnabled)
    }
}

private struct ObstacleView: View {
    let obstacle: Obstacle

    var body: some View {
        Group {
            switch obstacle.kind {
            case "rock", "coconut":
                RockObstacle(width: obstacle.width, height: obstacle.height)
            case "log", "branch", "driftwood":
                LogObstacle(width: obstacle.width, height: obstacle.height)
            case "bush", "vine":
                BushObstacle(width: obstacle.width, height: obstacle.height)
            case "ice", "snowball":
                IceObstacle(width: obstacle.width, height: obstacle.height)
            default:
                Image(systemName: obstacle.symbol)
                    .font(.system(size: obstacle.height))
                    .foregroundStyle(.brown)
            }
        }
        .frame(width: obstacle.width + 8, height: obstacle.height, alignment: .bottom)
    }
}

private struct RockObstacle: View {
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: width * 0.08, y: height))
                path.addQuadCurve(to: CGPoint(x: width * 0.22, y: height * 0.34), control: CGPoint(x: width * 0.02, y: height * 0.55))
                path.addQuadCurve(to: CGPoint(x: width * 0.52, y: height * 0.14), control: CGPoint(x: width * 0.35, y: height * 0.02))
                path.addQuadCurve(to: CGPoint(x: width * 0.9, y: height * 0.4), control: CGPoint(x: width * 0.82, y: height * 0.08))
                path.addQuadCurve(to: CGPoint(x: width * 0.86, y: height), control: CGPoint(x: width, y: height * 0.78))
                path.closeSubpath()
            }
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.56, green: 0.48, blue: 0.42),
                        Color(red: 0.28, green: 0.24, blue: 0.22)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )

            Path { path in
                path.move(to: CGPoint(x: width * 0.25, y: height * 0.42))
                path.addQuadCurve(to: CGPoint(x: width * 0.52, y: height * 0.28), control: CGPoint(x: width * 0.38, y: height * 0.3))
                path.addQuadCurve(to: CGPoint(x: width * 0.72, y: height * 0.42), control: CGPoint(x: width * 0.62, y: height * 0.3))
            }
            .stroke(.white.opacity(0.22), lineWidth: 2)
        }
        .frame(width: width, height: height)
        .shadow(color: .black.opacity(0.25), radius: 1, y: 1)
    }
}

private struct LogObstacle: View {
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        ZStack {
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.58, green: 0.32, blue: 0.13),
                            Color(red: 0.3, green: 0.16, blue: 0.07)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: width + 9, height: max(height * 0.5, 10))
                .offset(y: height * 0.25)

            Circle()
                .fill(Color(red: 0.72, green: 0.48, blue: 0.26))
                .frame(width: max(height * 0.46, 8), height: max(height * 0.46, 8))
                .overlay(Circle().stroke(Color(red: 0.38, green: 0.2, blue: 0.1), lineWidth: 1.5))
                .offset(x: (width + 9) * 0.32, y: height * 0.25)
        }
        .frame(width: width + 9, height: height, alignment: .bottom)
        .rotationEffect(.degrees(-8))
        .shadow(color: .black.opacity(0.25), radius: 1, y: 1)
    }
}

private struct BushObstacle: View {
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        ZStack(alignment: .bottom) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.25, green: 0.64, blue: 0.25),
                                Color(red: 0.08, green: 0.34, blue: 0.12)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: width * 0.62, height: height * 0.68)
                    .offset(x: CGFloat(index - 1) * width * 0.23, y: index == 1 ? -height * 0.12 : 0)
            }
        }
        .frame(width: width + 8, height: height)
        .shadow(color: .black.opacity(0.22), radius: 1, y: 1)
    }
}

private struct IceObstacle: View {
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.78, green: 0.96, blue: 1.0),
                            Color(red: 0.26, green: 0.7, blue: 0.92)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: width, height: height)
                .rotationEffect(.degrees(-10))

            Capsule()
                .fill(.white.opacity(0.55))
                .frame(width: width * 0.46, height: 2)
                .offset(x: -width * 0.08, y: -height * 0.16)
        }
        .shadow(color: .black.opacity(0.2), radius: 1, y: 1)
    }
}

struct GameLayout {
    let size: CGSize

    var groundHeight: CGFloat { min(max(size.height * 0.14, 30), 38) }
    var groundTop: CGFloat { size.height - groundHeight }
    var runnerSize: CGFloat { min(max(size.width * 0.19, 34), 40) }
    var runnerCenterX: CGFloat { min(max(size.width * 0.24, 45), 52) }
    var runnerCenterY: CGFloat { groundTop - runnerSize / 2 }
    var jumpButtonSize: CGFloat { min(max(size.width * 0.14, 27), 31) }

    func playerFrame(jumpHeight: CGFloat) -> CGRect {
        CGRect(
            x: runnerCenterX - runnerSize * 0.42,
            y: groundTop - runnerSize - jumpHeight,
            width: runnerSize * 0.84,
            height: runnerSize
        )
    }
}

struct CharacterBadge: View {
    let character: CharacterType
    let size: CGFloat
    var running = false
    var jumping = false

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.12)) { timeline in
            let step = running && Int(timeline.date.timeIntervalSinceReferenceDate * 8).isMultiple(of: 2)
            Group {
                if let assetName {
                    Image(assetName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: size, height: size)
                } else {
                    ZStack {
                        Circle().fill(character.color.gradient)
                        Circle().fill(.white.opacity(0.25)).frame(width: size * 0.5, height: size * 0.4).offset(y: size * 0.16)
                        Image(systemName: character.symbol).font(.system(size: size * 0.36, weight: .bold)).foregroundStyle(.white)
                        Capsule().fill(character.color).frame(width: size * 0.2, height: size * 0.35).offset(x: -size * 0.16, y: size * (step ? 0.47 : 0.4))
                        Capsule().fill(character.color).frame(width: size * 0.2, height: size * 0.35).offset(x: size * 0.16, y: size * (step ? 0.4 : 0.47))
                    }
                    .frame(width: size, height: size)
                }
            }
            .offset(y: running && step ? -1 : 1)
        }
    }

    private var assetName: String? {
        let prefix: String
        switch character {
        case .cappi: prefix = "Cappi"
        case .pebble: prefix = "Pebble"
        case .biscuit: prefix = "Biscuit"
        case .boba: prefix = "Boba"
        case .momo: prefix = "Momo"
        }

        if jumping { return "\(prefix)Jump" }
        if running { return "\(prefix)Run" }
        return "\(prefix)Idle"
    }
}
