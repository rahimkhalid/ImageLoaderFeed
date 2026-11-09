import Foundation

enum Endpoint {
    case photoFeed(page: Int, perPage: Int)

    var path: String {
        switch self {
        case .photoFeed:
            "photos"
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
        }
    }
}
