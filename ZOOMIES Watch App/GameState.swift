import Foundation

enum GameScreen: String {
    case home, characters, maps, settings, playing
}

enum RunPhase: Equatable {
    case countdown(Int)
    case go
    case running
    case paused
    case gameOver
}
