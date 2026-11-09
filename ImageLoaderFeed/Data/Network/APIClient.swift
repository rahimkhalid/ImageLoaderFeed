import Foundation

struct APIClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func send(_ request: URLRequest) async -> Result<Data, Error> {
        do {
            let (data, response) = try await session.data(for: request)
            guard let response = response as? HTTPURLResponse else {
                return .failure(AppError.invalidResponse)
            }

            guard (200..<300).contains(response.statusCode) else {
                return .failure(AppError.httpStatus(response))
            }

            return .success(data)
        } catch {
            return .failure(error)
        }
    }
}
