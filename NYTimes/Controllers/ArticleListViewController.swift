

import UIKit
import CoreData

private let articleNoImageCellreuseIdentifier = "ArticleNoImageCell"
private let articleMiddleImageCellreuseIdentifier = "ArticleMiddleImageCell"
private let articleLoadMorereuseIdentifier = "ArticleLoadMoreCell"

private let searchKeywordCellreuseIdentifier = "SearchKeywordCell"

class ArticleListViewController: UIViewController {

    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var searchHistoryArray: [SearchHistory] = []
    
    var articleArray: [Article] = [Article]()
    var currentPage: Int = 0
    
    var selectIndex:Int = 0
    
    var isSearching:Bool = false
    
    var searchText: String = ""
    
    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.autocorrectionType = .no
        searchController.searchBar.spellCheckingType = .no
        searchController.searchBar.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        return searchController
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "NT Times"
        self.searchView.addSubview(self.searchController.searchBar)
        
        self.searchController.searchBar.sizeToFit()
        definesPresentationContext = true
        
        self.searchText = "Singapore"
        self.currentPage = 0
        loadArticleArray(searchText: self.searchText, page: self.currentPage)
        
        self.searchHistoryArray = getSearchHistoryList()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let articlePagesViewController = segue.destination as! ArticlePagesViewController
        articlePagesViewController.articleArray = self.articleArray
        articlePagesViewController.index = self.selectIndex

    }
    
    func loadArticleArray(searchText: String, page:Int, completion: (()->())? = nil) {
        ProgressHUD.show(.loading, text: "Loading")
        WebServiceManager.shareWebServiceManager.getArticleArray(searchText, page) { (jsonResponse) in
            
            ProgressHUD.dismiss()
            
            guard let response = jsonResponse["response"] as? [String: Any],
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
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
            
            if (completion != nil) {
                completion!()
            }
            
        }
    }
    
    func loadMoreData(completion: (()->())? = nil){
        self.currentPage += 1
        loadArticleArray(searchText: self.searchText, page: self.currentPage, completion: completion)
    }
    
    func getSearchHistoryList() -> [SearchHistory] {
    
        var searchHistoryArray: [SearchHistory] = []

        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return searchHistoryArray
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<SearchHistory>(entityName: "SearchHistory")
        
        //3
        do {
            searchHistoryArray = try managedContext.fetch(fetchRequest)
            //            self.collectionView?.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return searchHistoryArray

    }
    
    //save search history
    func saveSearchHistory(keyword: String) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity =
            NSEntityDescription.entity(forEntityName: "SearchHistory",
                                       in: managedContext)!
        
        let searchHistory = SearchHistory(entity: entity,
                                          insertInto: managedContext)
        
        searchHistory.setValue(keyword, forKeyPath: "keyword")
        
        do {
            try managedContext.save()
            searchHistoryArray.append(searchHistory)
            //            self.collectionView?.reloadData()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

}

// MARK: UISearchBarDelegate
extension ArticleListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        debugPrint("searchBarSearchButtonClicked")
        self.searchText = searchBar.text!
        isSearching = false
        articleArray.removeAll()
        self.saveSearchHistory(keyword: searchBar.text!)
        self.loadArticleArray(searchText: self.searchText, page: 0)
    }
    
}

// MARK: UISearchControllerDelegate
extension ArticleListViewController: UISearchControllerDelegate{
    
    @available(iOS 8.0, *)
    public func willPresentSearchController(_ searchController: UISearchController){
        isSearching = true
        if searchHistoryArray.count > 0 {
            self.collectionView.reloadData()
        }
    }
    
    @available(iOS 8.0, *)
    public func willDismissSearchController(_ searchController: UISearchController){
        isSearching = false
        self.collectionView.reloadData()
    }
    
}

// MARK: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension ArticleListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isSearching {
            return self.searchHistoryArray.count
        }
        if self.articleArray.count > 0 {
            return self.articleArray.count + 1
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let searchKeywordCell = collectionView.dequeueReusableCell(withReuseIdentifier: searchKeywordCellreuseIdentifier, for: indexPath) as! SearchKeywordCell
        
        if isSearching {
            let searchHistory = searchHistoryArray[indexPath.row]
            searchKeywordCell.keywordLabel.text = searchHistory.keyword
            return searchKeywordCell
        }
        else{
            
            if indexPath.row == articleArray.count {
                self.loadMoreData()
                let articleLoadMoreCell = collectionView.dequeueReusableCell(withReuseIdentifier: articleLoadMorereuseIdentifier, for: indexPath)
                return articleLoadMoreCell
            }
            
            let article = articleArray[indexPath.row]

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
            let searchHistory = searchHistoryArray[indexPath.row]
            isSearching = false
            self.loadArticleArray(searchText: searchHistory.keyword!, page: 0)
            return
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
            if indexPath.row == self.articleArray.count {
                return CGSize(width: collectionView.bounds.width, height: 50);
            }
            //article cell
            let article = articleArray[indexPath.row]
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
