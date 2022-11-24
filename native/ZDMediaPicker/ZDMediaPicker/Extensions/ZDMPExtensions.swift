//
//  Extensions.swift
//  LImitedPhotosGallery
//
//  Created by lakshmi-12493 on 05/04/22.
//

import Foundation
import UIKit
import PhotosUI


enum VerticalScrollDirection {
    case up
    case down
}
extension UICollectionView{
    func scrollView(with direction : VerticalScrollDirection){
        UIViewPropertyAnimator.init(duration: 0.3, curve: .linear) {
            let yPoint = direction == .down ? self.contentOffset.y + 20 : self.contentOffset.y - 20
            let contentOffset = CGPoint.init(x: self.contentOffset.x, y: yPoint)
            self.scrollRectToVisible(CGRect(x: contentOffset.x, y: contentOffset.y, width: self.frame.width, height: self.frame.height), animated: false)
            self.layoutIfNeeded()
        }.startAnimation()
    }
}

extension TimeInterval{
    
    func timeFormatted() -> String {
        let seconds: Int = lround(self)
        var hour: Int = 0
        var minute: Int = Int(seconds/60)
        let second: Int = seconds % 60
        if minute > 59 {
            hour = minute / 60
            minute = minute % 60
            return String(format: "%d:%d:%02d", hour, minute, second)
        } else {
            return String(format: "%d:%02d", minute, second)
        }
    }
    
    
}

#warning("Update the method for getting number of photos per row")
extension UIView {
    func getNumberofPhotosPerRow()-> CGFloat{
        if self.frame.width < 500{ //TO DO: Lak
            return 3
        }
        else if self.frame.width <= 1024{
            return 5
        }
        else {
            return 7
        }
    }
}

extension UINavigationController {
    func enableRTL(){
        self.view.semanticContentAttribute =  .forceRightToLeft //: .forceLeftToRight
        self.navigationBar.semanticContentAttribute =  .forceRightToLeft //: .forceLeftToRight
    }
}
