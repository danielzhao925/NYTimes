

import UIKit

class ArticleNoImageCell: ArticleBaseCell {
    
    
    var article: Article? {
        didSet{
            titleLabel.text = article?.title as String?
        }
    }
    
}
