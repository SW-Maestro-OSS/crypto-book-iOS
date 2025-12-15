import Foundation
import UIKit

public actor ImageCache {
    public var cache: [URL: UIImage] = [:]
    public var loadingTasks: [URL: Task<UIImage?, Never>] = [:]

    public init() {}

    public func image(for url: URL) async -> UIImage? {
        if let cachedImage = cache[url] {
            return cachedImage
        }

        if let existingTask = loadingTasks[url] {
            return await existingTask.value
        }

        let task = Task<UIImage?, Never> {
            guard let (data, _) = try? await URLSession.shared.data(from: url),
                  let image = UIImage(data: data) else {
                return nil
            }
            return image
        }

        loadingTasks[url] = task

        let image = await task.value
        if let image = image {
            cache[url] = image
        }
        loadingTasks[url] = nil
        return image
    }

    public func prefetch(urls: [URL]) async {
        await withTaskGroup(of: Void.self) { group in
            for url in urls {
                group.addTask {
                    _ = await self.image(for: url)
                }
            }
        }
    }
}
