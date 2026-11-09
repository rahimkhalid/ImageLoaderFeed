struct PhotoFeedUseCase {
    let repository: any PhotoRepository
    private let pageSize = 30

    func fetch(page: Int = 1) async -> Result<[Photo], Error> {
        await repository.photoFeed(page: page, perPage: pageSize)
    }
}
