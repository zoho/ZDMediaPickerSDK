//
//  Utility.swift
//  CustomMediaPicker
//
//  Created by lakshmi-12493 on 12/04/22.
//

import Foundation
import UIKit

struct ZDMPUtility {
    
    static func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
    
    static func instantiateViewController(fromStoryboard name : String = ZDMPStoryboardId.ZDMediaPicker, withIdentifier identifier: String, bundleClass : AnyClass = ZDMediaPicker.self) -> UIViewController {
        return UIStoryboard(name: name, bundle: Bundle(for: bundleClass)).instantiateViewController(withIdentifier: identifier)
    }

}
