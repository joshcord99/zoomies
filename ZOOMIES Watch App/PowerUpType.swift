import SwiftUI

enum PowerUpType: String, CaseIterable {
    case magnet, shield, speed, doubleCoins, slowMotion
    case grayMouse, goldenMouse, rocketMouse, ghostMouse, rainbowMouse
    case blueYarn, redYarn, goldenYarn, rainbowYarn, giantYarn

    var symbol: String {
        switch self {
        case .magnet, .goldenMouse, .blueYarn: "magnet.fill"
        case .shield, .ghostMouse: "shield.fill"
        case .speed, .rocketMouse, .redYarn: "bolt.fill"
        case .doubleCoins, .goldenYarn: "dollarsign.circle.fill"
        case .slowMotion: "timer"
        case .grayMouse, .rainbowMouse: "pawprint.fill"
        case .rainbowYarn, .giantYarn: "circle.hexagongrid.fill"
        }
    }

    var label: String {
        rawValue.replacingOccurrences(of: "Mouse", with: " Mouse")
            .replacingOccurrences(of: "Yarn", with: " Yarn").capitalized
    }

    var isMouse: Bool { [.grayMouse, .goldenMouse, .rocketMouse, .ghostMouse, .rainbowMouse].contains(self) }
    var isYarn: Bool { [.blueYarn, .redYarn, .goldenYarn, .rainbowYarn, .giantYarn].contains(self) }
}
