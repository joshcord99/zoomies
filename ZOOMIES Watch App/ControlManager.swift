import Foundation

final class ControlManager {
    private var lastCrownValue = 0.0

    func crownChanged(to value: Double, jump: () -> Void) {
        if abs(value - lastCrownValue) > 0.16 {
            jump()
        }
        lastCrownValue = value
    }
}
