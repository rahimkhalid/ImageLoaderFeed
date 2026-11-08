import SwiftUI

struct PhotoCell: View {
    let caption: String
    let image: Image?

    init(caption: String, image: Image? = nil) {
        self.caption = caption
        self.image = image
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            GeometryReader { geometry in
                Group {
                    if let image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(systemName: "photo") //TODO: use actual image here
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
                .aspectRatio(AspectRatio.portrait, contentMode: .fit)
                .background(.quaternary)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))

            Text(caption)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .lineLimit(2, reservesSpace: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct PhotoCell_Previews: PreviewProvider {
    static var previews: some View {
        PhotoCell(caption: "A longer photo description that wraps onto a second line.")
            .frame(width: 170)
            .padding(Spacing.large)
    }
}
