//
//  RSSTests.swift
//  RSSTests
//
//  Created by Shyam Kumar on 1/11/23.
//

import XCTest
@testable import RSS

final class RSSTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let sut = HTMLParser2(htmlString: exampleHtml)
//        let dom = sut.createDOM()
        let groupedDom = sut.createFlattenedDOM()
        XCTAssertNil(nil)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

fileprivate var exampleHtml = "<ul><li><a href=\"https://what-if.xkcd.com\" rel=\"noopener noreferrer\" target=\"_blank\" referrerpolicy=\"no-referrer\">What If?</a></li>\n<li><a href=\"https://blag.xkcd.com\" rel=\"noopener noreferrer\" target=\"_blank\" referrerpolicy=\"no-referrer\">Blag</a></li>\n<li><a href=\"https://xkcd.com/about\" rel=\"noopener noreferrer\" target=\"_blank\" referrerpolicy=\"no-referrer\">About</a></li>\n<li><a href=\"https://xkcd.com/atom.xml\" rel=\"noopener noreferrer\" target=\"_blank\" referrerpolicy=\"no-referrer\">Feed</a>•<a href=\"https://xkcd.com/newsletter/\" rel=\"noopener noreferrer\" target=\"_blank\" referrerpolicy=\"no-referrer\">Email</a></li>\n<li><a href=\"https://twitter.com/xkcd/\" rel=\"noopener noreferrer\" target=\"_blank\" referrerpolicy=\"no-referrer\">TW</a>•<a href=\"https://www.facebook.com/TheXKCD/\" rel=\"noopener noreferrer\" target=\"_blank\" referrerpolicy=\"no-referrer\">FB</a>•<a href=\"https://www.instagram.com/xkcd/\" rel=\"noopener noreferrer\" target=\"_blank\" referrerpolicy=\"no-referrer\">IG</a></li>\n<li><a href=\"https://xkcd.com/books/\" rel=\"noopener noreferrer\" target=\"_blank\" referrerpolicy=\"no-referrer\">-Books-</a></li>\n<li><a href=\"https://xkcd.com/what-if-2/\" rel=\"noopener noreferrer\" target=\"_blank\" referrerpolicy=\"no-referrer\">What If? 2</a></li>\n<li><a href=\"https://xkcd.com/what-if/\" rel=\"noopener noreferrer\" target=\"_blank\" referrerpolicy=\"no-referrer\">WI?</a>•<a href=\"https://xkcd.com/thing-explainer/\" rel=\"noopener noreferrer\" target=\"_blank\" referrerpolicy=\"no-referrer\">TE</a>•<a href=\"https://xkcd.com/how-to/\" rel=\"noopener noreferrer\" target=\"_blank\" referrerpolicy=\"no-referrer\">HT</a></li>\n</ul>"
