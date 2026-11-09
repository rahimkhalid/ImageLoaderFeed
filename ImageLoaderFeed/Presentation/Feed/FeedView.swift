import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel: FeedViewModel

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.medium, alignment: .top),
        GridItem(.flexible(), spacing: Spacing.medium, alignment: .top)
    ]

    init(viewModel: FeedViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(AppStrings.photoFeedTitle)
                .task {
                    await viewModel.loadIfNeeded()
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView(AppStrings.loadingPhotos)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded(let photos) where photos.isEmpty:
            ContentUnavailableView(
                AppStrings.noPhotosTitle,
                systemImage: "photo.on.rectangle",
                description: Text(AppStrings.noPhotosDescription)
            )
        case .loaded(let photos):
            ScrollView {
                LazyVGrid(columns: columns, alignment: .leading, spacing: Spacing.extraLarge) {
                    ForEach(photos) { photo in
                        VStack(alignment: .leading, spacing: Spacing.small) {
                            PhotoCell(photo: photo)
                        }
                    }
                }
                .padding(.horizontal, Spacing.large)
                .padding(.vertical, Spacing.medium)
            }
        case .failed(let message):
            ContentUnavailableView {
                Label(AppStrings.loadPhotosErrorTitle, systemImage: "exclamationmark.triangle")
            } description: {
                Text(message)
            } actions: {
                Button(AppStrings.tryAgain) {
                    Task {
                        await viewModel.loadPhotos()
                    }
                }
                .buttonStyle(.bordered)
            }
        }
    }
}
