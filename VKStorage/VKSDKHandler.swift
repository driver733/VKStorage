//
//  VKDelegateHandler.swift
//  Quipo
//
//  Created by Mikhail Yakushin on 12/16/15.
//  Copyright © 2015 Mikhail Yakushin. All rights reserved.
//

import Foundation

let VKSDK_ACCESS_AUTHORIZATION_SUCCEEDED = "VKSDK_ACCESS_AUTHORIZATION_SUCCEEDED"
let VKSDK_ACCESS_AUTHORIZATION_FAILED = "VKSDK_ACCESS_AUTHORIZATION_FAILED"
let VKSDK_ACCESS_AUTHORIZATION_STARTED = "VKSDK_ACCESS_AUTHORIZATION_STARTED"
let VKSDK_AUTH_PERMISSIONS = ["friends", "offline", "wall", "docs", "messages"]
let VKSDK_VK_APP_ID = "5217207"

public class VKSDKDelegateHandler: NSObject {
  
  static var sharedInstance = VKSDKDelegateHandler()
  var VKSDKInstance: VKSdk!
  
  private override init() {
    super.init()
    VKSDKInstance = VKSdk.initializeWithAppId(VKSDK_VK_APP_ID)
    VKSDKInstance.registerDelegate(self)
    VKSDKInstance.uiDelegate = self
  }
  
  func setup(completionHandler: (() -> Void)) {
    if !VKSdk.isLoggedIn() {
      VKSdk.wakeUpSession(VKSDK_AUTH_PERMISSIONS) { (state: VKAuthorizationState, _) -> Void in
        completionHandler()
      }
    } else {
      completionHandler()
    }
  }

  
}


// ======================================================= //
// MARK: - VKSdkDelegate
// ======================================================= //
extension VKSDKDelegateHandler: VKSdkDelegate {

  public func vkSdkAccessAuthorizationFinishedWithResult(result: VKAuthorizationResult!) {
    if result.error == nil {
      NSNotificationCenter.defaultCenter().postNotificationName(VKSDK_ACCESS_AUTHORIZATION_SUCCEEDED, object: nil)
    } else {
      // auth failed
    }
  }
  
  @objc public func vkSdkUserAuthorizationFailed() {
    VKSdk.authorize(VKSDK_AUTH_PERMISSIONS)
  }
  
}


// ======================================================= //
// MARK: - VKSdkUIDelegate
// ======================================================= //

extension VKSDKDelegateHandler: VKSdkUIDelegate {
  
  public func vkSdkDidDismissViewController(controller: UIViewController!, hadBeenCancelled: Bool) {
    if !hadBeenCancelled {
      NSNotificationCenter.defaultCenter().postNotificationName(VKSDK_ACCESS_AUTHORIZATION_STARTED, object: nil)
    }
  }

  public func vkSdkShouldPresentViewController(controller: UIViewController!) {
    let currentVC = UIViewController.currentViewController()
    currentVC.presentViewController(controller, animated: true, completion: nil)
  }

  public func vkSdkNeedCaptchaEnter(captchaError: VKError!) {
    let captchaVC = VKCaptchaViewController.captchaControllerWithError(captchaError)
    let currentVC = UIViewController.currentViewController()
    currentVC.presentViewController(captchaVC, animated: true, completion: nil)
  }

}






