//
//  ArticleDetailsViewControllerTests.swift
//  NYTimes
//
//  Created by NCS-zdq on 15/4/17.
//  Copyright © 2017 zdq. All rights reserved.
//

import XCTest
@testable import NYTimes

class ArticleDetailsViewControllerTests: XCTestCase {
    
    var viewController: ArticleDetailsViewController!
    var articleArray:[Article]! = [Article]()

    override func setUp() {
        super.setUp()
        viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ArticleDetailsViewController") as! ArticleDetailsViewController

        do{
            let json = try! JSON.from("testData.json", bundle: Bundle(for: JSONTests.self)) as? [String : Any]  ?? [String : Any]()
            guard let response = json["response"] as? [String: Any],
                let docs = response["docs"] as? [[String: Any]]
                else{
                    return
            }
            for JSON in docs {
                do{
                    try articleArray.append(Article(json: JSON)!)
                }
                catch{
                    
                }
            }
        }catch{
            
        }
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        viewController = nil
        articleArray = nil
        super.tearDown()
    }
    
    func testCanInstantiateViewController() {
        XCTAssertNotNil(viewController)
    }
    
    func testAfterViewDidLoad()
    {
//        XCTAssertNotNil(articleArray)
//        XCTAssertNotEqual(articleArray.count, 0)
//        viewController.article = articleArray[0]
//        viewController.viewDidLoad()
//        XCTAssertNotNil(viewController.webView)
//        XCTAssertNotNil(viewController.article)
//        XCTAssertEqual(viewController.pageIndex, 0)
    }
}
