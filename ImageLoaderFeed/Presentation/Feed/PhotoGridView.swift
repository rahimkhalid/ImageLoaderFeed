import SwiftUI

struct PhotoGridView<Footer: View>: View {
    let photos: [Photo]
    let onSelect: (Photo) -> Void
    let onPhotoAppear: (String) -> Void
    @ViewBuilder var footer: () -> Footer

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.medium, alignment: .top),
        GridItem(.flexible(), spacing: Spacing.medium, alignment: .top)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, alignment: .leading, spacing: Spacing.extraLarge) {
                ForEach(photos) { photo in
                    PhotoCell(photo: photo)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onSelect(photo)
                        }
                        .onAppear {
                            onPhotoAppear(photo.id)
                        }
                }
            }
            .padding(.horizontal, Spacing.large)
            .padding(.vertical, Spacing.medium)

            footer()
        }
        .scrollDismissesKeyboard(.immediately)
    }
}
