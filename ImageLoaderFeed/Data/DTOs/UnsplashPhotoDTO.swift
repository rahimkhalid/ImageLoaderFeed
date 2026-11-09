import Foundation

struct UnsplashPhotoDTO: Decodable {
    let id: String
    let altDescription: String?
    let description: String?
    let urls: ImageURLs
    let user: Photographer?
    
    struct ImageURLs: Decodable {
        let small: URL
        let full: URL
    }
    
    struct Photographer: Decodable {
        let name: String
    }
    
    func toPhoto() -> Photo {
        let caption = [altDescription, description]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty } ?? ""
        
        return Photo(
            id: id,
            caption: caption,
            imageURL: .init(small: urls.small, full: urls.full),
            photographerName: user?.name
        )
    }
}
