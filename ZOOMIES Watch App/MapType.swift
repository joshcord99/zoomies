import SwiftUI

enum MapType: String, CaseIterable, Identifiable, Codable {
    case meadow, frost, cozy, beach, jungle

    var id: String { rawValue }

    var name: String {
        switch self {
        case .meadow: "Meadow Valley"
        case .frost: "Frost Peak"
        case .cozy: "Cozy Town"
        case .beach: "Sunny Beach"
        case .jungle: "Jungle Canopy"
        }
    }

    var recommended: CharacterType {
        switch self {
        case .meadow: .cappi
        case .frost: .pebble
        case .cozy: .biscuit
        case .beach: .boba
        case .jungle: .momo
        }
    }

    var compatibleCharacters: [CharacterType] {
        CharacterType.allCases
    }

    func supports(_ character: CharacterType) -> Bool {
        compatibleCharacters.contains(character)
    }

    var compatibilityLabel: String {
        compatibleCharacters.map(\.name).joined(separator: ", ")
    }

    var sky: Color {
        switch self {
        case .meadow: Color(red: 0.35, green: 0.78, blue: 0.98)
        case .frost: Color(red: 0.55, green: 0.82, blue: 0.98)
        case .cozy: Color(red: 0.35, green: 0.28, blue: 0.55)
        case .beach: Color(red: 0.15, green: 0.72, blue: 0.96)
        case .jungle: Color(red: 0.15, green: 0.55, blue: 0.35)
        }
    }

    var ground: Color {
        switch self {
        case .meadow: .green
        case .frost: .cyan
        case .cozy: .gray
        case .beach: .yellow
        case .jungle: Color(red: 0.2, green: 0.45, blue: 0.18)
        }
    }

    var propSymbol: String {
        switch self {
        case .meadow: "tree.fill"
        case .frost: "mountain.2.fill"
        case .cozy: "building.2.fill"
        case .beach: "sun.max.fill"
        case .jungle: "leaf.fill"
        }
    }
}
