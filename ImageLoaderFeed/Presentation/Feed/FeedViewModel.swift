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
    @Published private(set) var isLoadingNextPage = false
    @Published private(set) var nextPageError: String?

    private let photoFeedUseCase: PhotoFeedUseCase
    private let prefetchThreshold = 6
    private var nextPage = 1
    private var hasMorePages = true
    private var loadedPhotoIDs = Set<String>()

    init(photoFeedUseCase: PhotoFeedUseCase) {
        self.photoFeedUseCase = photoFeedUseCase
    }

    func loadIfNeeded() async {
        guard case .idle = state else { return }
        await loadPhotos()
    }
    
    func loadNextPageIfNeeded(currentPhotoID: String) async {
        guard case .loaded(let photos) = state,
              nextPageError == nil,
              photos.suffix(prefetchThreshold).contains(where: { $0.id == currentPhotoID }) else {
            return
        }

        await loadNextPage()
    }

    func retryNextPage() async {
        guard nextPageError != nil else { return }
        await loadNextPage()
    }

    func loadPhotos() async {
        if case .loading = state { return }
        guard !isLoadingNextPage else { return }

        nextPage = 1
        loadedPhotoIDs.removeAll()
        nextPageError = nil
        state = .loading

        let result = await photoFeedUseCase.fetch(page: nextPage)
        guard !Task.isCancelled else {
            state = .idle
            return
        }

        switch result {
        case .success(let photos):
            nextPage += 1
            hasMorePages = hasMorePages(fetchedPhotoCount: photos.count)
            state = .loaded(uniquePhotos(from: photos))
        case .failure(let error):
            if error is CancellationError || (error as? URLError)?.code == .cancelled {
                state = .idle
            } else {
                state = .failed(error.localizedDescription)
            }
        }
    }

    private func hasMorePages(fetchedPhotoCount: Int) -> Bool {
        fetchedPhotoCount == photoFeedUseCase.itemsPerPage
    }

    private func loadNextPage() async {
        guard case .loaded(let photos) = state,
              !photos.isEmpty,
              hasMorePages,
              !isLoadingNextPage else {
            return
        }

        isLoadingNextPage = true
        nextPageError = nil

        let result = await photoFeedUseCase.fetch(page: nextPage)
        guard !Task.isCancelled else { return }

        switch result {
        case .success(let response):
            let newPhotos = uniquePhotos(from: response)
            nextPage += 1
            hasMorePages = hasMorePages(fetchedPhotoCount: response.count)
            state = .loaded(photos + newPhotos)
            isLoadingNextPage = false
        case .failure(let error):
            if error is CancellationError || (error as? URLError)?.code == .cancelled {
                return
            }
            nextPageError = error.localizedDescription
            isLoadingNextPage = false
        }
    }

    private func uniquePhotos(from photos: [Photo]) -> [Photo] {
        photos.filter { loadedPhotoIDs.insert($0.id).inserted }
    }
}
