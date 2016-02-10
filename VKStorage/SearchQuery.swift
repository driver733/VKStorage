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
  
  private var docs = CurrentUser.sharedCurrentUser().documentArray.documents
  
  private let documentTypes = [
    "Documents"   : ["pdf"],
    "Archieves"   : ["rar", "zip"],
    "Pictures"    : ["jpg", "png", "jpeg"],
    "Animations"  : ["gif"],
    "Other"       : []
  ]
  
  private var knownTypes : [String] {
    var types = [String]()
    for key in documentTypes.keys {
      for type in documentTypes[key]! {
        types.append(type)
      }
    }
    return types
  }
  
  private let extentionsName = "Extentions:"
  private let datesName      = "Dates:"
  private let typesName      = "Types:"
  private let beginsWithName = "Begins with:"
  private let endsWithName   = "Ends with:"
  
  private var configurations : [SearchConfigType : [SearchConfig]]
  
  init() {
    configurations = [
      .Extention : [SearchConfig](),
      .Date      : [SearchConfig](),
      .Type      : [SearchConfig](),
      .Beginning : [SearchConfig](),
      .Ending    : [SearchConfig]()
    ]
  }
  
  //Implement dispatch_async?
  func suggestConfiguration(suggest: String, completion: (result: [(String, [SearchConfig])]) -> Void) {
    
    if suggest.isEmpty {
      //Default return
      completion(result: defaultSuggest().sort { $0.0.0.caseInsensitiveCompare($0.1.0) == NSComparisonResult.OrderedAscending })
      return
    }
    
    let tasks = [
      extentionsStartingWith(suggest),
      datesStartingWith(suggest),
      typesStartingWith(suggest)
    ]
    
    BFTask(forCompletionOfAllTasksWithResults: tasks).continueWithBlock { (task: BFTask) -> AnyObject? in
      let results = task.result as! NSArray
      
      var suggestions = [(String, [SearchConfig])]()
      
      for (_, result) in results.enumerate() {
        if let config = result as? [SearchConfig] {
          suggestions.append(((config.first?.type.rawValue)!, config))
        }
      }
      
      suggestions.append((self.beginsWithName, [SearchConfig(name: suggest, type: .Beginning)]))
      suggestions.append((self.endsWithName,   [SearchConfig(name: suggest, type: .Ending)]))
      
      completion(result: suggestions.sort() { $0.0.0.caseInsensitiveCompare($0.1.0) == NSComparisonResult.OrderedAscending })
      return nil
    }
        
  }
  
  func startingWith(str: String, forSearchConfigType: SearchConfigType) -> BFTask {
    let task = BFTaskCompletionSource()
//    var filtered =
    return task.task
  }
  
  func extentionsStartingWith(str: String) -> BFTask {
    let task = BFTaskCompletionSource()
    let filteredDocs = docs.filter() { $0.ext.lowercaseString.hasPrefix(str.lowercaseString) }
    
    let filteredExts = filteredDocs.map() { $0.ext }
    dispatch_async(dispatch_queue_create("com.bibo-ram.vkstorage.query.1", nil)) { () -> Void in
      var extentions = Set<SearchConfig>()
      
      for ext in filteredExts {
        if !self.namesArray(self.configurations[.Extention]!).contains(ext) {
          extentions.insert(SearchConfig(name: ext, type: .Extention))
        }
      }
      let result = Array<SearchConfig>(extentions)
      if !result.isEmpty {
        task.setResult(result)
      }
      else {
        task.setResult(nil)
      }
    }
    return task.task
  }
  
  func datesStartingWith(str: String) -> BFTask {
    let task = BFTaskCompletionSource()
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "MMMM yyyy"
    let filteredDocs = docs.filter { (doc: Document) -> Bool in
      let a = dateFormatter.stringFromDate(doc.date)
      return a.lowercaseString.hasPrefix(str.lowercaseString)
    }
    
    let filteredStringDates = filteredDocs.map() { dateFormatter.stringFromDate($0.date) }
    
    dispatch_async(dispatch_queue_create("com.bibo-ram.vkstorage.query.2", nil)) { () -> Void in
      
      var stringDates = Set<SearchConfig>()

      for date in filteredStringDates {
        print(date)
        if !self.namesArray(self.configurations[.Date]!).contains(date) {
          stringDates.insert(SearchConfig(name: date, type: .Date))
        }
      }
      let result = Array<SearchConfig>(stringDates)
      if !result.isEmpty {
        task.setResult(result)
      }
      else {
        task.setResult(nil)
      }
    }
    return task.task
  }
  
  func typesStartingWith(str: String) -> BFTask {
    let task = BFTaskCompletionSource()
    
    dispatch_async(dispatch_queue_create("com.bibo-ram.vkstorage.query.3", nil)) { () -> Void in
      var filteredTypes = Array<String>(self.documentTypes.keys).filter({ (key: String) -> Bool in
        return key.lowercaseString.hasPrefix(str.lowercaseString)
      })
      
      //config here is a String, refactor?
      for config in (self.namesArray(self.configurations[.Type]!)) {
        if let index = filteredTypes.indexOf(config) {
          filteredTypes.removeAtIndex(index)
        }
      }
      
      let result = Array<SearchConfig>(filteredTypes.map({ (type: String) -> SearchConfig in
        return SearchConfig(name: type, type: .Type)
      }))
      
      if !result.isEmpty {
        task.setResult(result)
      }
      else {
        task.setResult(nil)
      }
      
    }
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
        
        for doc in docs {
          datesSet.insert(SearchConfig(name: dateFormatter.stringFromDate(doc.date), type: .Date))
        }
        return Array<SearchConfig>(datesSet)
      }())
    ]
  }
  
  func addConfiguration(conf: SearchConfig) -> Bool {
    configurations[conf.type]?.append(conf)
    return true
  }
  
  func removeConfiguration(conf: SearchConfig) -> Bool {
    if let index = configurations[conf.type]?.indexOf(conf) {
      configurations[conf.type]?.removeAtIndex(index)
      return true
    }
    return false
  }
  
  func getDocs() -> [Document] {
    var docSet = Set<Document>()
    for key in configurations.keys {
//      let b = configurations[key]?.filter() { $0. }
      for config in configurations[key]! {
        switch config.type {
        case .Beginning:
          let result = docs.filter() { $0.title.lowercaseString.hasPrefix(config.name.lowercaseString) }
          for i in result {
            docSet.insert(i)
          }
        case .Ending:
          let result = docs.filter() { $0.title.lowercaseString.hasSuffix(config.name.lowercaseString) }
          for i in result {
            docSet.insert(i)
          }
        case .Extention:
          let result = docs.filter() { $0.ext.lowercaseString == config.name.lowercaseString }
          for i in result {
            docSet.insert(i)
          }
        case .Date:
          let dateFormatter = NSDateFormatter()
          dateFormatter.dateFormat = "MMMM yyyy"
          let result = docs.filter() { dateFormatter.stringFromDate($0.date).lowercaseString == config.name.lowercaseString }
          for i in result {
            docSet.insert(i)
          }
        case .Type:
          let result = docs.filter() { documentTypes[config.name]!.contains($0.ext.lowercaseString) || (config.name == "Other" && !knownTypes.contains($0.ext.lowercaseString)) }
          for i in result {
            docSet.insert(i)
          }
        }
      }
    }
    return Array<Document>(docSet)
  }
  
  func namesArray(source: [SearchConfig]) -> [String] {
    return source.map() { $0.name }
  }
  
}

enum SearchConfigType : String {
  case Date      = "Dates:"
  case Type      = "Types:"
  case Extention = "Extentions:"
  case Beginning = "Beginning with:"
  case Ending    = "Ending with:"
}

class SearchConfig: AnyObject, Hashable {
  
  var shortName : String?
  var name      : String
  var type      : SearchConfigType
  
  var hashValue : Int {
    return name.hashValue
  }
  
  init(name: String, type: SearchConfigType) {
    self.name      = name
    self.type      = type
    
    if type == .Date {
      let sdateFormatter = NSDateFormatter()
      sdateFormatter.dateFormat = "MMM yyyy"
      if let date = sdateFormatter.dateFromString(name) {
        shortName = sdateFormatter.stringFromDate(date)
      }
    }
  }
  
}

func ==(lhs: SearchConfig, rhs: SearchConfig) -> Bool {
  return lhs.hashValue == rhs.hashValue
}

