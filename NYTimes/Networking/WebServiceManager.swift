

import UIKit
struct WebServiceContants {
    
    static let baseApiURL = "https://api.nytimes.com/svc/search/v2/"
    static let baseWebURL = "https://www.nytimes.com/"
    static let articleSearch = "articlesearch.json"
    static let apiKey = "b5da8ca0bad244458c93ea0ba639ed5c"
    //"b5da8ca0bad244458c93ea0ba639ed5c"
    //"392fa1d2fc8245d6893fc51d394cf98c"
    
}

class WebServiceManager: NSObject {
    
    static let shareWebServiceManager = WebServiceManager()
    let networking = Networking(baseURL: WebServiceContants.baseApiURL)
   
    func getArticles(_ page: Int, _ searchText: String?, _ completion:@escaping ([Article]?)->()) {
        let params = ["api-key": WebServiceContants.apiKey,
                      "q": searchText ?? "",
                      "page": page] as [String : Any]
        
        self.networking.get(WebServiceContants.articleSearch, parameters:params ) { result in
            switch result {
            case .success(let response):
                let json = response.dictionaryBody
        
                guard let response = json["response"] as? [String: Any],
                    let docs = response["docs"] as? [[String: Any]]
                    else{
                        return
                }
                var articles = [Article]()
                for JSON in docs {
                    do{
                        try articles.append(Article(json: JSON)!)
                    }
                    catch{
                        
                    }
                }
                completion(articles)
                
            case .failure:
                completion(nil)
                break
            }
        }
    }
}
