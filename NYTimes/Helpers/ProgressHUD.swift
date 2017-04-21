

import UIKit
import Foundation

public typealias HUDCompletedBlock = (Void) -> Void

public enum HUDType {
    case loading
}

public extension ProgressHUD {
    public class func show(_ type: HUDType, text: String, time: TimeInterval? = nil, completion: HUDCompletedBlock? = nil) {
        dismiss()
        instance.registerDeviceOrientationNotification()
        var isNone: Bool = false
        let window = UIWindow()
        window.backgroundColor = UIColor.clear
        let mainView = UIView()
        mainView.layer.cornerRadius = 10
        mainView.backgroundColor = UIColor(red:0, green:0, blue:0, alpha: 0.7)
        
        var headView = UIView()
        headView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        (headView as! UIActivityIndicatorView).startAnimating()
        headView.translatesAutoresizingMaskIntoConstraints = false
        mainView.addSubview(headView)

        // label
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.white
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        mainView.addSubview(label)
        
        var height: CGFloat = 0
        if isNone {
            height = label.frame.height + 30
        } else {
            height = label.frame.height + 70
        }
        let superFrame = CGRect(x: 0, y: 0, width: label.frame.width + 50, height: height)
        window.frame = superFrame
        mainView.frame = superFrame
        
        // image
        if !isNone {
            mainView.addConstraint( NSLayoutConstraint(item: headView, attribute: .centerY, relatedBy: .equal, toItem: mainView, attribute: .centerY, multiplier: 0.6, constant: 0) )
            mainView.addConstraint( NSLayoutConstraint(item: headView, attribute: .centerX, relatedBy: .equal, toItem: mainView, attribute: .centerX, multiplier: 1.0, constant: 0) )
            mainView.addConstraint( NSLayoutConstraint(item: headView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 36) )
            mainView.addConstraint( NSLayoutConstraint(item: headView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 36) )
        }
        // label
        var mainViewMultiplier: CGFloat = 0
        if isNone {
            mainViewMultiplier = 1.0
        } else {
            mainViewMultiplier = 1.5
        }
        mainView.addConstraint( NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: mainView, attribute: .centerY, multiplier: mainViewMultiplier, constant: 0) )
        mainView.addConstraint( NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: mainView, attribute: .centerX, multiplier: 1.0, constant: 0) )
        mainView.addConstraint( NSLayoutConstraint(item: label, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 90) )
        mainView.addConstraint( NSLayoutConstraint(item: label, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0) )
        
        window.windowLevel = UIWindowLevelAlert
        window.center = getCenter()
        window.isHidden = false
        window.addSubview(mainView)
        windowsTemp.append(window)
        
        delayDismiss(time, completion: completion)
    }
    
    public class func dismiss() {
        if let _ = timer {
            timer!.cancel()
            timer = nil
        }
        instance.removeDeviceOrientationNotification()
        windowsTemp.removeAll(keepingCapacity: false)
    }
}

open class ProgressHUD: NSObject {
    fileprivate static var windowsTemp = [UIWindow]()
    fileprivate static var timer: DispatchSourceTimer?
    fileprivate static let instance = ProgressHUD()
    private struct Cache {
        static var imageOfCheckmark: UIImage?
        static var imageOfCross: UIImage?
        static var imageOfInfo: UIImage?
    }
    
    // center
    fileprivate class func getCenter() -> CGPoint {
        let rv = (UIApplication.shared.keyWindow?.subviews.first)!
        if rv.bounds.width > rv.bounds.height {
            return CGPoint(x: rv.bounds.height/2, y: rv.bounds.width/2)
        }
        return rv.center
    }
    
    // delay dismiss
    fileprivate class func delayDismiss(_ time: TimeInterval?, completion: HUDCompletedBlock?) {
        guard let time = time else { return }
        guard time > 0 else { return }
        var timeout = time
        timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: 0),
                                               queue: DispatchQueue.main)// as! DispatchSource
        timer!.scheduleRepeating(wallDeadline: .now(), interval: .seconds(1))
        
        timer!.setEventHandler { _ in
            if timeout <= 0 {
                DispatchQueue.main.async {
                    dismiss()
                    completion?()
                }
            } else {
                timeout -= 1
            }
        }
        timer!.resume()
    }
    
    // register notification
    fileprivate func registerDeviceOrientationNotification() {
        NotificationCenter.default.addObserver(ProgressHUD.instance, selector: #selector(ProgressHUD.transformWindow(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    // remove notification
    fileprivate func removeDeviceOrientationNotification() {
        NotificationCenter.default.removeObserver(ProgressHUD.instance)
    }
    
    // transform
    @objc fileprivate func transformWindow(_ notification: Notification) {
        var rotation: CGFloat = 0
        switch UIDevice.current.orientation {
        case .portrait:
            rotation = 0
        case .portraitUpsideDown:
            rotation = CGFloat(M_PI)
        case .landscapeLeft:
            rotation = CGFloat(M_PI/2)
        case .landscapeRight:
            rotation = CGFloat(M_PI + (M_PI/2))
        default:
            break
        }
        ProgressHUD.windowsTemp.forEach {
            $0.center = ProgressHUD.getCenter()
            $0.transform = CGAffineTransform(rotationAngle: rotation)
        }
    }
    
    // draw
    private class func draw(_ type: HUDType) {
        let checkmarkShapePath = UIBezierPath()
        
        // draw circle
        checkmarkShapePath.move(to: CGPoint(x: 36, y: 18))
        checkmarkShapePath.addArc(withCenter: CGPoint(x: 18, y: 18), radius: 17.5, startAngle: 0, endAngle: CGFloat(M_PI*2), clockwise: true)
        checkmarkShapePath.close()
        
        UIColor.white.setStroke()
        checkmarkShapePath.stroke()
    }

}
