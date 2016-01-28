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
//  var vkDoc: VKDocs!
  var docCache: DocumentCache {
    
    if let cache = DocumentCache(forPrimaryKey: self.id) {
      return cache
    }
    return DocumentCache(doc: self)
    
  }
  /// Date when the document was modified
  var date: NSDate = NSDate()
  /// Formatted size of the document
  
  var id: Int = 0
  var owner_id: Int = 0
  
  var size: String
  var title: String
  var ext: String
  var url: String
//  var photo_100: String = ""
//  var photo_130: String = ""
  
  var progressDelegate: ProgressDelegate?
  
  var isLoading = false
  
  var isCached: Bool {
    return FCFileManager.existsItemAtPath(title)
  }
  
  init(vkDoc: VKDocs) {
    self.id = Int(vkDoc.id)
    self.title = vkDoc.title
    self.owner_id = vkDoc.owner_id.integerValue
    self.ext = vkDoc.ext
    self.url = vkDoc.url
//    self.photo_100 = vkDoc.photo_100
//    self.photo_130 = vkDoc.photo_130
    self.date = NSDate(timeIntervalSince1970: NSTimeInterval(vkDoc.date))
    
    let byteCountFormatter = NSByteCountFormatter()
    byteCountFormatter.countStyle = .File
    self.size = byteCountFormatter.stringFromByteCount(vkDoc.size.longLongValue)
    
    
  }
  
  //Тут полный треш с title и suggestedFilename 
  //suggestedFilename перербатывает имя объекта или вк возвращает имя отличное от тайтла
  func downloadVK() -> BFTask {
    let task = BFTaskCompletionSource()
    
    var fileName = ""
    download(Method.GET, self.url, destination: { (_, response: NSHTTPURLResponse) -> NSURL in
      fileName = response.suggestedFilename!
      let path = NSURL.fileURLWithPath(FCFileManager.pathForDocumentsDirectoryWithPath(self.title))
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
        Defaults[self.title] = self.title
        self.isLoading = false
      }
    }
    
    return task.task
  }
  
}





