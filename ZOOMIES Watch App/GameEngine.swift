import SwiftUI

@MainActor
final class GameEngine: ObservableObject {
    @Published var phase: RunPhase = .countdown(3)
    @Published var player = Player()
    @Published var obstacles: [Obstacle] = []
    @Published var coins: [Coin] = []
    @Published var powerUps: [PowerUp] = []
    @Published var distance = 0.0
    @Published var runCoins = 0
    @Published var worldOffset: CGFloat = 0
    @Published var effectLabel: String?
    @Published var hitShake = 0.0
    @Published var isFlashing = false

    var yolo = false
    var savedResults = false
    private var character: CharacterType = .cappi
    private var map: MapType = .meadow
    private var soundEnabled = true
    private var hapticsEnabled = true
    private var timer: Timer?
    private var lastTick = Date.timeIntervalSinceReferenceDate
    private var phaseStarted = Date.timeIntervalSinceReferenceDate
    private var sceneSize: CGSize = .zero
    private var nextObstacle = 1.2
    private var nextCoin = 0.6
    private var nextPower = 5.0
    private var speedBoostUntil = 0.0
    private var shieldUntil = 0.0
    private var magnetUntil = 0.0
    private var doubleCoinsUntil = 0.0
    private var frenzyUntil = 0.0
    private var recentMouse = 0.0
    private var recentYarn = 0.0
    private let maxVisibleObstacles = 2
    private let minObstacleSpacing: CGFloat = 92
    private let minCoinObstacleSpacing: CGFloat = 125

    func configure(character: CharacterType, map: MapType, yolo: Bool, sound: Bool, haptics: Bool) {
        self.character = character
        self.map = map
        self.yolo = yolo
        self.soundEnabled = sound
        self.hapticsEnabled = haptics
    }

