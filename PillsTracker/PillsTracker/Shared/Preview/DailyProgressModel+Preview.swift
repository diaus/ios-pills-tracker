import Data
import FactoryKit

extension DailyProgressModel {
    /// A model whose use cases reach `repository`: registered on the container before the model resolves them.
    /// The preview still has to run it: `.task { await model.run() }`.
    static func preview(_ repository: PreviewPillTypeRepository) -> DailyProgressModel {
        Container.shared.pillTypeRepository.register { repository }
        return DailyProgressModel()
    }
}
