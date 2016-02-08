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
  
  private let extentionsName = "Extentions"
  private let datesName      = "Dates"
  private let typesName      = "Types"
  
  private var configurations: [String: [String]]
  
  init() {
    configurations = [
      extentionsName : [String](),
      datesName      : [String](),
      typesName      : [String]()
    ]
  }
  
  //Implement dispatch_async?
  func suggestConfiguration(suggest: String) -> [(String, [String]?)] {
    
    if suggest.isEmpty {
      //Default return
      return defaultSuggest()
    }
    
    var suggestions = [(String, [String]?)]()
    
    extentionsStartingWith(suggest).continueWithBlock { (task: BFTask) -> AnyObject? in
      suggestions.append(self.extentionsName, task.result as? [String])
      return nil
    }
    
    datesStartingWith(suggest).continueWithBlock { (task: BFTask) -> AnyObject? in
      suggestions.append(self.datesName, task.result as? [String])
      return nil
    }
    
    typesStartingWith(suggest).continueWithBlock { (task: BFTask) -> AnyObject? in
      suggestions.append(self.typesName, task.result as? [String])
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
        if !configurations[self.extentionsName]!.contains(doc.ext) {
          extentions.append(doc.ext)
        }
      }
      task.setResult(distinct(extentions))
      
      return task.task
  }
  
  func datesStartingWith(str: String) -> BFTask {
    let task = BFTaskCompletionSource()
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "MMMM yyyy"
    
    var stringDates = [String]()
    let filteredDocs = docs.filter() { dateFormatter.stringFromDate($0.date).hasPrefix(str) }
    for doc in filteredDocs {
      if !configurations[self.datesName]!.contains(dateFormatter.stringFromDate(doc.date)) {
        stringDates.append(dateFormatter.stringFromDate(doc.date))
      }
    }
    
    task.setResult(distinct(stringDates))
    
    return task.task
  }
  
  func typesStartingWith(str: String) -> BFTask {
    let task = BFTaskCompletionSource()
    
    var filteredTypes = Array<String>(documentTypes.keys).filter() { $0.hasPrefix(str) }
    
    for config in configurations[self.typesName]! {
      if let index = filteredTypes.indexOf(config) {
        filteredTypes.removeAtIndex(index)
      }
    }
    
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
  
  func defaultSuggest() -> [(String, [String]?)] {
    return [
      (self.typesName      , Array<String>(documentTypes.keys)),
      (self.extentionsName , {
        var extentionSet = Set<String>()
        for doc in docs {
          extentionSet.insert(doc.ext)
        }
        return Array<String>(extentionSet)
        }())
    ]
  }
  
//  func addConfiguration(str: String, forKey: String) -> Bool {
//    configurations[forKey]?.append(str)
//    return true
//  }
  
}