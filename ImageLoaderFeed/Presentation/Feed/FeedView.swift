import SwiftUI

struct FeedView: View {
    private let columns = [
        GridItem(.flexible(), spacing: Spacing.medium, alignment: .top),
        GridItem(.flexible(), spacing: Spacing.medium, alignment: .top)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.extraLarge) {
                    LazyVGrid(columns: columns, alignment: .leading, spacing: Spacing.extraLarge) {
                        ForEach(0..<12, id: \.self) { _ in
                            PhotoCell(caption: "Description")
                        }
                    }
                }
                .padding(.horizontal, Spacing.large)
                .padding(.vertical, Spacing.medium)
            }
            .navigationTitle("Photo Feed")
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}
