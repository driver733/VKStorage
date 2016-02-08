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
  func suggestConfiguration(suggest: String) -> [(String, [TupledName])] {
    
    if suggest.isEmpty {
      //Default return
      return defaultSuggest()
    }
    
    var suggestions = [(String, [TupledName])]()
    
    extentionsStartingWith(suggest).continueWithBlock { (task: BFTask) -> AnyObject? in
      
      if let a = task.result as? [TupledName] {
        suggestions.append(self.extentionsName, a)
      }
      return nil
    }
    
    datesStartingWith(suggest).continueWithBlock { (task: BFTask) -> AnyObject? in
      if let a = task.result as? [TupledName] {
        suggestions.append(self.datesName, a)
      }
      return nil
    }
    
    typesStartingWith(suggest).continueWithBlock { (task: BFTask) -> AnyObject? in
      if let a = task.result as? [TupledName] {
        suggestions.append(self.typesName, a)
      }
      return nil
    }
    
//    objects["Title begins with:"] = [suggest]
//    objects["Title ends with:"] = [suggest]
    
    return suggestions
  }
  
  func extentionsStartingWith(str: String) -> BFTask {
    let task = BFTaskCompletionSource()
    
    var extentions = Set<TupledName>()
    
    let filteredDocs = docs.filter() { $0.ext.lowercaseString.hasPrefix(str.lowercaseString) }
    for doc in filteredDocs {
      if !configurations[self.extentionsName]!.contains(doc.ext) {
        extentions.insert(TupledName(name: doc.ext))
      }
    }

    task.setResult(Array<TupledName>(extentions))
  
    return task.task
  }
  
  func datesStartingWith(str: String) -> BFTask {
    let task = BFTaskCompletionSource()
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "MMMM yyyy"
    let sdateFormatter = NSDateFormatter()
    sdateFormatter.dateFormat = "MM yyyy"
    
    var stringDates = Set<TupledName>()
    
    let filteredDocs = docs.filter() { dateFormatter.stringFromDate($0.date).lowercaseString.hasPrefix(str.lowercaseString) }
    for doc in filteredDocs {
      if !configurations[self.datesName]!.contains(dateFormatter.stringFromDate(doc.date)) {
        stringDates.insert(TupledName(name: dateFormatter.stringFromDate(doc.date), shortName: sdateFormatter.stringFromDate(doc.date)))
      }
    }
    
    task.setResult(Array<TupledName>(stringDates))
    
    return task.task
  }
  
  func typesStartingWith(str: String) -> BFTask {
    let task = BFTaskCompletionSource()
    
    var filteredTypes = Array<String>(documentTypes.keys).filter() { $0.lowercaseString.hasPrefix(str.lowercaseString) }
    
    for config in configurations[self.typesName]! {
      if let index = filteredTypes.indexOf(config) {
        filteredTypes.removeAtIndex(index)
      }
    }
    
    return task.task
  }
  
  func defaultSuggest() -> [(String, [TupledName])] {
    return [
      (self.typesName      , Array<TupledName>(documentTypes.keys.map() { TupledName(name: $0) })),
      (self.extentionsName , {
        var extentionsSet = Set<TupledName>()
        for doc in docs {
          extentionsSet.insert(TupledName(name: doc.ext))
        }
        return Array<TupledName>(extentionsSet)
      }()),
      (self.datesName      , {
        var datesSet = Set<TupledName>()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        let sdateFormatter = NSDateFormatter()
        sdateFormatter.dateFormat = "MM yyyy"
        
        for doc in docs {
          datesSet.insert(TupledName(name: dateFormatter.stringFromDate(doc.date), shortName: sdateFormatter.stringFromDate(doc.date)))
        }
        return Array<TupledName>(datesSet)
      }())
      
    ]
  }
  
//  func addConfiguration(str: String, forKey: String) -> Bool {
//    configurations[forKey]?.append(str)
//    return true
//  }
  
}

class TupledName: AnyObject, Hashable {
  
  var shortName : String?
  var name      : String
  
  var hashValue : Int {
      return name.hashValue
  }
  
  init(name: String, shortName: String) {
    self.name      = name
    self.shortName = shortName
  }
  
  init(name: String) {
    self.name      = name
  }
  
}

func ==(lhs: TupledName, rhs: TupledName) -> Bool {
  return lhs.hashValue == rhs.hashValue
}

