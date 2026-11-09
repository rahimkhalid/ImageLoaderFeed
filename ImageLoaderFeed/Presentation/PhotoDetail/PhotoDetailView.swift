import SwiftUI

struct PhotoDetailView: View {
    let photo: Photo
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: Spacing.large) {
            closeButton
            PhotoImage(
                url: photo.fullPageImage,
                cachedImageData: photo.cachedImageData,
                contentMode: .fit
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            photoDescription
                .padding(Spacing.large)
        }
    }

    private var closeButton: some View {
        HStack {
            Spacer()
            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.largeTitle)
                    .padding(Spacing.small)
            }
            .tint(Color.primary)
        }
        .padding(.horizontal, Spacing.small)
    }

    private var photoDescription: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text(photo.caption.isEmpty ? AppStrings.untitledPhoto : photo.caption)
                .font(.headline)
                .lineLimit(3)

            if let photographerName = photo.photographerName {
                Text(AppStrings.photographerName(photographerName))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
