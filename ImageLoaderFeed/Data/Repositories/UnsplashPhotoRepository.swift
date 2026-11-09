import Foundation

struct UnsplashPhotoRepository: PhotoRepository {
    private let apiClient: APIClient
    private let configuration: ServiceConfiguration

    private var accessKey: String {
        configuration.unsplashAccessKey
    }

    init(apiClient: APIClient, configuration: ServiceConfiguration) {
        self.apiClient = apiClient
        self.configuration = configuration
    }

    func photoFeed(page: Int, perPage: Int) async -> Result<[Photo], Error> {
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
                return .success(response.map { $0.toPhoto() })
            case .failure(let error):
                return .failure(mapAPIError(error))
            }
        } catch {
            return .failure(mapAPIError(error))
        }
    }

    func searchPhotos(query: String, page: Int, perPage: Int) async -> Result<[Photo], Error> {
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
                return .success(response.results.map { $0.toPhoto() })
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

        print(error)
        return AppError.somethingWentWrong
    }
}

