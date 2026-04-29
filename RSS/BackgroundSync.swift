//
//  BackgroundSync.swift
//  RSS
//

import BackgroundTasks
import Combine
import OSLog
import RSSClient
import RSSClientLive
import RSSViews

enum BackgroundSync {
    static let taskIdentifier = "com.shyamkumar.RSS.refresh"

    private static let log = Logger(subsystem: "com.shyamkumar.RSS", category: "BackgroundSync")
    private static var bag = Set<AnyCancellable>()

    static func register() {
        print("[BackgroundSync] register() entering")
        let registered = BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
            print("[BackgroundSync] handler fired")
            log.info("handler fired for \(taskIdentifier, privacy: .public)")
            handle(task: task as! BGAppRefreshTask)
        }
        print("[BackgroundSync] register() done, success=\(registered)")
        log.info("register() called, success=\(registered, privacy: .public)")
    }

    static func schedule() {
        print("[BackgroundSync] schedule() entering")
        BGTaskScheduler.shared.getPendingTaskRequests { existing in
            if existing.contains(where: { $0.identifier == taskIdentifier }) {
                print("[BackgroundSync] schedule() skipped: already pending")
                log.info("schedule() skipped: task already pending")
                return
            }
            let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
            request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60)
            do {
                try BGTaskScheduler.shared.submit(request)
                print("[BackgroundSync] schedule() submitted")
                log.info("scheduled \(taskIdentifier, privacy: .public) earliestBeginDate=\(request.earliestBeginDate?.description ?? "nil", privacy: .public)")
            } catch {
                print("[BackgroundSync] schedule() failed: \(error)")
                log.error("schedule failed: \(error.localizedDescription, privacy: .public)")
            }
        }
    }

    private static func handle(task: BGAppRefreshTask) {
        schedule()

        var completed = false
        task.expirationHandler = {
            guard !completed else { return }
            log.error("expirationHandler fired before completion")
            bag.removeAll()
            task.setTaskCompleted(success: false)
        }

        performSync { success in
            completed = true
            log.info("handle() finished success=\(success, privacy: .public)")
            task.setTaskCompleted(success: success)
        }
    }

    static func performSync(onCompletion: @escaping (Bool) -> Void) {
        let client = RSSClient.live
        var storage = StorageClient.live

        Publishers.Zip(
            client.categories(),
            client.feedFor(nil, 0, .unread, "")
        )
        .sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    log.error("performSync failed: \(error.localizedDescription, privacy: .public)")
                    onCompletion(false)
                } else {
                    onCompletion(true)
                }
            },
            receiveValue: { categories, feedResponse in
                log.info("synced \(categories.count, privacy: .public) categories, \(feedResponse.entries.count, privacy: .public) entries")
                storage.updateCategories(categories)
                var copy = feedResponse
                storage.updateFeed(for: 0, feedResponse: &copy)
            }
        )
        .store(in: &bag)
    }
}
