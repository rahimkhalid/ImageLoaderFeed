import Foundation

struct UnsplashSearchPhotosDTO: Decodable {
    let results: [UnsplashPhotoDTO]
}

struct UnsplashPhotoDTO: Decodable {
    let id: String
    let altDescription: String?
    let description: String?
    let urls: ImageURLs
    let user: Photographer?
    
    struct ImageURLs: Decodable {
        let small: URL
        let regular: URL
    }
    
    struct Photographer: Decodable {
        let name: String
    }
    
    func toPhoto() -> Photo {
        let caption = [altDescription, description]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty } ?? AppStrings.untitledPhoto
        
        return Photo(
            id: id,
            caption: caption,
            imageURL: .init(small: urls.small, regular: urls.regular),
            photographerName: user?.name
        )
    }
}
