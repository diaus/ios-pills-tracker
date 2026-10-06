import FactoryKit

extension Container {
    @MainActor var homeViewModel: Factory<HomeViewModel> {
        self { @MainActor in HomeViewModel() }
    }
}
