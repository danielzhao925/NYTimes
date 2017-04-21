//
//  ArticlePagesViewControllerTests.swift
//  NYTimes
//
//  Created by NCS-zdq on 20/4/17.
//  Copyright © 2017 zdq. All rights reserved.
//

import XCTest
@testable import NYTimes

class ArticlePagesViewControllerTests: XCTestCase {
    
    var viewController: ArticlePagesViewController!
    var articleArray:[Article]! = [Article]()
    
    override func setUp() {
        super.setUp()
        
        viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ArticlePagesViewController") as! ArticlePagesViewController
        
        do{
            let json = try! JSON.from("testData.json", bundle: Bundle(for: JSONTests.self)) as? [String : Any]  ?? [String : Any]()
            guard let response = json["response"] as? [String: Any],
                let docs = response["docs"] as? [[String: Any]]
                else{
                    return
            }
            for JSON in docs {
                do{
                    try self.articleArray.append(Article(json: JSON)!)
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
    
    func testConformsToPageViewControllerDataSource() {
        
        XCTAssert(viewController.conforms(to: UIPageViewControllerDataSource.self))
        XCTAssertTrue(viewController.responds(to: #selector(viewController.pageViewController(_:viewControllerBefore:))))
        XCTAssertTrue(viewController.responds(to: #selector(viewController.pageViewController(_:viewControllerAfter:))))
    }
    
    func testViewDidLoad() {
        
        XCTAssertNotNil(articleArray)
        viewController.articleArray = articleArray
        viewController.setViewControllers([viewController.getViewControllerAtIndex(index: 0)] as [UIViewController], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
        
        XCTAssertEqual(viewController.index, 0)

    }

    
}
