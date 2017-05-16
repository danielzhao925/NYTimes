

import UIKit
import WebKit

class ArticleDetailsViewController: UIViewController {

    fileprivate var webView: WKWebView!
    
    var article: Article!
    
    var pageIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = article.webUrl
        webView = WKWebView(frame: self.view.frame)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.uiDelegate = self
        webView.navigationDelegate = self;
        webView.load(URLRequest(url: URL(string: article.webUrl!)!))
        self.view.addSubview(webView)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        webView.load(URLRequest(url: URL(string: article.webUrl!)!))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
//    self.view.showLoadingActivity(position: "center" as AnyObject)

}

extension ArticleDetailsViewController:WKUIDelegate, WKNavigationDelegate{
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!){
        ProgressHUD.show(.loading,text: "Loading")

    }
    
//    @available(iOS 8.0, *)
//    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!){
//    }
    
    @available(iOS 8.0, *)
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){
        ProgressHUD.dismiss()
    }
    
    
    @available(iOS 8.0, *)
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error){
        ProgressHUD.dismiss()
    }
    
}
