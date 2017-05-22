//
//  ArticleListViewControllerTests.swift
//  NYTimes
//
//  Created by NCS-zdq on 20/4/17.
//  Copyright © 2017 zdq. All rights reserved.
//

import XCTest
@testable import NYTimes
import CoreData

class ArticleListViewControllerMock: ArticleListViewController {
    var loadExpectation: XCTestExpectation!
    var segueIdentifier: String?
    override func reloadData() {
        super.reloadData()
        loadExpectation.fulfill()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segueIdentifier = segue.identifier
        super.prepare(for: segue, sender: sender)
    }
}

class ArticleListViewControllerTests: BaseViewControllerTests {
    
    var navigationController:UINavigationController!
    var viewController: ArticleListViewController!
    
    override func setUp() {
        super.setUp()
        sleep(8)
        navigationController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as! UINavigationController
        
        self.viewController = self.navigationController.topViewController as! ArticleListViewController!
        XCTAssertNotNil(self.viewController)
        let _ = self.viewController.view
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        navigationController = nil
        viewController = nil
        super.tearDown()
    }
    
    func testCollectionViewIsNotNil() {
        XCTAssertNotNil(viewController.collectionView)
    }
    
    func testShouldSetCollectionViewdataSource() {
        XCTAssertNotNil(viewController.collectionView.dataSource)
    }
    
