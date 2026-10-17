/// One of the three parts of the day a pill can be prescribed for.
/// Slots are labels, not clock times.
public enum Slot: String, CaseIterable, Sendable, Hashable, Codable {
    case morning
    case day
    case evening
}
