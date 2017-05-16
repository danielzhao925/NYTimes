

import UIKit

public class Article: NSObject {
    
    var webUrl: String?
    
    var title:String?
    var media:Media?
    
    public init?(json:[String: Any]) throws{
    
        self.webUrl = json["web_url"] as? String

        if let headline = json["headline"] as? [String: Any],
            let main = headline["main"] as? String{
            self.title = main as String
        }
        
        if let array = json["multimedia"] as? [[String: Any]] {
            for object in array {
                if let media = try Media(json: object) {
                    if media.subtype == "thumbnail" {
                        self.media = media
                    }
                }
            }
        }
        
    }
}

class Media: NSObject {
    
    var url: String?
    var width: Float?
    var height: Float?
    var subtype: String?
    var type: String?
    
    init?(json:[String: Any]) throws{
        
        guard let width = json["width"] as? Float,
            let url = json["url"] as? String,
            let height = json["height"] as? Float,
            let subtype = json["subtype"] as? String,
            let type = json["type"] as? String
            else{
                return nil
        }
        self.url = url
        self.width = width
        self.height = height
        self.subtype = subtype
        self.type = type
    }
}
