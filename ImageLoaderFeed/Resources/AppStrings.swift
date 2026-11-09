enum AppStrings {
    static let photoFeedTitle = "Photo Feed"
    static let loadingPhotos = "Loading photos…"
    static let noPhotosTitle = "No photos yet"
    static let noPhotosDescription = "Check back for new photos."
    static let loadPhotosErrorTitle = "Couldn't load photos"
    static let tryAgain = "Try again"
    static let configurationRequiredTitle = "Configuration required"
    static let imageLoadError = "Image load failed"
    static let untitledPhoto = "Untitled photo"
    static let previewPhotoDescription = "A longer photo description that wraps onto a second line."

    static let missingUnsplashAccessKey = "Something wrong with Unsplash Configuration"
    static let invalidURL = "Error: Request URL is invalid"
    static let somethingWentWrong = "Something Went Wrong. Please try again."
    static let unauthorized = "Error: Invalid AccessKey"
    static let rateLimited = "Error: The Unsplash request limit has been reached"
    static let invalidResponse = "Error: Invalid response"

    static func httpStatusError(_ statusCode: Int) -> String {
        "The server returned HTTP \(statusCode). Please try again."
    }

    static func photographerAttribution(_ name: String) -> String {
        "By \(name) on Unsplash"
    }
}
