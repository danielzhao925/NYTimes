//
//  ArticlePagesViewControllerTests.swift
//  NYTimes
//
//  Created by NCS-zdq on 20/4/17.
//  Copyright © 2017 zdq. All rights reserved.
//

import XCTest
@testable import NYTimes

class ArticlePagesViewControllerMock: ArticlePagesViewController {
    
}

class ArticlePagesViewControllerTests: BaseViewControllerTests {
    
    var viewController: ArticlePagesViewController!
    
    override func setUp() {
        super.setUp()
        viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ArticlePagesViewController") as! ArticlePagesViewController
        XCTAssertNotNil(viewController)
        let _ = viewController.view
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        viewController = nil
        super.tearDown()
    }
    
    func testConformsToPageViewControllerDataSource() {
 
        XCTAssert(viewController.conforms(to: UIPageViewControllerDataSource.self))
        XCTAssertTrue(viewController.responds(to: #selector(viewController.pageViewController(_:viewControllerBefore:))))
        XCTAssertTrue(viewController.responds(to: #selector(viewController.pageViewController(_:viewControllerAfter:))))
    }
    
    func testPageScrolling() {
        
//        let articles = self.articles()
//        XCTAssertNotNil(articles)
//        XCTAssertEqual(articles?.count, 10)
////        viewController.didm
//        viewController.articles = articles
//        viewController.index = 3
//        viewController.pageViewController(<#T##pageViewController: UIPageViewController##UIPageViewController#>, viewControllerAfter: <#T##UIViewController#>)
//        XCTAssertNotNil(articles)
//        viewController.articles = articles
//        viewController.setViewControllers([viewController.getViewControllerAtIndex(index: 0)] as [UIViewController], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
//        
//        XCTAssertEqual(viewController.index, 0)

    }
    
}
