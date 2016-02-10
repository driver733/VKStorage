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
    "Animations"  : ["gif"],
    "Archieves"   : ["rar", "zip"],
    "Documents"   : ["pdf"],
    "Other"       : [],
    "Pictures"    : ["jpg", "png", "jpeg"]
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
  
  private var configurations : [SearchConfigType : [SearchConfig]]
  
  init() {
    configurations = [
      .Extention : [SearchConfig](),
      .Date      : [SearchConfig](),
      .CType     : [SearchConfig](),
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
      searchSuggestionWith(suggest, forSearchConfigType: .Extention),
      searchSuggestionWith(suggest, forSearchConfigType: .Date),
      searchSuggestionWith(suggest, forSearchConfigType: .CType),
      searchSuggestionWith(suggest, forSearchConfigType: .Beginning),
      searchSuggestionWith(suggest, forSearchConfigType: .Ending)
    ]
    
    BFTask(forCompletionOfAllTasksWithResults: tasks).continueWithBlock { (task: BFTask) -> AnyObject? in
      let results = task.result as! NSArray
      
      var suggestions = [(String, [SearchConfig])]()
      
      for (_, result) in results.enumerate() {
        if let config = result as? [SearchConfig] {
          suggestions.append(((config.first?.type.rawValue)!, config))
        }
      }
      
      completion(result: suggestions.sort() { $0.0.0.caseInsensitiveCompare($0.1.0) == NSComparisonResult.OrderedAscending })
      return nil
    }
        
  }
  
  func searchSuggestionWith(var str: String, forSearchConfigType: SearchConfigType) -> BFTask {
    let task = BFTaskCompletionSource()
    
    str = str.lowercaseString
    let existentConfigsNames = configurations[forSearchConfigType]!.map() { $0.name }
    var filtered = [String]()
    var q = dispatch_get_main_queue()
    
    //Don't implement !existentConfigNames.contains() checks here,
    //except for .CType since Document cannot be accessed in an async call.
    //If check is completed within async block further on, paralleling will be 
    //more efficient for large amount of data
    switch forSearchConfigType {
    case .Extention:
      q = dispatch_queue_create("com.bibo-ram.vkstorage.query.1", nil)
      filtered = (docs.filter() { $0.ext.lowercaseString.hasPrefix(str) }).map() { $0.ext }
    case .Date:
      q = dispatch_queue_create("com.bibo-ram.vkstorage.query.2", nil)
      let df = NSDateFormatter()
      df.dateFormat = "MMMM yyyy"
      filtered = (docs.filter() { df.stringFromDate($0.date).lowercaseString.hasPrefix(str) }).map() { df.stringFromDate($0.date) }
    case .CType:
      q = dispatch_queue_create("com.bibo-ram.vkstorage.query.3", nil)
      dispatch_async(q, { 
        filtered = Array<String>(self.documentTypes.keys).filter() { $0.lowercaseString.hasPrefix(str) && !existentConfigsNames.contains($0) }
        if !filtered.isEmpty {
          var types = filtered.map() { SearchConfig(name: $0, type: .CType) }
          types.sortInPlace() { $0.0.name.localizedCaseInsensitiveCompare($0.1.name) == NSComparisonResult.OrderedAscending }
          task.setResult(types)
        }
        else {
          task.setResult(nil)
        }
      })
    case .Beginning, .Ending:
      if !str.isEmpty {
        task.setResult(str)
      }
      else {
        task.setResult(nil)
      }
    }

    if forSearchConfigType == .Date || forSearchConfigType == .Extention {
      dispatch_async(q) {
        var configSet = Set<SearchConfig>()
        for token in filtered {
          if !existentConfigsNames.contains(token) {
            configSet.insert(SearchConfig(name: token, type: forSearchConfigType))
          }
        }
        var result = Array<SearchConfig>(configSet)
        if forSearchConfigType == .Date {
          let df = NSDateFormatter()
          df.dateFormat = "MMMM yyyy"
          result.sortInPlace() { df.dateFromString($0.0.name)!.compare(df.dateFromString($0.1.name)!) == NSComparisonResult.OrderedDescending }
        }
        
        if forSearchConfigType == .Extention {
          result.sortInPlace() { $0.0.name.localizedCaseInsensitiveCompare($0.1.name) == NSComparisonResult.OrderedAscending }
        }
        
        if !result.isEmpty {
          task.setResult(result)
        }
        else {
          task.setResult(nil)
        }
      }
    }
    
    return task.task
  }
  
  func defaultSuggest() -> [(String, [SearchConfig])] {
    return [
      (SearchConfigType.CType.rawValue     , Array<SearchConfig>(documentTypes.keys.map() { SearchConfig(name: $0, type: .CType) }).sort() { $0.0.name.localizedCaseInsensitiveCompare($0.1.name) == NSComparisonResult.OrderedAscending }),
      (SearchConfigType.Extention.rawValue , {
        var extentionsSet = Set<SearchConfig>()
        for doc in docs {
          extentionsSet.insert(SearchConfig(name: doc.ext, type: .Extention))
        }
        return Array<SearchConfig>(extentionsSet).sort() { $0.0.name.localizedCaseInsensitiveCompare($0.1.name) == NSComparisonResult.OrderedAscending }
      }())
//      (SearchConfigType.Date.rawValue      , {
//        var datesSet = Set<SearchConfig>()
//        
//        let dateFormatter = NSDateFormatter()
//        dateFormatter.dateFormat = "MMMM yyyy"
//        
//        for doc in docs {
//          datesSet.insert(SearchConfig(name: dateFormatter.stringFromDate(doc.date), type: .Date))
//        }
//        return Array<SearchConfig>(datesSet)
//      }())
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
        case .CType:
          let result = docs.filter() { documentTypes[config.name]!.contains($0.ext.lowercaseString) || (config.name == "Other" && !knownTypes.contains($0.ext.lowercaseString)) }
          for i in result {
            docSet.insert(i)
          }
        }
      }
    }
    return Array<Document>(docSet)
  }
  
}

enum SearchConfigType : String {
  case Date      = "Dates"
  //Type is a reserved word? Type.rawValue doesn't work for some reason
  case CType     = "Types"
  case Extention = "Extentions"
  case Beginning = "Beginning with"
  case Ending    = "Ending with"
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

