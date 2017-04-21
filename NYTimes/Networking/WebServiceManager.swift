

import UIKit
struct WebServiceContants {
    
    static let baseApiURL = "https://api.nytimes.com/svc/search/v2/"
    static let baseWebURL = "https://www.nytimes.com/"
    static let articleSearch = "articlesearch.json"
    static let apiKey = "392fa1d2fc8245d6893fc51d394cf98c"
    //"b5da8ca0bad244458c93ea0ba639ed5c"
    
}

class WebServiceManager: NSObject {
    
    static let shareWebServiceManager = WebServiceManager()
   
    func getArticleArray(_ searchText: String?, _ page: Int, _ finished:@escaping ([String : Any])->()) {
        let params = ["api-key": WebServiceContants.apiKey,
                      "q": searchText ?? "",
                      "page": page] as [String : Any]
        
        let networking = Networking(baseURL: WebServiceContants.baseApiURL)
        networking.get(WebServiceContants.articleSearch,parameters:params ) { result in
            switch result {
            case .success(let response):
                let json = response.dictionaryBody
                finished(json)

            case .failure(let response): break
            }
        }
    }
}

extension UIImageView {

    func setImageWithUrl(urlStr: String){
    
        let networking = Networking(baseURL: WebServiceContants.baseWebURL)
        networking.downloadImage(urlStr) { result in
            
            debugPrint("image: \(urlStr)")
            
            switch result {
            case .success(let response):
                debugPrint(response)
                self.image = response.image
            case .failure:
                break
            }
        }
    }
}
