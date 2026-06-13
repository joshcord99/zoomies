import Foundation

enum ControlMode: String, CaseIterable, Identifiable {
    case screenButton
    case digitalCrown

    var id: String { rawValue }
    var title: String { self == .screenButton ? "Screen Button" : "Digital Crown" }
}
