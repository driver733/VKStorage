//
//  UploadDocument.swift
//  VKStorage
//
//  Created by Mike on 1/7/16.
//  Copyright © 2016 BIBORAM. All rights reserved.
//

import Foundation


class UploadDocument {
  
  /// <#Description#>
  var title: String!
  /// <#Description#>
  var data: NSData!
  /// <#Description#>
  var tags: String?
  /// <#Description#>
  var progress: Int64?
  
  
  class func getUploadServer() -> BFTask {
    let task = BFTaskCompletionSource()
    let req = VKApiDocs().getUploadServer()
    req.executeWithResultBlock({ (response: VKResponse!) -> Void in
      let json = JSON(response.json)
      let uploadServerURL = NSURL(string: json["response"]["upload_url"].stringValue)
      task.setResult(uploadServerURL)
      }) { (error: NSError!) -> Void in
    }
    return task.task
  }
  
  class func getWallUploadServer() -> BFTask {
    let task = BFTaskCompletionSource()
    let req = VKApiDocs().getWallUploadServer()
    req.executeWithResultBlock({ (response: VKResponse!) -> Void in
      let json = JSON(response.json)
      let uploadServerURL = NSURL(string: json["response"]["upload_url"].stringValue)
      task.setResult(uploadServerURL)
      }) { (error: NSError!) -> Void in
    }
    return task.task
  }
  
  
  func uploadVK(uploadServerURL: NSURL) -> BFTask {
    let task = BFTaskCompletionSource()
    upload(.POST, uploadServerURL, data: data)
    .progress({ (_, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) -> Void in
      
    })
    .responseJSON(completionHandler: { (response: Response<AnyObject, NSError>) -> Void in
      let json = JSON(response.result.value!)
      print(json)
    })
    return task.task
  }
  
  func save() -> BFTask {
    let task = BFTaskCompletionSource()
    var req: VKRequest!
    if let tags = tags {
      req = VKApiDocs().save(String(data), andTitle: title, andTags: tags)
    } else {
      req = VKApiDocs().save(String(data), andTitle: title)
    }
    req.executeWithResultBlock({ (response: VKResponse!) -> Void in
      
      }) { (error: NSError!) -> Void in
        
    }
    return task.task
  }
  
}






