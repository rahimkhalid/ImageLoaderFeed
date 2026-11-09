import Foundation

struct Photo: Identifiable {
    let id: String
    let caption: String
    let imageURL: ImageURLs?
    let photographerName: String?
    
    var feedImage: URL? {
        imageURL?.small
    }
    
    var fullPageImage: URL? {
        imageURL?.regular
    }
    
    struct ImageURLs {
        let small: URL
        let regular: URL
    }
}
