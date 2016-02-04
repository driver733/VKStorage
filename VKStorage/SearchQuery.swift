//
//  SearchQuery.swift
//  VKStorage
//
//  Created by Timofey on 1/31/16.
//  Copyright © 2016 BIBORAM. All rights reserved.
//

import Foundation

class SearchQuery {
  
  let docs = CurrentUser.sharedCurrentUser().documentArray.documents
  
  init() {
//    let extention = Document.objectsWithPredicate(NSPredicate(format: "", argumentArray: nil))
//    configuration = [String : Set<String>]()
  }
  
  //Implement dispatch_async?
  func suggestConfiguration(suggest: String) -> [String : [String]] {
    
    var suggestions = [String : [String]]()
    
    extentionsStartingWith(suggest).continueWithBlock { (task: BFTask) -> AnyObject? in
      suggestions["Extentions"] = task.result as? [String]
      print("1")
      return nil
    }
    
    print("2")
    
    datesStartingWith(suggest).continueWithBlock { (task: BFTask) -> AnyObject? in
      suggestions["Dates"] = task.result as? [String]
      print("3")
      return nil
    }
//    objects["Title begins with:"] = [suggest]
//    objects["Title ends with:"] = [suggest]
    
    return suggestions
  }
  
  func extentionsStartingWith(str: String) -> BFTask {
    let task = BFTaskCompletionSource()
    
    var extentions = [String]()
    for doc in (docs.filter() { $0.ext.hasPrefix(str) }) {
      extentions.append(doc.ext)
    }
    task.setResult(distinct(extentions))
    
    return task.task
  }
  
  func datesStartingWith(str: String) -> BFTask {
    let task = BFTaskCompletionSource()
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "MMMM yyyy"
    
    var stringDates = [String]()
    for doc in (docs.filter() { dateFormatter.stringFromDate($0.date).hasPrefix(str) }) {
      stringDates.append(dateFormatter.stringFromDate(doc.date))
    }
    
    task.setResult(distinct(stringDates))
    
    return task.task
  }
  
  func distinct<T: Equatable>(source: [T]) -> [T] {
    var unique = [T]()
    for item in source {
      if !unique.contains(item) {
        unique.append(item)
      }
    }
    return unique
  }
  
  
  
}