    func start(size: CGSize) {
        sceneSize = size
        restart()
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func restart() {
        player = Player(lives: yolo ? 1 : 3)
        obstacles = []
        coins = []
        powerUps = []
        distance = 0
        runCoins = 0
        savedResults = false
        worldOffset = 0
        effectLabel = nil
        phase = .countdown(3)
        phaseStarted = Date.timeIntervalSinceReferenceDate
        lastTick = phaseStarted
        nextObstacle = yolo ? 1.05 : 1.45
        nextCoin = 0.4
        nextPower = 4.5
    }

    func jump() {
        guard phase == .running else { return }
        player.jump(as: character)
    }

    func togglePause() {
        if phase == .running {
            phase = .paused
        } else if phase == .paused {
            phase = .running
            lastTick = Date.timeIntervalSinceReferenceDate
        }
    }

    private func tick() {
        let now = Date.timeIntervalSinceReferenceDate
        let delta = min(now - lastTick, 0.05)
        lastTick = now

        switch phase {
        case .countdown:
            let elapsed = now - phaseStarted
            if elapsed >= 3 {
                phase = .go
                phaseStarted = now
            } else {
                phase = .countdown(max(1, 3 - Int(elapsed)))
            }
            return
        case .go:
            if now - phaseStarted > 0.65 { phase = .running }
            return
        case .paused, .gameOver:
            return
        case .running:
            updateRun(delta: delta, now: now)
        }
    }

    // The player stays fixed; every world object moves left by the current scroll speed.
    private func updateRun(delta: TimeInterval, now: TimeInterval) {
        let tier = floor(distance / 250)
        let baseSpeed = (yolo ? 92.0 : 75.0) + tier * 5
        let speed = baseSpeed * (now < speedBoostUntil ? 1.35 : 1)
        let multiplier = (yolo ? 2.0 : 1.0) + tier * 0.1
        let homeBonus = character.homeMap == map ? 1.1 : 1
        distance += speed * delta * 0.09 * multiplier * homeBonus
        worldOffset -= CGFloat(speed * delta)
        player.update(delta: delta)

        nextObstacle -= delta
        nextCoin -= delta
        nextPower -= delta
        if nextObstacle <= 0 { spawnObstacle(speed: speed) }
        if nextCoin <= 0 { spawnCoins(now: now) }
        // Power-ups are intentionally shelved for the current gameplay version.

        for index in obstacles.indices { obstacles[index].x -= CGFloat(speed * delta) }
        for index in coins.indices {
            coins[index].x -= CGFloat(speed * delta)
            if now < magnetUntil, coins[index].x > 55 { coins[index].x -= CGFloat(speed * delta * 1.7) }
        }
        for index in powerUps.indices { powerUps[index].x -= CGFloat(speed * delta) }

        checkCollisions(now: now)
        obstacles.removeAll { $0.x < -30 }
        coins.removeAll { $0.x < -20 }
        powerUps.removeAll { $0.x < -20 }
        isFlashing = now < player.invincibleUntil && Int(now * 12).isMultiple(of: 2)
    }

    private func spawnObstacle(speed: Double) {
        guard visibleObstacleCount < maxVisibleObstacles else {
            nextObstacle = 0.35
            return
        }

        let spawnX = sceneSize.width + 25
        guard hasRoomForObstacle(at: spawnX) else {
            nextObstacle = 0.28
            return
        }

        let kinds: [String]
        switch map {
        case .meadow: kinds = ["rock", "log", "bush"]
        case .frost: kinds = ["snowball", "ice", "log"]
        case .cozy: kinds = ["box", "puddle", "trash"]
        case .beach: kinds = ["sandcastle", "ball", "driftwood"]
        case .jungle: kinds = ["vine", "branch", "coconut"]
        }
        let kind = kinds.randomElement() ?? "rock"
        let low = kind == "puddle"
        obstacles.append(Obstacle(x: spawnX, kind: kind, width: low ? 27 : 22, height: low ? 10 : 25))
        let tier = min(distance / 1000, 0.6)
        nextObstacle = Double.random(in: (yolo ? 0.95 : 1.2)...(2.05 - tier * 0.5))
    }

    private var visibleObstacleCount: Int {
        obstacles.filter { obstacle in
            obstacle.x > -obstacle.width && obstacle.x < sceneSize.width + 35
        }.count
    }

    private func hasRoomForObstacle(at spawnX: CGFloat) -> Bool {
        obstacles.allSatisfy { obstacle in
            abs(spawnX - obstacle.x) >= minObstacleSpacing
        }
    }

    private func spawnCoins(now: TimeInterval) {
        let count = now < frenzyUntil ? 5 : (yolo ? 4 : 3)
        let startX = sceneSize.width + 20
        let coinXs = (0..<count).map { startX + CGFloat($0 * 17) }
        guard coinXs.allSatisfy(isClearForCoin) else {
            nextCoin = 0.3
            return
        }

        for index in 0..<count {
            coins.append(Coin(x: coinXs[index], y: CGFloat.random(in: 48...82)))
        }
        nextCoin = now < frenzyUntil ? 0.45 : Double.random(in: 0.9...1.5)
    }

    private func isClearForCoin(x: CGFloat) -> Bool {
        obstacles.allSatisfy { obstacle in
            abs(x - obstacle.x) >= minCoinObstacleSpacing
        }
    }

    private func spawnPowerUp() {
        let type: PowerUpType
        if character == .biscuit, map == .cozy {
            type = (PowerUpType.allCases.filter { $0.isMouse || $0.isYarn }).randomElement() ?? .grayMouse
        } else {
            type = [.magnet, .shield, .speed, .doubleCoins, .slowMotion].randomElement() ?? .magnet
        }
        powerUps.append(PowerUp(x: sceneSize.width + 25, y: CGFloat.random(in: 28...70), type: type))
        nextPower = Double.random(in: 5...8)
    }

    private func checkCollisions(now: TimeInterval) {
        let layout = GameLayout(size: sceneSize)
        let playerFrame = layout.playerFrame(jumpHeight: player.y)
        for obstacle in obstacles where CollisionManager.intersects(
            playerFrame: playerFrame,
            itemCenter: CGPoint(x: obstacle.x, y: layout.groundTop - obstacle.collisionSize.height / 2),
            itemSize: obstacle.collisionSize
        ) {
            guard now > player.invincibleUntil else { continue }
            if now < shieldUntil {
                shieldUntil = 0
                showEffect("Shield saved you!")
            } else {
                player.lives -= 1
                player.invincibleUntil = now + 1.25
                hitShake = hitShake == 0 ? 12 : -hitShake
                HapticManager.play(.failure, enabled: hapticsEnabled)
                if player.lives <= 0 { phase = .gameOver }
            }
        }

        let collectedCoins = coins.filter {
            CollisionManager.intersects(
                playerFrame: playerFrame,
                itemCenter: CGPoint(x: $0.x, y: layout.groundTop - $0.y),
                itemSize: CGSize(width: 13, height: 13)
            )
        }
        for _ in collectedCoins {
            let bonus = character == .boba && map == .beach ? 1.1 : 1
            runCoins += Int(Double(now < doubleCoinsUntil ? 2 : 1) * bonus)
            AudioManager.playCollect(enabled: soundEnabled)
        }
        let coinIDs = Set(collectedCoins.map(\.id))
        coins.removeAll { coinIDs.contains($0.id) }

    }

    private func apply(_ type: PowerUpType, now: TimeInterval) {
        let duration = character == .biscuit && map == .cozy ? 6.6 : 6.0
        if type == .grayMouse { runCoins += 10 }
        if [.magnet, .goldenMouse, .blueYarn, .rainbowMouse].contains(type) { magnetUntil = now + duration }
        if [.shield, .ghostMouse].contains(type) { shieldUntil = now + duration }
        if [.speed, .rocketMouse, .redYarn, .giantYarn].contains(type) { speedBoostUntil = now + duration }
        if [.doubleCoins, .goldenYarn].contains(type) { doubleCoinsUntil = now + duration }
        if type.isMouse { recentMouse = now }
        if type.isYarn { recentYarn = now }
        if abs(recentMouse - recentYarn) < 2.5, recentMouse > 0, recentYarn > 0 {
            frenzyUntil = now + duration
            speedBoostUntil = now + duration
            doubleCoinsUntil = now + duration
            showEffect("CAT FRENZY!")
            HapticManager.play(.success, enabled: hapticsEnabled)
        } else {
            showEffect(type.label)
            HapticManager.play(.directionUp, enabled: hapticsEnabled)
        }
    }

    private func showEffect(_ text: String) {
        effectLabel = text
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.2))
            if self.effectLabel == text { self.effectLabel = nil }
        }
    }
}
