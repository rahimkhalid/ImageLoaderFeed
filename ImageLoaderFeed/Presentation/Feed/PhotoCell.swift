import SwiftUI

struct PhotoCell: View {
    private let photo: Photo

    init(photo: Photo) {
        self.photo = photo
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            GeometryReader { geometry in
                AsyncImage(url: photo.feedImage) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        Image(systemName: "photo")
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
                .aspectRatio(AspectRatio.portrait, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))

            Text(photo.caption)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if let photographerName = photo.photographerName {
                Text(AppStrings.photographerName(photographerName))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
    }
}

struct PhotoCell_Previews: PreviewProvider {
    static var previews: some View {
        PhotoCell(photo: .init(id: "1", caption: AppStrings.previewPhotoDescription, imageURL: nil, photographerName: nil))
            .frame(width: 170)
            .padding(Spacing.large)
    }
}
