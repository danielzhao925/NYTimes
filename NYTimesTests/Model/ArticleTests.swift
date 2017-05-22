//
//  ArticleTests.swift
//  NYTimes
//
//  Created by NCS-zdq on 16/5/17.
//  Copyright © 2017 zdq. All rights reserved.
//

import XCTest

class ArticleTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testArticleSingle() {
        let bundle = Bundle(for: type(of: self))
        let url = bundle.url(forResource: "articleSingle", withExtension: "json")
        let jsonData = try! Data(contentsOf: url!)
        let JSON = try! JSONSerialization.jsonObject(with: jsonData, options: []) as! [String:Any]
        let article: Article?
        do{
            article = try Article(json: JSON)
            XCTAssertEqual(article?.webUrl, "https://www.nytimes.com/2017/04/04/world/asia/here-lies-a-graveyard-where-east-and-west-came-together.html")
            XCTAssertEqual(article?.title, "Here Lies a Graveyard Where ‘East and West Came Together’")
            XCTAssertNotNil(article?.media)
            XCTAssertEqual(article?.media?.url, "images/2017/04/01/world/03singapore-1/03singapore-1-thumbStandard.jpg")
            XCTAssertEqual(article?.media?.width, 75)
            XCTAssertEqual(article?.media?.height, 75)
            XCTAssertEqual(article?.media?.subtype, "thumbnail")
            XCTAssertEqual(article?.media?.type, "image")

        }catch{
            XCTFail("no response")
        }
    }
    
    func testArticles() {
    
        let bundle = Bundle(for: type(of: self))
        let url = bundle.url(forResource: "articles", withExtension: "json")
        let jsonData = try! Data(contentsOf: url!)
        let JSON = try! JSONSerialization.jsonObject(with: jsonData, options: []) as! [String:Any]
        let articleResponse : ArticleResponse?
        do{
            articleResponse = try ArticleResponse(json: JSON)
            let articles = articleResponse?.articles
            XCTAssertEqual(articles?.count, 10)
            let article = articles?.first
            XCTAssertEqual(article?.webUrl, "https://www.nytimes.com/2017/04/04/world/asia/here-lies-a-graveyard-where-east-and-west-came-together.html")
            XCTAssertEqual(article?.title, "Here Lies a Graveyard Where ‘East and West Came Together’")
            XCTAssertNotNil(article?.media)
            XCTAssertEqual(article?.media?.url, "images/2017/04/01/world/03singapore-1/03singapore-1-thumbStandard.jpg")
            XCTAssertEqual(article?.media?.width, 75)
            XCTAssertEqual(article?.media?.height, 75)
            XCTAssertEqual(article?.media?.subtype, "thumbnail")
            XCTAssertEqual(article?.media?.type, "image")
        }catch{
            XCTFail("no response")
        }
    }
}
