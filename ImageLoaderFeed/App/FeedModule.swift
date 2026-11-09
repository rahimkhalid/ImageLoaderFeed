import SwiftUI

@MainActor
struct FeedModule {
    static func makeView(configuration: ServiceConfiguration) -> FeedView {
        let apiClient = APIClient()
        let cache = PhotoFeedCache()
        let repository = UnsplashPhotoRepository(
            apiClient: apiClient,
            configuration: configuration,
            cache: cache
        )
        let photoFeedUseCase = PhotoFeedUseCase(repository: repository)
        let viewModel = FeedViewModel(photoFeedUseCase: photoFeedUseCase)
        let router = AppRouter()
        return FeedView(viewModel: viewModel, router: router)
    }
}
