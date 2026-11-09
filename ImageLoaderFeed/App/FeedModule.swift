import SwiftUI

@MainActor
struct FeedModule {
    static func makeView(configuration: ServiceConfiguration) -> FeedView {
        let apiClient = APIClient()
        let repository = UnsplashPhotoRepository(
            apiClient: apiClient,
            configuration: configuration
        )
        let photoFeedUseCase = PhotoFeedUseCase(repository: repository)
        let viewModel = FeedViewModel(photoFeedUseCase: photoFeedUseCase)
        return FeedView(viewModel: viewModel)
    }
}
