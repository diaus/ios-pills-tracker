import Domain
import Foundation

/// The name, Abbreviation and grid shape a Pill Type form holds, as its fields see them. Shared by the
/// Add Pill Type and Pill Type sheets; rules stay in Domain, this only turns the fields into a new
/// aggregate or a change to an existing one.
nonisolated struct PillTypeForm: Equatable, Sendable {
    var name = ""
    /// Empty means not set; Domain stores a blank Abbreviation as not set.
    var abbreviation = ""
    var rows = 2
    var columns = 5

    /// The field a rule the form broke shows under.
    enum Field {
        case name, rows, columns
        /// Under both steppers: an error without a field of its own, such as a locked shape.
        case shape
    }

    init() {}

    init(_ aggregate: PillTypeAggregate) {
        name = aggregate.pillType.name
        abbreviation = aggregate.pillType.abbreviation ?? ""
        rows = aggregate.pillType.shape.rows
        columns = aggregate.pillType.shape.columns
    }

    static func field(for error: DomainError) -> Field {
        switch error {
        case .emptyName: .name
        case .invalidRows: .rows
        case .invalidColumns: .columns
        default: .shape
        }
    }

    func makeAggregate(createdAt: Date) throws(DomainError) -> PillTypeAggregate {
        try PillTypeAggregate.new(name: name, abbreviation: abbreviation, rows: rows, columns: columns, createdAt: createdAt)
    }

    /// Renames, sets the Abbreviation and, only when it changed, the shape, which a Current Blister
    /// with pills refuses.
    func apply(to aggregate: inout PillTypeAggregate) throws(DomainError) {
        try aggregate.rename(name)
        aggregate.setAbbreviation(abbreviation)
        let shape = try GridShape(rows: rows, columns: columns)
        if shape != aggregate.pillType.shape {
            try aggregate.changeShape(shape)
        }
    }
}
