//
//  Extentions.swift
//  VKStorage
//
//  Created by Mike on 1/5/16.
//  Copyright © 2016 BIBORAM. All rights reserved.
//

import Foundation

extension String {
  subscript (i: Int) -> Character {
    return self[self.startIndex.advancedBy(i)]
  }
}

extension UIView {
  class func loadFromNibNamed(nibNamed: String, bundle : NSBundle? = nil) -> UIView? {
    return UINib(
      nibName: nibNamed,
      bundle: bundle
      ).instantiateWithOwner(nil, options: nil)[0] as? UIView
  }
}

extension LoadingStateDelegate {
  
  func didStartNetworingActivity() {
    let loadingStateView = LoadingIndicatorView()
    UIViewController.currentViewController().view.addSubview(loadingStateView)
  }
  
  func didEndNetworingActivity() {
    if let loadingView = UIViewController.currentViewController().view.viewWithTag(LoadingIndicatorViewTag) as? LoadingIndicatorView {
      loadingView.toggleTickWithTimeIntervalExpirationBlock({ () -> Void in
      })
    }
  }
  
}

extension UIViewController {
  
  class func currentViewController() -> UIViewController {
    var topController = UIApplication.sharedApplication().keyWindow?.rootViewController
    while ((topController?.presentedViewController) != nil) {
      topController = topController?.presentedViewController
    }
    return topController!
  }
  
}

extension DefaultsKeys {
  static var isLoggedIn = DefaultsKey<Bool>("isLoggedIn")
}