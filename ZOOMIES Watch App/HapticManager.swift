import WatchKit

enum HapticManager {
    static func play(_ type: WKHapticType, enabled: Bool) {
        guard enabled else { return }
        WKInterfaceDevice.current().play(type)
    }
}
