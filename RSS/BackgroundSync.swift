//
//  BackgroundSync.swift
//  RSS
//

import BackgroundTasks
import Combine
import RSSClient
import RSSClientLive
import RSSViews

enum BackgroundSync {
    static let taskIdentifier = "com.shyamkumar.RSS.refresh"

    private static var bag = Set<AnyCancellable>()

    static func register() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
            handle(task: task as! BGAppRefreshTask)
        }
    }

    static func schedule() {
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60)
        try? BGTaskScheduler.shared.submit(request)
    }

    private static func handle(task: BGAppRefreshTask) {
        schedule()

        let client = RSSClient.live
        var storage = StorageClient.live
        var completed = false

        task.expirationHandler = {
            guard !completed else { return }
            bag.removeAll()
            task.setTaskCompleted(success: false)
        }

        Publishers.Zip(
            client.categories(),
            client.feedFor(nil, 0, .unread, "")
        )
        .sink(
            receiveCompletion: { completion in
                completed = true
                if case .failure = completion {
                    task.setTaskCompleted(success: false)
                } else {
                    task.setTaskCompleted(success: true)
                }
            },
            receiveValue: { categories, feedResponse in
                storage.updateCategories(categories)
                var copy = feedResponse
                storage.updateFeed(for: 0, feedResponse: &copy)
            }
        )
        .store(in: &bag)
    }
}
