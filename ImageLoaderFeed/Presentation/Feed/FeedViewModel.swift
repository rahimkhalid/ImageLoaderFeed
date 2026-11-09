import Combine
import Foundation

@MainActor
final class FeedViewModel: ObservableObject {
    enum State {
        case idle
        case loading
        case loaded([Photo])
        case failed(String)
    }

    @Published private(set) var state: State = .idle
    private let photoFeedUseCase: PhotoFeedUseCase

    init(photoFeedUseCase: PhotoFeedUseCase) {
        self.photoFeedUseCase = photoFeedUseCase
    }

    func loadIfNeeded() async {
        guard case .idle = state else { return }
        await loadPhotos()
    }

    func loadPhotos() async {
        if case .loading = state { return }
        state = .loading

        let result = await photoFeedUseCase.fetch()
        guard !Task.isCancelled else {
            state = .idle
            return
        }

        switch result {
        case .success(let photos):
            state = .loaded(photos)
        case .failure(let error):
            if error is CancellationError || (error as? URLError)?.code == .cancelled {
                state = .idle
            } else {
                state = .failed(error.localizedDescription)
            }
        }
    }
}
