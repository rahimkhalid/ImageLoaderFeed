import Foundation

enum AppError: LocalizedError {
    case missingUnsplashAccessKey
    case invalidURL
    case invalidResponse
    case httpStatus(HTTPURLResponse)
    case unauthorized
    case rateLimited
    case somethingWentWrong
    case offline

    var errorDescription: String? {
        switch self {
        case .missingUnsplashAccessKey:
            AppStrings.missingUnsplashAccessKey
        case .invalidURL:
            AppStrings.invalidURL
        case .invalidResponse:
            AppStrings.invalidResponse
        case .httpStatus(let response):
            AppStrings.httpStatusError(response.statusCode)
        case .unauthorized:
            AppStrings.unauthorized
        case .rateLimited:
            AppStrings.rateLimited
        case .somethingWentWrong:
            AppStrings.somethingWentWrong
        case .offline:
            AppStrings.offline
        }
    }

    static func isConnectivityError(_ error: Error) -> Bool {
        guard let error = error as? URLError else { return false }
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost, .timedOut:
            return true
        default:
            return false
        }
    }
}
