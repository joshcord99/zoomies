import Foundation

enum DistanceUnit: String, CaseIterable, Identifiable {
    case metric
    case standard

    var id: String { rawValue }
    var title: String { self == .metric ? "Metric" : "Standard (US)" }

    func format(meters: Double) -> String {
        switch self {
        case .metric:
            if meters >= 1_000 {
                return String(format: "%.2f km", meters / 1_000)
            }
            return "\(Int(meters))m"
        case .standard:
            let feet = meters * 3.28084
            if feet >= 5_280 {
                return String(format: "%.2f mi", feet / 5_280)
            }
            return "\(Int(feet))ft"
        }
    }
}
