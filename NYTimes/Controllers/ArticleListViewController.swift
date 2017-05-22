

import UIKit
import CoreData

private let articleNoImageCellreuseIdentifier = "ArticleNoImageCell"
private let articleMiddleImageCellreuseIdentifier = "ArticleMiddleImageCell"
private let articleLoadMorereuseIdentifier = "ArticleLoadMoreCell"

private let searchKeywordCellreuseIdentifier = "SearchKeywordCell"

class ArticleListViewController: UIViewController {

    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var searchHistories = [SearchHistory]()
    
    var articles = [Article]()
    var currentPage: Int = 0
    
    var selectIndex: Int = 0
    
    var isSearching: Bool = false
    
    var searchText: String = ""
    
    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
//        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.autocorrectionType = .no
        searchController.searchBar.spellCheckingType = .no
        searchController.searchBar.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        return searchController
    }()
    
    var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "NT Times"
        self.searchBar = self.searchController.searchBar
        self.searchView.addSubview(self.searchBar)
        self.searchBar.sizeToFit()
        definesPresentationContext = true
        
        self.searchText = "Singapore"
        self.currentPage = 0
        loadArticles()
        
        searchHistories = DatabaseManager.shareDatabaseManager.getSearchHistoryList()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        debugPrint("view will appear")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let articlePagesViewController = segue.destination as! ArticlePagesViewController
        articlePagesViewController.articles = self.articles
        articlePagesViewController.index = self.selectIndex
    }
    
    func loadArticles() {
        debugPrint("load articles...")
        if self.currentPage == 0 {
            self.articles.removeAll()
        }
        ProgressHUD.show(.loading, text: "Loading")
        WebServiceManager.shareWebServiceManager.getArticles(self.currentPage, self.searchText) { (articles) in
            ProgressHUD.dismiss()
            if let articles = articles {
                for article in articles {
                    self.articles.append(article)
                }
            }
            self.reloadData()
        }
    }
    
    func loadMoreArticles(){
        self.currentPage += 1
        loadArticles()
    }
    
    func reloadData(){
        self.collectionView.reloadData()
    }
}

// MARK: UISearchBarDelegate
extension ArticleListViewController: UISearchBarDelegate {

    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar){
    
        isSearching = true
        searchHistories = DatabaseManager.shareDatabaseManager.getSearchHistoryList()
        if searchHistories.count > 0 {
            self.reloadData()
        }
    }
    
    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar){
        isSearching = false
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            self.searchText = searchText
            isSearching = false
            articles.removeAll()
            DatabaseManager.shareDatabaseManager.saveSearchHistory(keyword:  self.searchText)
            self.currentPage = 0
            
            self.loadArticles()
        }
    }
}

// MARK: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension ArticleListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isSearching {
            return self.searchHistories.count
        }
        if self.articles.count > 0 {
            return self.articles.count + 1
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let searchKeywordCell = collectionView.dequeueReusableCell(withReuseIdentifier: searchKeywordCellreuseIdentifier, for: indexPath) as! SearchKeywordCell
        
        if isSearching {
            let searchHistory = searchHistories[indexPath.row]
            searchKeywordCell.keywordLabel.text = searchHistory.keyword
            return searchKeywordCell
        }
        else{
            
            if indexPath.row == articles.count {
                self.loadMoreArticles()
                let articleLoadMoreCell = collectionView.dequeueReusableCell(withReuseIdentifier: articleLoadMorereuseIdentifier, for: indexPath)
                return articleLoadMoreCell
            }
            
            let article = articles[indexPath.row]

            if article.media != nil {
                let articleMiddleImageCell = collectionView.dequeueReusableCell(withReuseIdentifier: articleMiddleImageCellreuseIdentifier, for: indexPath) as! ArticleMiddleImageCell
                articleMiddleImageCell.article = article
                
                return articleMiddleImageCell
            }else{
                let articleNoImageCell = collectionView.dequeueReusableCell(withReuseIdentifier: articleNoImageCellreuseIdentifier, for: indexPath) as! ArticleNoImageCell
                articleNoImageCell.article = article
                
                return articleNoImageCell

            }
            
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        
        if isSearching {
            let searchHistory = searchHistories[indexPath.row]
            if let keyword = searchHistory.keyword {
                isSearching = false
                self.currentPage = 0
                self.searchText = keyword
                self.searchBar.text = self.searchText
                self.searchBar.resignFirstResponder()
                self.loadArticles()
                return
            }
        }
        self.selectIndex = indexPath.row
        self.performSegue(withIdentifier: "ArticleDetails", sender: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if isSearching {
            return CGSize(width: collectionView.bounds.width, height: 45.0);
        }
        else{
            //load more cell
            if indexPath.row == self.articles.count {
                return CGSize(width: collectionView.bounds.width, height: 50);
            }
            //article cell
            let article = articles[indexPath.row]
            var height:CGFloat = 0
            if article.media != nil {
                
                height = NSString.boundingRectWithString(article.title! as NSString, size: CGSize(width:230, height: CGFloat(MAXFLOAT)), fontSize: 17)
                if height < CGFloat((article.media?.height)!) {
                    height = CGFloat((article.media?.height)!)
                }
            }else{
                height = NSString.boundingRectWithString(article.title! as NSString, size: CGSize(width: 230, height: CGFloat(MAXFLOAT)), fontSize: 17)
            }
            height += 24
            return CGSize(width: collectionView.bounds.width, height: height);
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 2.0
    }
}
