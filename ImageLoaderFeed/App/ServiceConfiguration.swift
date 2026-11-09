import Foundation

struct ServiceConfiguration {
    let unsplashAccessKey: String

    init(bundle: Bundle = .main) throws {
        let key = (bundle.object(
            forInfoDictionaryKey: "UnsplashAccessKey"
        ) as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !key.isEmpty,
              key != "YOUR_UNSPLASH_ACCESS_KEY",
              !key.contains("$(") else {
            throw AppError.missingUnsplashAccessKey
        }

        unsplashAccessKey = key
    }
}

