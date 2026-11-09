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
        imageURL?.full
    }
    
    struct ImageURLs {
        let small: URL
        let full: URL
    }
}
