//
//  VKDocs.swift
//  VKStorage
//
//  Created by Mike on 1/6/16.
//  Copyright © 2016 BIBORAM. All rights reserved.
//

import Foundation

class Document : RLMObject {
  
  /// Date when the document was modified
  dynamic var date: NSDate = NSDate()
  /// Formatted size of the document
  
  dynamic var id: Int = 0
  dynamic var owner_id: Int = 0
  
  dynamic var size: String = ""
  dynamic var title: String = ""
  dynamic var ext: String = ""
  dynamic var url: String = ""
//  var photo_100: String = ""
//  var photo_130: String = ""
  
  dynamic var progressDelegate: ProgressDelegate?
  
  var isLoading = false
  
  dynamic var isCached: Bool {
    return FCFileManager.existsItemAtPath(title)
  }
  
  convenience init(vkDoc: VKDocs) {
    self.init()
    self.id = Int(vkDoc.id)
    self.title = vkDoc.title
    self.owner_id = vkDoc.owner_id.integerValue
    self.ext = vkDoc.ext
    self.url = vkDoc.url
    self.date = NSDate(timeIntervalSince1970: NSTimeInterval(vkDoc.date))
    
    let byteCountFormatter = NSByteCountFormatter()
    byteCountFormatter.countStyle = .File
    self.size = byteCountFormatter.stringFromByteCount(vkDoc.size.longLongValue)
    
    //    self.photo_100 = vkDoc.photo_100
    //    self.photo_130 = vkDoc.photo_130

  }

//  Тут полный треш с title и suggestedFilename 
//  suggestedFilename перербатывает имя объекта или вк возвращает имя отличное от тайтла
  func downloadVK() -> BFTask {
    
    self.isLoading = true
    let task = BFTaskCompletionSource()
    var fileName = String()
    let path = NSURL.fileURLWithPath(FCFileManager.pathForDocumentsDirectoryWithPath(self.title))
    
    download(Method.GET, self.url, destination: { (_, response: NSHTTPURLResponse) -> NSURL in
      fileName = response.suggestedFilename!
      return path
    })
    .progress { (bytesRead: Int64, totalBytesRead: Int64, totalBytesExpectedToRead: Int64) -> Void in
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        let completionPercentage = Float(Double(totalBytesRead) / Double(totalBytesExpectedToRead))
        self.progressDelegate?.progressDidChange(completionPercentage)
      })
    }
    .responseJSON { (response: Response<AnyObject, NSError>) -> Void in
      if !fileName.isEmpty {
        Defaults[self.title] = self.title
        self.isLoading = false
        task.setResult(nil)
      }
    }
    return task.task
  }
  
  override class func primaryKey() -> String {
    return "id"
  }

  @objc override class func ignoredProperties() -> [String] {
    return ["progressDelegate", "isLoading"]
  }
  
}





