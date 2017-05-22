

import UIKit
struct WebServiceContants {
    
    static let baseApiURL = "https://api.nytimes.com/svc/search/v2/"
    static let baseWebURL = "https://www.nytimes.com/"
    static let articleSearch = "articlesearch.json"
    static let apiKey = "5763846de30d489aa867f0711e2b031c"
    //"b5da8ca0bad244458c93ea0ba639ed5c"
    //"392fa1d2fc8245d6893fc51d394cf98c"
    //"c9ed80d74aa2459393a275342ba3d563"
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
                do{
                    guard let articleResponse = try ArticleResponse(json: json),
                        let articles = articleResponse.articles
                        else{
                            return
                    }
                    completion(articles)
                    
                }catch{
                
                }
                break
            case .failure:
                completion(nil)
                break
            }
        }
    }
}
