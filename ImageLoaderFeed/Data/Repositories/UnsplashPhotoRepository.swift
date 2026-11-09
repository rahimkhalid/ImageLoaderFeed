import Foundation

struct UnsplashPhotoRepository: PhotoRepository {
    private let apiClient: APIClient
    private let configuration: ServiceConfiguration
    private let cache: PhotoFeedCache

    private var accessKey: String {
        configuration.unsplashAccessKey
    }

    init(apiClient: APIClient, configuration: ServiceConfiguration, cache: PhotoFeedCache) {
        self.apiClient = apiClient
        self.configuration = configuration
        self.cache = cache
    }

    func cachedPhoto(id: String) async -> Photo? {
        await cache.load().first { $0.id == id }
    }

    func photoFeed(page: Int, perPage: Int) async -> PhotoFeedResult {
        do {
            let request = try APIRequest(
                endpoint: .photoFeed(page: page, perPage: perPage),
                headers: [
                    "Authorization": "Client-ID \(accessKey)"
                ]
            ).makeURLRequest()

            switch await apiClient.send(request) {
            case .success(let data):
                let response = try JSONDecoder().decode([UnsplashPhotoDTO].self, from: data)
                let photos = response.map { $0.toPhoto() }
                if page == 1 { await cache.save(photos) }
                return .success((photos: photos, isFromCache: false))
            case .failure(let error):
                if page == 1 {
                    let photos = await cache.load()
                    if !photos.isEmpty { return .success((photos: photos, isFromCache: true)) }
                }
                return .failure(mapAPIError(error))
            }
        } catch {
            return .failure(mapAPIError(error))
        }
    }

    func searchPhotos(query: String, page: Int, perPage: Int) async -> PhotoFeedResult {
        do {
            let request = try APIRequest(
                endpoint: .searchPhotos(query: query, page: page, perPage: perPage),
                headers: [
                    "Authorization": "Client-ID \(accessKey)"
                ]
            ).makeURLRequest()

            switch await apiClient.send(request) {
            case .success(let data):
                let response = try JSONDecoder().decode(UnsplashSearchPhotosDTO.self, from: data)
                return .success((photos: response.results.map { $0.toPhoto() }, isFromCache: false))
            case .failure(let error):
                return .failure(mapAPIError(error))
            }
        } catch {
            return .failure(mapAPIError(error))
        }
    }

    private func mapAPIError(_ error: Error) -> Error {
        if error is CancellationError || (error as? URLError)?.code == .cancelled {
            return error
        }

        if AppError.isConnectivityError(error) { return AppError.offline }

        print(error)
        return AppError.somethingWentWrong
    }
}

