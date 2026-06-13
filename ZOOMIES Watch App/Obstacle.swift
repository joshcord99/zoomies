import SwiftUI

struct Obstacle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var kind: String
    var width: CGFloat = 22
    var height: CGFloat = 25

    var symbol: String {
        switch kind {
        case "snowball": "snowflake"
        case "box": "shippingbox.fill"
        case "puddle": "drop.fill"
        case "sandcastle": "building.columns.fill"
        case "coconut": "circle.fill"
        default: "exclamationmark.triangle.fill"
        }
    }
}
