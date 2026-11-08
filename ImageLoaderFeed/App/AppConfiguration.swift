import Foundation

struct AppConfiguration {
    let unsplashAccessKey: String

    init(bundle: Bundle = .main) throws {
        let key = (bundle.object(
            forInfoDictionaryKey: "UnsplashAccessKey"
        ) as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !key.isEmpty,
              key != "YOUR_UNSPLASH_ACCESS_KEY",
              !key.contains("$(") else {
            throw ConfigurationError.missingUnsplashAccessKey
        }

        unsplashAccessKey = key
    }
}

enum ConfigurationError: LocalizedError {
    case missingUnsplashAccessKey

    var errorDescription: String? {
        "The Unsplash Access Key is missing. Configure Secrets.xcconfig and rebuild."
    }
}
