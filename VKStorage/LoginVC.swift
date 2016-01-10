//
//  LoginVC.swift
//  VKStorage
//
//  Created by Mike on 1/5/16.
//  Copyright © 2016 BIBORAM. All rights reserved.
//

import Foundation
import UIKit

let MAIN_TAB_BAR_VC_VIEW_DID_APPEAR = "mainTabBarVCViewDidAppear"

class LoginVC: UIViewController {

  var loginButton: UIButton!
  
  
  
  override func loadView() {
    self.view = UIView.loadFromNibNamed("LoginVC")!
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    loginButton = view.subviews[0] as! UIButton
    loginButton.addTarget(self, action: "didTapLoginButton:", forControlEvents: .TouchUpInside)
    CurrentUser.sharedCurrentUser().loginLoadingStateDelegate = self
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func didTapLoginButton(sender: UIButton) {
    CurrentUser.sharedCurrentUser().login()
  }
  
  func pushMainVC() {
    dispatch_async(dispatch_get_main_queue()) { () -> Void in
      let mainTabBarVC = MainTabBarVC()
      let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
      let rootVCView = appDelegate.window?.rootViewController?.view
      UIView.transitionFromView(rootVCView!,
        toView: mainTabBarVC.view,
        duration: 0.5,
        options: UIViewAnimationOptions.TransitionCrossDissolve,
        completion: { (complete: Bool) -> Void in
          if complete {
            NSNotificationCenter.defaultCenter().addObserver(self, name: MAIN_TAB_BAR_VC_VIEW_DID_APPEAR, object: nil, handler: { (observer, notification) -> Void in
              appDelegate.window?.rootViewController = mainTabBarVC
            })
          }
      })
    }
  }

  
}

extension LoginVC : LoadingStateDelegate {

  func didEndNetworingActivity() {
    if let loadingView = UIViewController.currentViewController().view.viewWithTag(LoadingIndicatorViewTag) as? LoadingIndicatorView {
      loadingView.toggleTickWithTimeIntervalExpirationBlock({ () -> Void in
        self.pushMainVC()
      })
    }
  }
  
}