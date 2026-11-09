import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel: FeedViewModel
    @StateObject private var router: AppRouter

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.medium, alignment: .top),
        GridItem(.flexible(), spacing: Spacing.medium, alignment: .top)
    ]

    init(viewModel: FeedViewModel, router: AppRouter) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _router = StateObject(wrappedValue: router)
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(AppStrings.photoFeedTitle)
                .task {
                    await viewModel.loadIfNeeded()
                }
        }
        .allowsHitTesting(router.presentedRoute == nil)
        .overlay {
            if let route = router.presentedRoute {
                router.destination(for: route)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.scale(scale: 0.96).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: router.presentedRoute?.id)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            loadingView
        case .loaded(let photos) where photos.isEmpty:
            emptyView
        case .loaded(let photos):
            photoGrid(photos: photos)
        case .failed(let message):
            errorView(message: message) {
                await viewModel.loadPhotos()
            }
        }
    }

    @ViewBuilder
    private var loadingView: some View {
        ProgressView(AppStrings.loadingPhotos)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var emptyView: some View {
        ContentUnavailableView(
            AppStrings.noPhotosTitle,
            systemImage: "photo.on.rectangle",
            description: Text(AppStrings.noPhotosDescription)
        )
    }

    @ViewBuilder
    private func photoGrid(photos: [Photo]) -> some View {
        ScrollView {
            LazyVGrid(columns: columns, alignment: .leading, spacing: Spacing.extraLarge) {
                ForEach(photos) { photo in
                    PhotoCell(photo: photo)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            router.showPhoto(photo)
                        }
                        .onAppear {
                            Task {
                                await viewModel.loadNextPageIfNeeded(currentPhotoID: photo.id)
                            }
                        }
                }
            }
            .padding(.horizontal, Spacing.large)
            .padding(.vertical, Spacing.medium)
            paginationFooter
        }
    }

    @ViewBuilder
    private func errorView(message: String, retry: @escaping () async -> Void) -> some View {
        ContentUnavailableView {
            Label(AppStrings.loadPhotosErrorTitle, systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button(AppStrings.tryAgain) {
                Task {
                    await retry()
                }
            }
            .buttonStyle(.bordered)
        }
    }

    @ViewBuilder
    private var paginationFooter: some View {
        if viewModel.isLoadingNextPage {
            ProgressView(AppStrings.loadingPhotos)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.large)
        } else if let message = viewModel.nextPageError {
            errorView(message: message) {
                await viewModel.retryNextPage()
            }
            .frame(maxWidth: .infinity)
            .padding(Spacing.large)
        }
    }
}
