import Combine
import SwiftUI

@MainActor
final class AppRouter: ObservableObject {
    @Published var presentedRoute: Route?

    func showPhoto(_ photo: Photo) {
        presentedRoute = .photoDetail(photo)
    }

    func dismissPhoto() {
        presentedRoute = nil
    }

    @ViewBuilder
    func destination(for route: Route) -> some View {
        switch route {
        case .photoDetail(let photo):
            PhotoDetailView(photo: photo, onClose: dismissPhoto)
        }
    }
}

extension AppRouter {
    enum Route: Identifiable {
        case photoDetail(Photo)

        var id: String {
            switch self {
            case .photoDetail(let photo):
                photo.id
            }
        }
    }
}
