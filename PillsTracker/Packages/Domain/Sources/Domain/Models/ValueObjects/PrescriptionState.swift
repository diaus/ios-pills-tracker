import Foundation

/// Whether a Prescription counts toward today's progress and shows as a Home card.
public enum PrescriptionState: String, Sendable, Hashable, Codable {
    case active
    case paused
}
