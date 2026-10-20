import Foundation

/// Whether a Blister is the one being consumed right now or a former one kept for history.
public enum BlisterState: String, Sendable, Hashable, Codable {
    case current
    case retired
}
