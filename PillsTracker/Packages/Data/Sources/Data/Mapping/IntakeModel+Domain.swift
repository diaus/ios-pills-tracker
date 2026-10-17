import Domain
import Foundation

extension IntakeModel {
    convenience init(_ intake: Intake) {
        self.init(
            id: intake.id,
            pillTypeID: intake.pillTypeID,
            blisterID: intake.blisterID,
            position: intake.position,
            slot: intake.slot.rawValue,
            dayYear: intake.day.year,
            dayMonth: intake.day.month,
            dayDay: intake.day.day,
            instant: intake.instant
        )
    }

    func toDomain() throws(DataError) -> Intake {
        Intake(
            id: id,
            pillTypeID: pillTypeID,
            blisterID: blisterID,
            position: position,
            slot: try DataError.rawValue(slot),
            day: Day(year: dayYear, month: dayMonth, day: dayDay),
            instant: instant
        )
    }
}
