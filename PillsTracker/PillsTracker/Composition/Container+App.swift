import FactoryKit
import Foundation

/// View model factories. Use cases live in `Container+UseCases.swift`, repositories in the Data package.
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

    @MainActor var pillTypeViewModel: ParameterFactory<UUID, PillTypeViewModel> {
        self { @MainActor pillTypeID in PillTypeViewModel(pillTypeID: pillTypeID) }
    }

    @MainActor var prescriptionViewModel: ParameterFactory<UUID, PrescriptionViewModel> {
        self { @MainActor pillTypeID in PrescriptionViewModel(pillTypeID: pillTypeID) }
    }
}
