//
//  Feed.swift
//  RSS
//
//  Created by Shyam Kumar on 1/11/23.
//

import Foundation
import QueryBuilderSwiftUI

struct Feed: Codable, Identifiable {
    var id: Int
    var userId: Int // user_id
    var feedUrl: String // feed_url
    var siteUrl: String // site_url
    var title: String
    var checkedAt: String // checked_at
    var nextCheckAt: String // next_check_at
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case feedUrl = "feed_url"
        case siteUrl = "site_url"
        case title
        case checkedAt = "checked_at"
        case nextCheckAt = "next_check_at"
    }
}

extension Feed: IsComparable {
    func evaluate(comparator: QueryBuilderSwiftUI.Comparator, against value: any IsComparable) -> Bool {
        guard let value = value as? Feed else {
            return false
        }
        switch comparator {
        case .less:
            return self.title < value.title
        case .greater:
            return self.title > value.title
        case .lessThanOrEqual:
            return self.title <= value.title
        case .greaterThanOrEqual:
            return self.title >= value.title
        case .equal:
            return self.title == value.title
        case .notEqual:
            return self.title != value.title
        }
    }
    
    static func createAssociatedViewModel(options: [(any IsComparable)], startingValue: (any IsComparable)?) -> StringComparableViewModel {
        return StringComparableViewModel(value: startingValue as? String, options: options)
    }
    
    func translateOption() -> any IsComparable { title }
}
