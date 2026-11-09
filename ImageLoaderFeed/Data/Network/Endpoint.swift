import Foundation

enum Endpoint {
    case photoFeed(page: Int, perPage: Int)
    case searchPhotos(query: String, page: Int, perPage: Int)

    var path: String {
        switch self {
        case .photoFeed:
            "photos"
        case .searchPhotos:
            "search/photos"
        }
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .photoFeed(let page, let perPage):
            [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "per_page", value: String(perPage)),
                URLQueryItem(name: "order_by", value: "latest")
            ]
        case .searchPhotos(let query, let page, let perPage):
            [
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "per_page", value: String(perPage))
            ]
        }
    }
}
