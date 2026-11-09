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
    @Published var searchQuery = "" {
        didSet {
            guard normalizedQuery != makeNormalized(oldValue) else {
                return
            }
            loadPhotos()
        }
    }

    private let photoFeedUseCase: PhotoFeedUseCase
    private let prefetchThreshold = 6
    private var nextPage = 1
    private var hasMorePages = true
    private var loadedPhotoIDs = Set<String>()
    private var activeQuery = ""
    private var loadTask: Task<Void, Never>?

    private var normalizedQuery: String {
        makeNormalized(searchQuery)
    }

    var isSearching: Bool {
        !activeQuery.isEmpty
    }

    init(photoFeedUseCase: PhotoFeedUseCase) {
        self.photoFeedUseCase = photoFeedUseCase
    }
    
    private func makeNormalized(_ string: String) -> String {
        string.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func hasMorePages(fetchedPhotoCount: Int) -> Bool {
        fetchedPhotoCount == photoFeedUseCase.itemsPerPage
    }
    
    func loadIfNeeded() {
        guard case .idle = state else { return }
        loadPhotos()
    }

    func loadNextPageIfNeeded(currentPhotoID: String) {
        guard case .loaded(let photos) = state,
              activeQuery == normalizedQuery,
              nextPageError == nil,
              photos.suffix(prefetchThreshold).contains(where: { $0.id == currentPhotoID }) else {
            return
        }

        loadNextPage()
    }

    func retryNextPage() {
        guard nextPageError != nil else { return }
        loadNextPage()
    }

    func loadPhotos() {
        let query = normalizedQuery
        if query == activeQuery {
            if case .loading = state { return }
            guard !isLoadingNextPage else { return }
        }

        let shouldDebounce = query != activeQuery && !query.isEmpty
        loadTask?.cancel()
        activeQuery = query

        nextPage = 1
        hasMorePages = true
        isLoadingNextPage = false
        loadedPhotoIDs.removeAll()
        nextPageError = nil
        state = .loading

        loadTask = Task {
            if shouldDebounce {
                do {
                    try await Task.sleep(for: .milliseconds(250))
                } catch {
                    return
                }
            }

            let result = await photoFeedUseCase.fetch(page: 1, query: query)
            guard !Task.isCancelled else { return }

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
    }

    private func loadNextPage() {
        guard case .loaded(let photos) = state,
              !photos.isEmpty,
              activeQuery == normalizedQuery,
              hasMorePages,
              !isLoadingNextPage else {
            return
        }

        isLoadingNextPage = true
        nextPageError = nil

        let page = nextPage
        let query = activeQuery
        loadTask = Task {
            defer {
                if !Task.isCancelled { isLoadingNextPage = false }
            }

            let result = await photoFeedUseCase.fetch(page: page, query: query)
            guard !Task.isCancelled else { return }

            switch result {
            case .success(let response):
                let newPhotos = uniquePhotos(from: response)
                nextPage += 1
                hasMorePages = hasMorePages(fetchedPhotoCount: response.count)
                state = .loaded(photos + newPhotos)
            case .failure(let error):
                if error is CancellationError || (error as? URLError)?.code == .cancelled {
                    return
                }
                nextPageError = error.localizedDescription
            }
        }
    }

    private func uniquePhotos(from photos: [Photo]) -> [Photo] {
        photos.filter { loadedPhotoIDs.insert($0.id).inserted }
    }
}
