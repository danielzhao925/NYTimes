

import UIKit

class ArticleMiddleImageCell: ArticleBaseCell {
    
    var article: Article? {
        didSet{
            titleLabel.text = article?.title
            self.imageView.image = nil
            if article?.media != nil {
                self.imageView.setImageWithUrl(urlStr: (self.article?.media?.url!)!)
            }
        }
    }
    
}