    func testConformsToCollectionViewDataSource() {
        XCTAssert(viewController.conforms(to: UICollectionViewDataSource.self))
        XCTAssertTrue(viewController.responds(to: #selector(viewController.numberOfSections(in:))))
        XCTAssertTrue(viewController.responds(to: #selector(viewController.collectionView(_:numberOfItemsInSection:))))
        XCTAssertTrue(viewController.responds(to: #selector(viewController.collectionView(_:cellForItemAt:))))
    }
    
    
    func testShouldSetCollectionViewDelegate() {
        XCTAssertNotNil(viewController.collectionView.delegate)
    }
    
    func testConformsToCollectionViewDelegate() {
        XCTAssert(viewController.conforms(to: UICollectionViewDelegate.self))
        XCTAssertTrue(viewController.responds(to: #selector(viewController.collectionView(_:didSelectItemAt:))))
    }
    
    func testConformsToCollectionViewDelegateFlowLayout () {
        XCTAssert(viewController.conforms(to: UICollectionViewDelegateFlowLayout.self))
        XCTAssertTrue(viewController.responds(to: #selector(viewController.collectionView(_:layout:sizeForItemAt:))))
        XCTAssertTrue(viewController.responds(to: #selector(viewController.collectionView(_:layout:minimumLineSpacingForSectionAt:))))
    }
    
    func testConformsToSearchBarDelegate() {
        XCTAssert(viewController.conforms(to: UISearchBarDelegate.self))
        XCTAssertTrue(viewController.responds(to: #selector(viewController.searchBarTextDidBeginEditing(_:))))
        XCTAssertTrue(viewController.responds(to: #selector(viewController.searchBarTextDidEndEditing(_:))))
        XCTAssertTrue(viewController.responds(to: #selector(viewController.searchBarSearchButtonClicked(_:))))
    }
    
    func testAfterViewDidLoad(){
        let controller = ArticleListViewControllerMock()
        controller.searchView = viewController.searchView
        controller.collectionView = self.viewController.collectionView
        controller.collectionView.delegate = controller
        controller.collectionView.dataSource = controller
        controller.loadExpectation = expectation(description: "reload data")
        controller.loadArticles()
        waitForExpectations(timeout: 30.0, handler: nil)
        
        XCTAssertNotNil(controller.articles)
        XCTAssertGreaterThan(controller.articles.count, 0)
        
//        XCTAssertEqual(controller.collectionView(controller.collectionView, numberOfItemsInSection:0), controller.articles.count + 1)
//        let collectionViewCell = controller.collectionView(controller.collectionView, cellForItemAt:IndexPath(row: 0, section: 0))
//        XCTAssertNotNil(collectionViewCell)
    }

    func testloadMoreArticles(){
        
        let controller = ArticleListViewControllerMock()
        controller.searchView = viewController.searchView
        controller.collectionView = self.viewController.collectionView
        controller.collectionView.delegate = controller
        controller.collectionView.dataSource = controller
        controller.loadExpectation = expectation(description: "reload data")
        controller.loadArticles()
        waitForExpectations(timeout: 30.0, handler: nil)
        
        let count = controller.articles.count
        controller.loadExpectation = expectation(description: "reload more data")
        controller.loadMoreArticles()
        waitForExpectations(timeout: 10.0, handler: nil)
        XCTAssertEqual(controller.currentPage, 1)
        XCTAssertGreaterThan(controller.articles.count, count)
        
        XCTAssertEqual(controller.collectionView(controller.collectionView, numberOfItemsInSection:0), controller.articles.count + 1)
        
    }
    
    func testIfSearchHistoryIsEmpty() {
        let controller = ArticleListViewControllerMock()
        controller.searchView = viewController.searchView
        controller.collectionView = self.viewController.collectionView
        controller.collectionView.delegate = controller
        controller.collectionView.dataSource = controller
        
        controller.searchHistories.removeAll()
        controller.loadExpectation = expectation(description: "reload search history")
        controller.reloadData()
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertEqual(controller.collectionView(controller.collectionView, numberOfItemsInSection:0), 0)
    }
    
    func testIfSearchHistoriesIsNotEmpty() {
        let controller = ArticleListViewControllerMock()
        controller.searchView = viewController.searchView
        controller.searchBar = viewController.searchBar

        controller.collectionView = self.viewController.collectionView
        controller.collectionView.delegate = controller
        controller.collectionView.dataSource = controller
        controller.searchText = self.viewController.searchText
        DatabaseManager.shareDatabaseManager.deleteAllSearchHistory()
        DatabaseManager.shareDatabaseManager.saveSearchHistory(keyword:  "Japan")
        DatabaseManager.shareDatabaseManager.saveSearchHistory(keyword:  "Singapore")
        
        controller.searchHistories = DatabaseManager.shareDatabaseManager.getSearchHistoryList()
        controller.isSearching = true
        let searchHistory = viewController.searchHistories[0]
        controller.loadExpectation = expectation(description: "searching article")
        controller.collectionView(controller.collectionView, didSelectItemAt: IndexPath(row: 0, section: 0))
        waitForExpectations(timeout: 10.0, handler: nil)
        XCTAssertEqual(controller.searchText, searchHistory.keyword)
        XCTAssertEqual(controller.articles.count, 10)
    }
    
    func testSelectingArticleCellPushesArticleDetailsView(){
        let controller = ArticleListViewControllerMock()
        controller.selectIndex = 0
        let articlePagesViewController = ArticlePagesViewController()
        let segue = UIStoryboardSegue(identifier: "ArticleDetails",
                                      source: controller,
                                      destination: articlePagesViewController)
        XCTAssertEqual(navigationController.viewControllers.count, 1)
        controller.isSearching = false
        controller.prepare(for: segue, sender: nil)

        if let identifier = controller.segueIdentifier {
            XCTAssertEqual("ArticleDetails", identifier)
        }
        else {
            XCTFail("Segue should be performed")
        }
    }
    
    func testArgumentToPassIsPassedOnSegue(){
        let controller = ArticleListViewControllerMock()
        controller.selectIndex = 0
        let articlePagesViewController = ArticlePagesViewController()
        let segue = UIStoryboardSegue(identifier: "ArticleDetails",
                                      source: controller,
                                      destination: articlePagesViewController)
        controller.prepare(for: segue, sender: nil)

        if let identifier = controller.segueIdentifier {
            XCTAssertEqual("ArticleDetails", identifier)
        }
        else {
            XCTFail("Segue should be performed")
        }
        XCTAssertEqual(articlePagesViewController.index, 0)
        XCTAssertNotNil(articlePagesViewController.articles)
    }
}
