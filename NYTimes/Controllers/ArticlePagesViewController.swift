

import UIKit

class ArticlePagesViewController: UIPageViewController {

    var articles = [Article]()
    var index:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        
        self.setViewControllers([self.getViewControllerAtIndex(index: self.index)] as [UIViewController], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func detailsViewController() -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: "ArticleDetailsViewController")
    }
    
    func getViewControllerAtIndex(index: NSInteger) -> ArticleDetailsViewController
    {
        // Create a new view controller and pass suitable data.
        let pageContentViewController = self.storyboard?.instantiateViewController(withIdentifier: "ArticleDetailsViewController") as! ArticleDetailsViewController
        pageContentViewController.pageIndex = index
        pageContentViewController.article = articles[index]
        self.title = pageContentViewController.article.title
        return pageContentViewController
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ArticlePagesViewController: UIPageViewControllerDataSource{

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?{
        print("\(viewController)")
        
        let pageContent: ArticleDetailsViewController = viewController as! ArticleDetailsViewController
        
        var index = pageContent.pageIndex
        
        if ((index == 0) || (index == NSNotFound)){
            return nil
        }
        
        index -= 1
        return getViewControllerAtIndex(index: index)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?{
    
        let pageContent: ArticleDetailsViewController = viewController as! ArticleDetailsViewController
        
        var index = pageContent.pageIndex
        
        if (index == NSNotFound){
            return nil
        }
        index += 1
        if (index == articles.count){
            return nil;
        }
        return getViewControllerAtIndex(index: index)
    }
}
