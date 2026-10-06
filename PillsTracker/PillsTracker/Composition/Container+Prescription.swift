import FactoryKit
import Foundation

extension Container {
    @MainActor var prescriptionViewModel: ParameterFactory<UUID, PrescriptionViewModel> {
        self { @MainActor pillTypeID in PrescriptionViewModel(pillTypeID: pillTypeID) }
    }
}
