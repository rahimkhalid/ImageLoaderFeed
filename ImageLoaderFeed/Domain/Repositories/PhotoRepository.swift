protocol PhotoRepository {
    func photoFeed(page: Int, perPage: Int) async -> Result<[Photo], Error>
}
