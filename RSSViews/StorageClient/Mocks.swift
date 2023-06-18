//
//  Mocks.swift
//  
//
//  Created by Shyam Kumar on 6/13/23.
//

import Foundation

extension StorageClient {
    public static var empty: Self {
        .init(
            storeCategoriesToDisk: { _ in },
            readCategoriesFromDisk: { return [] },
            storeFeedsToDisk: { _ in },
            readFeedsFromDisk: { return [] }
        )
    }
}
