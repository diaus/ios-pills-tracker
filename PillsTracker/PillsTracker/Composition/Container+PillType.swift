import FactoryKit
import Foundation

extension Container {
    @MainActor var pillTypeViewModel: ParameterFactory<UUID, PillTypeViewModel> {
        self { @MainActor pillTypeID in PillTypeViewModel(pillTypeID: pillTypeID) }
    }
}
