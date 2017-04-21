//
//  ArticleListViewControllerTests.swift
//  NYTimes
//
//  Created by NCS-zdq on 20/4/17.
//  Copyright © 2017 zdq. All rights reserved.
//

import XCTest
import CoreData
@testable import NYTimes

class ArticleListViewControllerTests: XCTestCase {
    
    var navigationController:UINavigationController!
    var viewController: ArticleListViewController!
    var articleArray:[Article]! = [Article]()

    override func setUp() {
        super.setUp()
        
        navigationController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as! UINavigationController
        
        viewController = navigationController.topViewController as! ArticleListViewController!
        
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
        
        super.tearDown()
    }
    
    func testCanInstantiateViewController() {
        XCTAssertNotNil(viewController)
    }
    
    func testCollectionViewIsNotNil() {
        viewController.view.layoutIfNeeded()
        XCTAssertNotNil(viewController.collectionView)
    }
    
    func testConformsToCollectionViewDataSource() {
        
        XCTAssert(viewController.conforms(to: UICollectionViewDataSource.self))
        XCTAssertTrue(viewController.responds(to: #selector(viewController.collectionView(_:numberOfItemsInSection:))))
        XCTAssertTrue(viewController.responds(to: #selector(viewController.collectionView(_:cellForItemAt:))))
    }
    
    func testShouldSetCollectionViewDelegate() {
        viewController.view.layoutIfNeeded()
        XCTAssertNotNil(viewController.collectionView.delegate)
    }
    
    func testConformsToCollectionViewDelegate() {
        
        XCTAssert(viewController.conforms(to: UICollectionViewDelegate.self))
        XCTAssertTrue(viewController.responds(to: #selector(viewController.collectionView(_:didSelectItemAt:))))
    }
    
    func testConformsToCollectionViewDelegateFlowLayout () {
        
       XCTAssert(viewController.conforms(to: UICollectionViewDelegateFlowLayout.self))
        XCTAssertTrue(viewController.responds(to: #selector(viewController.collectionView(_:layout:sizeForItemAt:))))
        XCTAssertTrue(viewController.responds(to:#selector(viewController.collectionView(_:layout:minimumLineSpacingForSectionAt:))))
    }
    
    func testConformsToSearchBarDelegate() {
        
        XCTAssert(viewController.conforms(to: UISearchBarDelegate.self))
        XCTAssertTrue(viewController.responds(to: #selector(viewController.searchBarSearchButtonClicked(_:))))
    }
    
    func testConformsToSearchControllerDelegate() {
        
        XCTAssert(viewController.conforms(to: UISearchControllerDelegate.self))
        XCTAssertTrue(viewController.responds(to: #selector(viewController.willPresentSearchController(_:))))
        XCTAssertTrue(viewController.responds(to: #selector(viewController.willDismissSearchController(_:))))
    }

    func testLoadArtcleArray(){
        viewController.view.layoutSubviews()
        XCTAssertEqual(viewController.articleArray.count,0)
        let testExpectation = expectation(description: "Load Article expectation")
        viewController.loadArticleArray(searchText: "Singapore", page: 0) { 
            testExpectation.fulfill()
        }
        waitForExpectations(timeout: 10.0, handler: nil)
        XCTAssertEqual(viewController.articleArray.count,10)
        XCTAssertEqual(viewController.collectionView(viewController.collectionView, numberOfItemsInSection: 0),11)
    }
    
    func testLoadMore(){
        viewController.view.layoutSubviews()
        let testExpectation = expectation(description: "Load expectation")
        viewController.searchText = "Singapore"
        viewController.currentPage = 0
        viewController.loadArticleArray(searchText: viewController.searchText, page: viewController.currentPage) {
            testExpectation.fulfill()
        }
        waitForExpectations(timeout: 10.0, handler: nil)
        XCTAssertEqual(viewController.articleArray.count,10)
        XCTAssertEqual(viewController.collectionView(viewController.collectionView, numberOfItemsInSection: 0),11)
        
        let testLoadMoreExpectation = expectation(description: "Load more expectation")

        viewController.loadMoreData(){
            testLoadMoreExpectation.fulfill()
        }
        waitForExpectations(timeout: 15.0, handler: nil)
        XCTAssertEqual(viewController.articleArray.count,20)
        XCTAssertEqual(viewController.collectionView(viewController.collectionView, numberOfItemsInSection: 0),21)
    }
    
    func testIfArticleArrayIsEmpty() {
        viewController.view.layoutSubviews()
        viewController.viewDidLoad()
        XCTAssertEqual(viewController.articleArray.count, 0)
        viewController.collectionView.reloadData()
    }
    
    func testIfSearchHistoryIsEmpty() {
        viewController.view.layoutSubviews()
        viewController.isSearching = true
        XCTAssertEqual(viewController.searchHistoryArray.count, 0)
        viewController.collectionView.reloadData()
    }
    
    func testIfSearchHistoryIsNotEmpty() {
        viewController.view.layoutSubviews()
        
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

        viewController.searchHistoryArray = [searchHistory1,searchHistory2]
        viewController.isSearching = true
        viewController.collectionView.reloadData()
        viewController.collectionView(viewController.collectionView, didSelectItemAt: IndexPath(row: 0, section: 0))
        
        let testExpectation = expectation(description: "Load Article base on searching")
        
        XCTAssertEqual(viewController.searchText, "Japan")
        viewController.loadArticleArray(searchText: "Japan", page: 0) { 
            testExpectation.fulfill()
        }
        waitForExpectations(timeout: 15.0, handler: nil)
        XCTAssertEqual(viewController.articleArray.count, 10)

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
