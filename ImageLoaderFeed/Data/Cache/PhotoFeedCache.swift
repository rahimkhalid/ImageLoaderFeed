import Foundation

actor PhotoFeedCache {
    private let directory: URL
    private let session: URLSession
    private let limit = 30
    private var saveTask: Task<Void, Never>?

    init(
        directory: URL = URL.applicationSupportDirectory.appending(path: "PhotoFeedCache"),
        session: URLSession = .shared
    ) {
        self.directory = directory
        self.session = session
    }

    func save(_ photos: [Photo]) {
        saveTask?.cancel()
        let photos = Array(photos.prefix(limit))

        saveTask = Task {
            do {
                var savedPhotos: [Photo] = []
                for var photo in photos {
                    guard !Task.isCancelled else { return }
                    guard let url = photo.imageURL?.small else { continue }
                    let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
                    guard let (data, response) = try? await session.data(for: request),
                          let response = response as? HTTPURLResponse,
                          (200..<300).contains(response.statusCode),
                          response.mimeType?.hasPrefix("image/") == true else { continue }
                    photo.cachedImageData = data
                    savedPhotos.append(photo)
                }

                guard !Task.isCancelled, !savedPhotos.isEmpty else { return }
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                var cacheDirectory = directory
                var values = URLResourceValues()
                values.isExcludedFromBackup = true
                try cacheDirectory.setResourceValues(values)
                let data = try JSONEncoder().encode(savedPhotos)
                try data.write(to: fileURL, options: .atomic)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func load() -> [Photo] {
        guard let data = try? Data(contentsOf: fileURL),
              let photos = try? JSONDecoder().decode([Photo].self, from: data) else {
            return []
        }
        return Array(photos.prefix(limit)).filter { $0.cachedImageData != nil }
    }

    private var fileURL: URL {
        directory.appending(path: "photos.json")
    }
}
