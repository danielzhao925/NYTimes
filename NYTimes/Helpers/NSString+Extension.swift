

import UIKit

extension NSString {
    class func boundingRectWithString(_ string: NSString, size: CGSize, fontSize: CGFloat) -> CGFloat {
        return string.boundingRect(with: size, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: fontSize)], context: nil).size.height
    }
}
