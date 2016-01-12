//
//  VKDoc.swift
//  VKStorage
//
//  Created by Mike on 1/6/16.
//  Copyright © 2016 BIBORAM. All rights reserved.
//

import Foundation

class Document {
  
  /// vkDoc instance associated with the Document
  var vkDoc: VKDocs!
  /// Date when the document was modified
  var date: NSDate!
  /// Formatted size of the document
  var size: String!
  /// <#Description#>
  var isLoading = false
  var isCached: Bool {
    if let title = Defaults[vkDoc.title].string {
      return FCFileManager.existsItemAtPath(FCFileManager.pathForDocumentsDirectoryWithPath(title))
    } else {
      return false
    }
  }
 
  var progressDelegate: ProgressDelegate?
  
  init(vkDoc: VKDocs) {
    self.vkDoc = vkDoc
    self.date = NSDate(timeIntervalSince1970: NSTimeInterval(vkDoc.date))
    let byteCountFormatter = NSByteCountFormatter()
    byteCountFormatter.countStyle = .File
    self.size = byteCountFormatter.stringFromByteCount(vkDoc.size.longLongValue)
  }
  
  func downloadVK() -> BFTask {
    let task = BFTaskCompletionSource()
    var fileName = ""
    download(Method.GET, NSURL(string: vkDoc.url)!, destination: { (_, response: NSHTTPURLResponse) -> NSURL in
      fileName = response.suggestedFilename!
      let path = NSURL.fileURLWithPath(FCFileManager.pathForDocumentsDirectoryWithPath(response.suggestedFilename))
      return path
    })
    .progress { (bytesRead: Int64, totalBytesRead: Int64, totalBytesExpectedToRead: Int64) -> Void in
      self.isLoading = true
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        let completionPercentage = Float(Double(totalBytesRead) / Double(totalBytesExpectedToRead))
        self.progressDelegate?.progressDidChange(completionPercentage)
      })
    }
    .responseJSON { (response: Response<AnyObject, NSError>) -> Void in
      if !fileName.isEmpty {
        Defaults[self.vkDoc.title] = fileName
        self.isLoading = false
      }
    }
    
    return task.task
  }
  
  
  
  
  
  
  
  
  
}






