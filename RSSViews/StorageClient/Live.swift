//
//  Live.swift
//  
//
//  Created by Shyam Kumar on 6/13/23.
//

import Foundation
import RSSClient

extension StorageClient {
    public static var live: Self {
        enum StorageKey: String {
            case feeds
            case categories
            
            var savePath: URL {
                FileManager.documentsDirectory.appendingPathComponent(rawValue)
            }
        }
        
        return .init(
            storeCategoriesToDisk: { categories in
                try? (try? JSONEncoder().encode(categories))?.write(to: StorageKey.categories.savePath)
            },
            readCategoriesFromDisk: {
                guard let data = try? Data(contentsOf: StorageKey.categories.savePath) else { return [] }
                return (try? JSONDecoder().decode([RSSCategory].self, from: data)) ?? []
            },
            storeFeedsToDisk: { feeds in
                try? (try? JSONEncoder().encode(feeds))?.write(to: StorageKey.feeds.savePath)
            },
            readFeedsFromDisk: {
                guard let data = try? Data(contentsOf: StorageKey.feeds.savePath) else { return [] }
                return (try? JSONDecoder().decode([FeedResponse].self, from: data)) ?? []
            }
        )
    }
}

// MARK: - Helpers
extension FileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
