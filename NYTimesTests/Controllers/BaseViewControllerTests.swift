//
//  BaseViewControllerTests.swift
//  NYTimes
//
//  Created by NCS-zdq on 17/5/17.
//  Copyright © 2017 zdq. All rights reserved.
//

import XCTest
@testable import NYTimes

class BaseViewControllerTests: XCTestCase {
    
    open var articles : [Article?]!
    var article  : Article?

    override func setUp() {
        super.setUp()
        
        self.articles = getArticles()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func getArticles() -> [Article] {
        
        let bundle = Bundle(for: type(of: self))
        let url = bundle.url(forResource: "articles", withExtension: "json")
        let jsonData = try! Data(contentsOf: url!)
        let JSON = try! JSONSerialization.jsonObject(with: jsonData, options: []) as! [String:Any]
        
        var articles = [Article]()
        
        do{
            guard let articleResponse = try ArticleResponse(json: JSON),
                let articlesTmp = articleResponse.articles
                else{
                    return articles
            }
            for article in articlesTmp {
                articles.append(article)
            }
        }catch{
            
        }
        return articles
    }
    
    func getArticleSingle() throws -> Article?  {
        
        let bundle = Bundle(for: type(of: self))
        let url = bundle.url(forResource: "articleSingle", withExtension: "json")
        let jsonData = try! Data(contentsOf: url!)
        let JSON = try! JSONSerialization.jsonObject(with: jsonData, options: []) as! [String:Any]
        
//        do{
            if let article = try Article(json: JSON)
            {
                    return article
            }
//            return nil
//        }catch{
//            
//        }
        return nil
    }
}
