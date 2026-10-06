extension PillTypeAggregate {
    /// Index of the Current Blister in `blisters`, so a use case can mutate it in place.
    func currentBlisterIndex() throws(UseCaseError) -> Int {
        guard let index = blisters.firstIndex(where: { $0.state == .current }) else { throw .noCurrentBlister }
        return index
    }
}
