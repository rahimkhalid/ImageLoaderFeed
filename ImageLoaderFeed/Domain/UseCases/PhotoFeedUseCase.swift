@MainActor
final class PhotoFeedUseCase {
    let repository: any PhotoRepository
    let itemsPerPage = 30
    private(set) var isFromCache = false

    init(repository: any PhotoRepository) {
        self.repository = repository
    }

    func photoForDetail(_ photo: Photo) async -> Photo {
        guard photo.cachedImageData == nil else { return photo }
        return await repository.cachedPhoto(id: photo.id) ?? photo
    }

    func fetch(page: Int = 1, query: String = "") async -> Result<[Photo], Error> {
        guard !Task.isCancelled else { return .failure(CancellationError()) }
        isFromCache = false
        let result: PhotoFeedResult
        if query.isEmpty {
            result = await repository.photoFeed(page: page, perPage: itemsPerPage)
        } else {
            result = await repository.searchPhotos(query: query, page: page, perPage: itemsPerPage)
        }

        guard !Task.isCancelled else { return .failure(CancellationError()) }
        return result.map { response in
            isFromCache = response.isFromCache
            return response.photos
        }
    }
}
