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

    var collisionSize: CGSize {
        switch kind {
        case "rock", "coconut":
            CGSize(width: width * 0.72, height: height * 0.72)
        case "log", "branch", "driftwood":
            CGSize(width: width * 0.9, height: height * 0.46)
        case "bush", "vine":
            CGSize(width: width * 0.86, height: height * 0.6)
        case "ice", "snowball":
            CGSize(width: width * 0.78, height: height * 0.78)
        case "puddle":
            CGSize(width: width * 0.86, height: height * 0.5)
        default:
            CGSize(width: width * 0.82, height: height * 0.76)
        }
    }
}
