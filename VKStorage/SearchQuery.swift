//
//  SearchQuery.swift
//  VKStorage
//
//  Created by Timofey on 1/31/16.
//  Copyright © 2016 BIBORAM. All rights reserved.
//
//TODO: Убрать категории которых нет, сделать типы документов
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
  
  private var configurations : [SearchConfig]
  private var configurationsNames : [String] {
   return Array<String>(configurations.map() { $0.name })
  }
  
  init() {
//    configurations = [
//      extentionsName : [String](),
//      datesName      : [String](),
//      typesName      : [String]()
//    ]
    configurations = [SearchConfig]()
  }
  
  //Implement dispatch_async?
  func suggestConfiguration(suggest: String) -> [(String, [SearchConfig])] {
    
    if suggest.isEmpty {
      //Default return
      return defaultSuggest()
    }
    
    var suggestions = [(String, [SearchConfig])]()
    
    extentionsStartingWith(suggest).continueWithBlock { (task: BFTask) -> AnyObject? in
      
      if let a = task.result as? [SearchConfig] {
        suggestions.append(self.extentionsName, a)
      }
      return nil
    }
    
    datesStartingWith(suggest).continueWithBlock { (task: BFTask) -> AnyObject? in
      if let a = task.result as? [SearchConfig] {
        suggestions.append(self.datesName, a)
      }
      return nil
    }
    
    typesStartingWith(suggest).continueWithBlock { (task: BFTask) -> AnyObject? in
      if let a = task.result as? [SearchConfig] {
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
    
    var extentions = Set<SearchConfig>()
    
    let filteredDocs = docs.filter() { $0.ext.lowercaseString.hasPrefix(str.lowercaseString) }
    for doc in filteredDocs {
      if !configurationsNames.contains(doc.ext) {
        extentions.insert(SearchConfig(name: doc.ext, type: .Extention))
      }
    }

    task.setResult(Array<SearchConfig>(extentions))
  
    return task.task
  }
  
  func datesStartingWith(str: String) -> BFTask {
    let task = BFTaskCompletionSource()
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "MMMM yyyy"
    let sdateFormatter = NSDateFormatter()
    sdateFormatter.dateFormat = "MM yyyy"
    
    var stringDates = Set<SearchConfig>()
    
    let filteredDocs = docs.filter() { dateFormatter.stringFromDate($0.date).lowercaseString.hasPrefix(str.lowercaseString) }
    for doc in filteredDocs {
      if !configurationsNames.contains(dateFormatter.stringFromDate(doc.date)) {
        stringDates.insert(SearchConfig(name: dateFormatter.stringFromDate(doc.date), shortName: sdateFormatter.stringFromDate(doc.date), type: .Date))
      }
    }
    
    task.setResult(Array<SearchConfig>(stringDates))
    
    return task.task
  }
  
  func typesStartingWith(str: String) -> BFTask {
    let task = BFTaskCompletionSource()
    
    var filteredTypes = Array<String>(documentTypes.keys).filter() { $0.lowercaseString.hasPrefix(str.lowercaseString) }
    
    for config in configurationsNames {
      if let index = filteredTypes.indexOf(config) {
        filteredTypes.removeAtIndex(index)
      }
    }
    let types = Array<SearchConfig>(filteredTypes.map() { SearchConfig(name: $0, type: .Type) })
    task.setResult(types)
    
    return task.task
  }
  
  func defaultSuggest() -> [(String, [SearchConfig])] {
    return [
      (self.typesName      , Array<SearchConfig>(documentTypes.keys.map() { SearchConfig(name: $0, type: .Type) })),
      (self.extentionsName , {
        var extentionsSet = Set<SearchConfig>()
        for doc in docs {
          extentionsSet.insert(SearchConfig(name: doc.ext, type: .Extention))
        }
        return Array<SearchConfig>(extentionsSet)
      }()),
      (self.datesName      , {
        var datesSet = Set<SearchConfig>()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        let sdateFormatter = NSDateFormatter()
        sdateFormatter.dateFormat = "MM yyyy"
        
        for doc in docs {
          datesSet.insert(SearchConfig(name: dateFormatter.stringFromDate(doc.date), shortName: sdateFormatter.stringFromDate(doc.date), type: .Date))
        }
        return Array<SearchConfig>(datesSet)
      }())
      
    ]
  }
  
  func addConfiguration(conf: SearchConfig) -> Bool {
    configurations.append(conf)
    return true
  }
  
  
}

enum SearchConfigType {
  case Date
  case Type
  case Extention
}

class SearchConfig: AnyObject, Hashable {
  
  var shortName : String?
  var name      : String
  var type      : SearchConfigType
  
  var hashValue : Int {
      return name.hashValue
  }
  
  init(name: String, shortName: String, type: SearchConfigType) {
    self.name      = name
    self.shortName = shortName
    self.type      = type
  }
  
  init(name: String, type: SearchConfigType) {
    self.name      = name
    self.type      = type
  }
  
}

func ==(lhs: SearchConfig, rhs: SearchConfig) -> Bool {
  return lhs.hashValue == rhs.hashValue
}

