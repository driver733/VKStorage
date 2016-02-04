//
//  SearchQuery.swift
//  VKStorage
//
//  Created by Timofey on 1/31/16.
//  Copyright © 2016 BIBORAM. All rights reserved.
//

import Foundation

class SearchQuery {
  
  private let docs = CurrentUser.sharedCurrentUser().documentArray.documents
  
  private let documentTypes = [
    "Documents"   : ["pdf"],
    "Archieves"   : ["rar"],
    "Pictures"    : ["jpg"],
    "Animations"  : ["gif"],
    "Other"       : []
  ]
  
  init() {

  }
  
  //Implement dispatch_async?
  func suggestConfiguration(suggest: String) -> [String : [String]] {
    
    if suggest.isEmpty {
      //Default return
      return defaultSuggest()
    }
    
    var suggestions = [String : [String]]()
    
    extentionsStartingWith(suggest).continueWithBlock { (task: BFTask) -> AnyObject? in
      suggestions["Extentions"] = task.result as? [String]
      return nil
    }
    
    
    datesStartingWith(suggest).continueWithBlock { (task: BFTask) -> AnyObject? in
      suggestions["Dates"] = task.result as? [String]
      return nil
    }
    
    typesStartingWith(suggest).continueWithBlock { (task: BFTask) -> AnyObject? in
      suggestions["Types"] = task.result as? [String]
      return nil
    }
    
//    objects["Title begins with:"] = [suggest]
//    objects["Title ends with:"] = [suggest]
    
    return suggestions
  }
  
  func extentionsStartingWith(str: String) -> BFTask {
      let task = BFTaskCompletionSource()
      
      var extentions = [String]()
    
      let filteredDocs = docs.filter() { $0.ext.hasPrefix(str) }
      for doc in filteredDocs {
        extentions.append(doc.ext)
      }
      task.setResult(distinct(extentions))
      
      return task.task
  }
  
//  func typesIn(str: [String], allTypes: [String : [String]]) -> BFTask {
//    let task = BFTaskCompletionSource()
//    
//    var types = [String]()
//    for typeSet in allTypes.keys {
//      
//    }
//    
//    return task.task
//  }
  
  func typesStartingWith(str: String) -> BFTask {
    let task = BFTaskCompletionSource()
    
    task.setResult(Array<String>(documentTypes.keys).filter() { $0.hasPrefix(str) })
    
    return task.task
  }
  
  func datesStartingWith(str: String) -> BFTask {
    let task = BFTaskCompletionSource()
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "MMMM yyyy"
    
    var stringDates = [String]()
    let filteredDocs = docs.filter() { dateFormatter.stringFromDate($0.date).hasPrefix(str) }
    for doc in filteredDocs {
      stringDates.append(dateFormatter.stringFromDate(doc.date))
    }
    
    task.setResult(distinct(stringDates))
    
    return task.task
  }
  
  //replace this with set opetations?
  private func distinct<T: Equatable>(source: [T]) -> [T] {
    var unique = [T]()
    for item in source {
      if !unique.contains(item) {
        unique.append(item)
      }
    }
    return unique
  }
  
  func defaultSuggest() -> [String: [String]] {
    return [
      "Types"      : Array<String>(documentTypes.keys),
      "Extentions" : {
        var extentionSet = Set<String>()
        for doc in docs {
          extentionSet.insert(doc.ext)
        }
        return Array<String>(extentionSet)
        }()
    ]
  }
  
}