typealias PhotoFeedResult = Result<(photos: [Photo], isFromCache: Bool), Error>

protocol PhotoRepository {
    func cachedPhoto(id: String) async -> Photo?
    func photoFeed(page: Int, perPage: Int) async -> PhotoFeedResult
    func searchPhotos(query: String, page: Int, perPage: Int) async -> PhotoFeedResult
}
