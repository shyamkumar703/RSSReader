//
//  String.swift
//  RSS
//
//  Created by Shyam Kumar on 1/13/23.
//

import Foundation
import SwiftUI

extension String {
    func indicesOf(string: String, startIndex: Int? = nil) -> [Int] {
        var indices = [Int]()
        var searchStartIndex: String.Index = {
            if let startIndex = startIndex {
                return String.Index(utf16Offset: startIndex, in: self)
            } else {
                return self.startIndex
            }
        }()

        while searchStartIndex < self.endIndex,
            let range = self.range(of: string, range: searchStartIndex..<self.endIndex),
            !range.isEmpty
        {
            let index = distance(from: self.startIndex, to: range.lowerBound)
            indices.append(index)
            searchStartIndex = range.upperBound
        }

        return indices
    }
    
    func nearestOf(strings: [String], fromStartIndex: Int) -> (String, Int) { // selected string and index
        var nearest = ("", Int.max) //
        for string in strings {
            if let firstIndex = indicesOf(string: string).filter({ $0 > fromStartIndex}).first,
               firstIndex < nearest.1 && firstIndex > fromStartIndex {
                nearest = (string, firstIndex + string.count)
            }
        }
        return nearest
    }
    
    func convertToAttributedFromHTML() -> AttributedString? {
        var attributedText: NSAttributedString?
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue]
        if let data = data(using: .unicode, allowLossyConversion: true), let attrStr = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            attributedText = attrStr
        }
        if let attributedText = attributedText {
            return AttributedString(attributedText)
        } else {
            return nil
        }
    }
}
