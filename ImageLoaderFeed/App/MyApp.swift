import SwiftUI

@main struct MyApp: App {
    private let feedView: Result<FeedView, Error> = Result {
        let configuration = try ServiceConfiguration()
        return FeedModule.makeView(configuration: configuration)
    }

    var body: some Scene {
        WindowGroup {
            switch feedView {
            case .success(let view):
                view
            case .failure(let error):
                ContentUnavailableView(
                    AppStrings.configurationRequiredTitle,
                    systemImage: "key",
                    description: Text(error.localizedDescription)
                )
            }
        }
    }
}
