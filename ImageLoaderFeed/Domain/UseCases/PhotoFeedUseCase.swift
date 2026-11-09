struct PhotoFeedUseCase {
    let repository: any PhotoRepository
    let itemsPerPage = 30

    func fetch(page: Int = 1) async -> Result<[Photo], Error> {
        await repository.photoFeed(page: page, perPage: itemsPerPage)
    }
}
