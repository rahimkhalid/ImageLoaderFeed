import SwiftUI
import UIKit

struct PhotoImage: View {
    let url: URL?
    let cachedImageData: Data?
    let contentMode: ContentMode

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                imageContent(image)
            default:
                if let cachedImage {
                    imageContent(cachedImage)
                } else {
                    Image(systemName: "photo")
                }
            }
        }
    }

    private var cachedImage: Image? {
        guard let data = cachedImageData, let image = UIImage(data: data) else { return nil }
        return Image(uiImage: image)
    }

    private func imageContent(_ image: Image) -> some View {
        image
            .resizable()
            .aspectRatio(contentMode: contentMode)
    }
}
