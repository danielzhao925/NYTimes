//
//  ArticleDetailsViewControllerTests.swift
//  NYTimes
//
//  Created by NCS-zdq on 15/4/17.
//  Copyright © 2017 zdq. All rights reserved.
//

import XCTest
@testable import NYTimes
import WebKit

class ArticleDetailsViewControllerTests: BaseViewControllerTests {
    
    var viewController: ArticleDetailsViewController!

    override func setUp() {
        super.setUp()
        viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ArticleDetailsViewController") as! ArticleDetailsViewController
        let _ = viewController.view
        XCTAssertNotNil(viewController)
        viewController.viewDidLoad()
        XCTAssertNotNil(viewController.webView)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        viewController = nil
        super.tearDown()
    }
    
    func testCanInstantiateViewController() {
        XCTAssertNotNil(viewController)
    }
    
    func testAfterViewDidLoad()
    {
//        self.viewController.article = self.article!
//        XCTAssertNotNil(articleArray)
//        XCTAssertNotEqual(articleArray.count, 0)
//        viewController.article = articleArray[0]
//        viewController.viewDidLoad()
//        XCTAssertNotNil(viewController.webView)
//        XCTAssertNotNil(viewController.article)
//        XCTAssertEqual(viewController.pageIndex, 0)
    }
    
    func testShouldSetWebViewWKNavigationDelegate() {
        XCTAssertNotNil(viewController.webView.navigationDelegate)
    }
    
    func testConformsToWebViewUIDelegate() {
        XCTAssert(viewController.conforms(to: WKNavigationDelegate.self))
        XCTAssertTrue(viewController.responds(to: #selector(viewController.webView(_:didStartProvisionalNavigation:))))
        XCTAssertTrue(viewController.responds(to: #selector(viewController.webView(_:didFinish:))))
        XCTAssertTrue(viewController.responds(to: #selector(viewController.webView(_:didFail:withError:))))
    }
    

}
