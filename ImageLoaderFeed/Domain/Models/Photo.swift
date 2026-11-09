import Foundation

struct Photo: Identifiable, Codable, Sendable {
    let id: String
    let caption: String
    let imageURL: ImageURLs?
    let photographerName: String?
    var cachedImageData: Data? = nil
    
    var feedImage: URL? {
        imageURL?.small
    }
    
    var fullPageImage: URL? {
        imageURL?.regular
    }
    
    struct ImageURLs: Codable, Sendable {
        let small: URL
        let regular: URL
    }
}
