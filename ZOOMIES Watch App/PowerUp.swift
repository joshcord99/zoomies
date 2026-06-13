import Foundation
import CoreGraphics

struct PowerUp: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var type: PowerUpType
}
