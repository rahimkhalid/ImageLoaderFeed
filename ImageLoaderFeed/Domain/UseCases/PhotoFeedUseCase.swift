struct PhotoFeedUseCase {
    let repository: any PhotoRepository
    let itemsPerPage = 30

    func fetch(page: Int = 1, query: String = "") async -> Result<[Photo], Error> {
        if query.isEmpty {
            await repository.photoFeed(page: page, perPage: itemsPerPage)
        } else {
            await repository.searchPhotos(query: query, page: page, perPage: itemsPerPage)
        }
    }
}
