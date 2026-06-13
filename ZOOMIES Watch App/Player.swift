import Foundation
import CoreGraphics

struct Player {
    var y: CGFloat = 0
    var velocity: CGFloat = 0
    var jumpCount = 0
    var lives = 3
    var invincibleUntil: TimeInterval = 0

    var isGrounded: Bool { y <= 0.01 }

    mutating func jump(as character: CharacterType) {
        let maxJumps = character == .biscuit ? 2 : 1
        guard jumpCount < maxJumps else { return }
        velocity = character == .pebble ? 205 : 220
        jumpCount += 1
    }

    mutating func update(delta: TimeInterval) {
        velocity -= 525 * CGFloat(delta)
        y += velocity * CGFloat(delta)
        if y <= 0 {
            y = 0
            velocity = 0
            jumpCount = 0
        }
    }
}
