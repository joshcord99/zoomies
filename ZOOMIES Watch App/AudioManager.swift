import WatchKit

enum AudioManager {
    static func playCollect(enabled: Bool) {
        guard enabled else { return }
        WKInterfaceDevice.current().play(.click)
    }
}
