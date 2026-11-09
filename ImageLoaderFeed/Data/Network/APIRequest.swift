import Foundation

struct APIRequest {
    private static let defaultBaseURL = "https://api.unsplash.com"

    let baseURL: String
    let endpoint: Endpoint
    let headers: [String: String]

    init(
        baseURL: String = APIRequest.defaultBaseURL,
        endpoint: Endpoint,
        headers: [String: String] = [:]
    ) {
        self.baseURL = baseURL
        self.endpoint = endpoint
        self.headers = headers
    }

    func makeURLRequest() throws -> URLRequest {
        guard let baseURL = URL(string: baseURL),
              var components = URLComponents(
                url: baseURL.appending(path: endpoint.path),
                resolvingAgainstBaseURL: false
              ) else {
            throw AppError.invalidURL
        }

        components.queryItems = (components.queryItems ?? []) + endpoint.queryItems
        guard let url = components.url else {
            throw AppError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        return request
    }
}
