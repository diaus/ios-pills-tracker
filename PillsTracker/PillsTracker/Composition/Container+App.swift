import FactoryKit
import Foundation

extension Container {
    @MainActor var homeViewModel: Factory<HomeViewModel> {
        self { @MainActor in HomeViewModel() }
    }

    @MainActor var addPillTypeViewModel: Factory<AddPillTypeViewModel> {
        self { @MainActor in AddPillTypeViewModel() }
    }

    @MainActor var pillTypesListViewModel: Factory<PillTypesListViewModel> {
        self { @MainActor in PillTypesListViewModel() }
    }

    @MainActor var blisterViewModel: ParameterFactory<UUID, BlisterViewModel> {
        self { @MainActor pillTypeID in BlisterViewModel(pillTypeID: pillTypeID) }
    }
}
