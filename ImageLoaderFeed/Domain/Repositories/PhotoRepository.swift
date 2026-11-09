protocol PhotoRepository {
    func photoFeed(page: Int, perPage: Int) async -> Result<[Photo], Error>
    func searchPhotos(query: String, page: Int, perPage: Int) async -> Result<[Photo], Error>
}
