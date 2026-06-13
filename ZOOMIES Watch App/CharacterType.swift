import SwiftUI

enum CharacterType: String, CaseIterable, Identifiable, Codable {
    case cappi, pebble, biscuit, boba, momo

    var id: String { rawValue }
    var name: String { rawValue.capitalized }

    var animal: String {
        switch self {
        case .cappi: "Capybara"
        case .pebble: "Penguin"
        case .biscuit: "Cat"
        case .boba: "Corgi"
        case .momo: "Monkey"
        }
    }

    var ability: String {
        switch self {
        case .cappi: "Balanced runner"
        case .pebble: "Long ice slide"
        case .biscuit: "Double jump"
        case .boba: "Coin-streak boost"
        case .momo: "Banana magnet"
        }
    }

    var homeMap: MapType {
        switch self {
        case .cappi: .meadow
        case .pebble: .frost
        case .biscuit: .cozy
        case .boba: .beach
        case .momo: .jungle
        }
    }

    var color: Color {
        switch self {
        case .cappi: .brown
        case .pebble: .blue
        case .biscuit: .orange
        case .boba: .yellow
        case .momo: .purple
        }
    }

    var symbol: String {
        switch self {
        case .cappi: "leaf.fill"
        case .pebble: "snowflake"
        case .biscuit: "cat.fill"
        case .boba: "dog.fill"
        case .momo: "tree.fill"
        }
    }
}
