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
    
    override func reloadData() {
        super.reloadData()
        loadExpectation.fulfill()
    }
}


class ArticleListViewControllerTests: XCTestCase {
    
    var navigationController:UINavigationController!
    var viewController: ArticleListViewController!

    override func setUp() {
        super.setUp()
        
        navigationController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as! UINavigationController
        
        viewController = navigationController.topViewController as! ArticleListViewController!
        XCTAssertNotNil(viewController)
        let _ = viewController.view
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        navigationController = nil
        viewController = nil
        super.tearDown()
    }
    
//    func testData(){
//    
//        do{
//            let json = try! JSON.from("testData.json", bundle: Bundle(for: JSONTests.self)) as? [String : Any]  ?? [String : Any]()
//            guard let response = json["response"] as? [String: Any],
//                let docs = response["docs"] as? [[String: Any]]
//                else{
//                    return
//            }
//            for JSON in docs {
//                do{
//                    try self.articleArray.append(Article(json: JSON)!)
//                }
//                catch{
//                    
//                }
//            }
//        }catch{
//            
//        }
//
//        
//    }
//
    
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
    
    func testAfterViewDidLoad()
    {
        let controller = ArticleListViewControllerMock()
        controller.searchView = viewController.searchView
        controller.loadExpectation = expectation(description: "reload data")
        controller.collectionView = self.viewController.collectionView
        XCTAssertNotNil(controller.collectionView)
        controller.viewDidLoad()
        waitForExpectations(timeout: 10.0, handler: nil)
        XCTAssertNotNil(controller.articles)
        XCTAssertGreaterThan(controller.articles.count, 0)
    }
    
    func testCollectionViewAfterViewDidLoad(){
        let controller = ArticleListViewControllerMock()
        controller.searchView = viewController.searchView
        controller.loadExpectation = expectation(description: "reload data")
        controller.collectionView = self.viewController.collectionView
        controller.collectionView.delegate = controller
        controller.collectionView.dataSource = controller
        
        XCTAssertNotNil(controller.collectionView)
        controller.viewDidLoad()
        
        waitForExpectations(timeout: 10.0, handler: nil)
        XCTAssertEqual(controller.collectionView(controller.collectionView, numberOfItemsInSection:0), controller.articles.count + 1)
        let collectionViewCell = controller.collectionView(controller.collectionView, cellForItemAt:IndexPath(row: 0, section: 0))
        XCTAssertNotNil(collectionViewCell)
    }

    func testloadMoreArticles(){
        let controller = ArticleListViewControllerMock()
        controller.searchView = viewController.searchView
        controller.loadExpectation = expectation(description: "reload data")
        controller.collectionView = self.viewController.collectionView
        controller.collectionView.delegate = controller
        controller.collectionView.dataSource = controller
        
        XCTAssertNotNil(controller.collectionView)
        controller.viewDidLoad()
        waitForExpectations(timeout: 10.0, handler: nil)

        let count = controller.articles.count
        
        controller.loadExpectation = expectation(description: "reload more data")
        controller.loadMoreArticles()
        waitForExpectations(timeout: 10.0, handler: nil)
        XCTAssertEqual(controller.currentPage, 1)
        XCTAssertGreaterThan(controller.articles.count, count)
        
        XCTAssertEqual(controller.collectionView(controller.collectionView, numberOfItemsInSection:0), controller.articles.count + 1)
        
    }
    
    func testIfSearchHistoryIsEmpty() {
        viewController.isSearching = true
        XCTAssertEqual(viewController.searchHistories.count, 0)
        viewController.collectionView.reloadData()
    }
    
    func testIfSearchHistoryIsNotEmpty() {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity =
            NSEntityDescription.entity(forEntityName: "SearchHistory",
                                       in: managedContext)!
        let searchHistory1 = SearchHistory(entity: entity,
                                          insertInto: managedContext)
        searchHistory1.setValue("Japan", forKeyPath: "keyword")
        
        let searchHistory2 = SearchHistory(entity: entity,
                                          insertInto: managedContext)
        searchHistory2.setValue("Singapore", forKeyPath: "keyword")

        viewController.searchHistories = [searchHistory1,searchHistory2]
        viewController.isSearching = true
        viewController.collectionView.reloadData()
        viewController.collectionView(viewController.collectionView, didSelectItemAt: IndexPath(row: 0, section: 0))
        
        let testExpectation = expectation(description: "Load Article base on searching")
        
        XCTAssertEqual(viewController.searchText, "Japan")
//        viewController.loadArticles() {
//            testExpectation.fulfill()
//        }
        waitForExpectations(timeout: 15.0, handler: nil)
        XCTAssertEqual(viewController.articles.count, 10)

    }
    
//    func testSelectingArticleCellPushesArticleDetailsView(){
//        viewController.view.layoutSubviews()
//        XCTAssertEqual(navigationController.viewControllers.count, 1)
//        viewController.isSearching = false
//        viewController.collectionView(viewController.collectionView, didSelectItemAt: IndexPath(row: 0, section: 0))
//        navigationController.updateFocusIfNeeded()
//        XCTAssertEqual(navigationController.viewControllers.count, 2)
//        XCTAssertEqual(String(describing: type(of: navigationController.topViewController)),String(describing: type(of: ArticlePagesViewController.self)))
//    }

}
