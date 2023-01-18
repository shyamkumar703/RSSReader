//
//  Date.swift
//  RSS
//
//  Created by Shyam Kumar on 1/18/23.
//

import Foundation

extension Date {
    func timePassed() -> String {
        let currentTime = Date()
        let seconds = currentTime.timeIntervalSince1970 - self.timeIntervalSince1970
        if seconds < 60 {
            let seconds = Int(seconds)
            return "\(seconds) second\(seconds == 1 ? "" : "s") ago"
        } else if seconds / 60 < 60 {
            let minutes = Int(seconds / 60)
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        } else if seconds / 3600 < 24 {
            let hours = Int(seconds / 3600)
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        } else if seconds / (3600 * 24) < 365 {
            let days = Int(seconds / (3600 * 24))
            return "\(days) day\(days == 1 ? "" : "s") ago"
        } else {
            let years = Int(seconds / (3600 * 24 * 365))
            return "\(years) year\(years == 1 ? "" : "s") ago"
        }
    }
}
