//
//  CurrentUser.swift
//  VKStorage
//
//  Created by Mike on 1/5/16.
//  Copyright © 2016 BIBORAM. All rights reserved.
//

import Foundation


protocol LoadingStateDelegate {
  func didStartNetworingActivity()
  func didEndNetworingActivity()
}

class CurrentUser: User {
  
  var delegate: DocsProcessingDelegate?
  var loginLoadingStateDelegate: LoadingStateDelegate?
  var friends: VKUsersArray!
  var documentArray: DocumentArray!
  
  var rootDir: AbstractDirectory
  var currentDir: AbstractDirectory
  
  override init() {
    
    let realm = RLMRealm.defaultRealm()
    if realm.isEmpty {
      let rootDir = AbstractDirectory(name: "root", parent: nil)
      rootDir.path = "/root"
      realm.beginWriteTransaction()
      realm.addOrUpdateObject(rootDir)
      try! realm.commitWriteTransaction()
    }
    
    rootDir = AbstractDirectory(forPrimaryKey: "/root")!
    currentDir = rootDir

  }
  
  private static var sharedInstance: CurrentUser!
  
  class func sharedCurrentUser() -> CurrentUser {
    if sharedInstance == nil {
      sharedInstance = CurrentUser()
    }
    return sharedInstance
  }

  private class func resetSharedInstance() {
    sharedInstance = nil
  }
  
  func login() {
    if !VKSdk.vkAppMayExists() {
      NSNotificationCenter.defaultCenter().addObserver(self, name: VKSDK_ACCESS_AUTHORIZATION_STARTED, object: nil) { (observer, notification) -> Void in
        self.loginLoadingStateDelegate?.didStartNetworingActivity()
        NSNotificationCenter.defaultCenter().addObserver(self, name: VKSDK_ACCESS_AUTHORIZATION_SUCCEEDED, object: nil) { (observer, notification) -> Void in
          self.loginLoadingStateDelegate?.didEndNetworingActivity()
          Defaults[.isLoggedIn] = true
        }
      }
    } else {
      NSNotificationCenter.defaultCenter().addObserver(self, name: VKSDK_ACCESS_AUTHORIZATION_SUCCEEDED, object: nil) { (observer, notification) -> Void in
        self.loginLoadingStateDelegate?.didEndNetworingActivity()
      }
    }
    VKSdk.authorize(VKSDK_AUTH_PERMISSIONS)
  }
  
  func loadFriends() -> BFTask {
    return loadFriendsIDs()

    .continueWithSuccessBlock { (task: BFTask) -> AnyObject? in
      let friendsIDs = task.result as! [String]
      return self.loadFriendsProfiles(friendsIDs)
    }
    .continueWithBlock { (task: BFTask) -> AnyObject? in
      if task.error == nil {
        self.friends = task.result as! VKUsersArray
      }
      return nil
    }
}
  
  func loadFriendsIDs() -> BFTask {
    let task = BFTaskCompletionSource()
    let vkReq = VKApiUsers().getSubscriptions()
    vkReq.executeWithResultBlock({ (response: VKResponse!) -> Void in
      let json = JSON(response.json)
      var friendsIDs = [String]()
      for (index, _) in json.enumerate() {
        friendsIDs.append(String(json[index]))
      }
      task.setResult(friendsIDs)
      }, errorBlock: { (error: NSError!) -> Void in
    })
    return task.task
  }
  
  func loadFriendsProfiles(profilesIDs : [String]) -> BFTask {
    let task = BFTaskCompletionSource()
    let req = VKApiUsers().get([VK_API_USER_IDS : profilesIDs])
    req.executeWithResultBlock({ (response: VKResponse!) -> Void in
      let res = response.parsedModel as! VKUsersArray
      task.setResult(res)
      }) { (error: NSError!) -> Void in
        
    }
    return task.task
  }
  
  func getVKUserID() -> BFTask {
    let task = BFTaskCompletionSource()
    let vkReq = VKApiUsers().get()
    vkReq.executeWithResultBlock({ (response: VKResponse!) -> Void in
      let res = response.parsedModel as! VKUser
      task.setResult(res)
      }) { (error: NSError!) -> Void in
    }
    return task.task
  }

  func loadDocuments() -> BFTask {
    let task = BFTaskCompletionSource()
    VKApiDocs().get().executeWithResultBlock({ (response: VKResponse!) -> Void in
      let res = response.parsedModel as! VKDocsArray
      self.documentArray = DocumentArray()
      
      self.documentArray.processVKDocsArray(res)
//      self.documentArray.processDocumentsCaches().continueWithBlock({ (result: BFTask) -> AnyObject? in
//        //allow working with documents (displaying them?) after their docs have been processed
//        self.delegate?.didFinishProcessingCaches()
//        return nil
//      })
      task.setResult(nil)
      }) { (error: NSError!) -> Void in
    }
      return task.task
  }
  
}

protocol DocsProcessingDelegate {
  
  func didFinishProcessingDocs()
  
}


