//
//  DocumentArray.swift
//  VKStorage
//
//  Created by Mike on 1/7/16.
//  Copyright © 2016 BIBORAM. All rights reserved.
//

import Foundation



class DocumentArray {
  
  var documents: [Document]!
  private(set) var sortInfo: SortInfo!
  
  init(vkDocsArray: VKDocsArray) {
    documents = [Document]()
    for vkDocument in vkDocsArray.items {
      let doc = Document(vkDoc: vkDocument as! VKDocs)
      documents.append(doc)
    }
  }
  
  func sortByName(sortType: NSComparisonResult) {
    documents.sortInPlace({$0.title.localizedCompare($1.title) == sortType})
    sortInfo = nameSortInfo()
  }
  
  func sortByUploadDate(sortType: NSComparisonResult) {
    documents.sortInPlace({$0.date.compare($1.date) == sortType})
    sortInfo = uploadDateSortInfo()
  }
  
  func sortBySize(sortType: NSComparisonResult) {
    documents.sortInPlace({$0.size.compare($1.size) == sortType})
    sortInfo = sizeSortInfo(sortType)
  }
  
  private func sizeSortInfo(sortType: NSComparisonResult) -> SortInfo {
    var numberOfDocsForEachSize = [Int](count: 7, repeatedValue: 0)
    var sizes = ["1MB", "5MB", "10MB", "25MB", "50MB", "100MB", "200MB"]
    var indexes = [0, 1, 2, 3, 4, 5, 6]
    if sortType == .OrderedDescending {
      indexes = indexes.reverse()
      sizes = sizes.reverse()
    }
      for doc in documents {
        let sizeInMB = Double(doc.size)!/1024/1024
        switch sizeInMB {
        case _ where sizeInMB < 1:
          numberOfDocsForEachSize[indexes[0]]++
        case _ where sizeInMB > 1 && sizeInMB < 5:
          numberOfDocsForEachSize[indexes[1]]++
        case _ where sizeInMB > 5 && sizeInMB < 10:
          numberOfDocsForEachSize[indexes[2]]++
        case _ where sizeInMB > 10 && sizeInMB < 25:
         numberOfDocsForEachSize[indexes[3]]++
        case _ where sizeInMB > 25 && sizeInMB < 50:
          numberOfDocsForEachSize[indexes[4]]++
        case _ where sizeInMB > 50 && sizeInMB < 100:
          numberOfDocsForEachSize[indexes[5]]++
        case _ where sizeInMB > 100 && sizeInMB < 200:
          numberOfDocsForEachSize[indexes[6]]++
        default: break
        }
      }
    return SortInfo(numberOfSections: sizes.count, sortType: .Size, numberOfRowsInSections: numberOfDocsForEachSize, titleForHeaderInSection: sizes)
  }
  
  private func nameSortInfo() -> SortInfo {
    var numberOfUniquePrefixChars = 0
    var numberOfPrefixCharsForEachPrefix = [0]
    var tempPrefixChar = documents[0].title[0]
    var index = 0
    var prefixChars: [String] = [String(tempPrefixChar)]
    for doc in documents {
      if String(doc.title[0]).lowercaseString != String(tempPrefixChar).lowercaseString {
        prefixChars.append(String(doc.title[0]))
        numberOfPrefixCharsForEachPrefix.append(1)
        index++
        numberOfUniquePrefixChars++
        tempPrefixChar = doc.title[0]
      } else {
        numberOfPrefixCharsForEachPrefix[index]++
      }
    }
    numberOfUniquePrefixChars++
    return SortInfo(numberOfSections: numberOfUniquePrefixChars, sortType: .Name, numberOfRowsInSections: numberOfPrefixCharsForEachPrefix, titleForHeaderInSection: prefixChars)
  }
  
  private func uploadDateSortInfo() -> SortInfo {
    var numberOfUniquePrefixChars = 0
    var numberOfPrefixCharsForEachPrefix = [0]
    var tempPrefixChar = dateStringFromUploadDate(documents.first!.date)
    var index = 0
    var prefixChars: [String] = [String(tempPrefixChar)]
    for doc in documents {
      if dateStringFromUploadDate(doc.date) != tempPrefixChar {
        prefixChars.append(dateStringFromUploadDate(doc.date))
        numberOfPrefixCharsForEachPrefix.append(1)
        index++
        numberOfUniquePrefixChars++
        tempPrefixChar = dateStringFromUploadDate(doc.date)
      } else {
        numberOfPrefixCharsForEachPrefix[index]++
      }
    }
    numberOfUniquePrefixChars++
    return SortInfo(numberOfSections: numberOfUniquePrefixChars, sortType: .Name, numberOfRowsInSections: numberOfPrefixCharsForEachPrefix, titleForHeaderInSection: prefixChars)
  }
  
  private func dateStringFromUploadDate(uploadDate: NSDate) -> String {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "EEE, MMM d, h:mm a"
    if NSDate().daysFrom(uploadDate) < 1 {
      return "Today"
    } else if NSDate().daysFrom(uploadDate) < 2 {
      return "Yesterday"
    }
    else if NSDate().weeksFrom(uploadDate) < 1 {
      return "This week"
    }
    else if NSDate().monthsFrom(uploadDate) < 1 {
      return "This month"
    }
    else if NSDate().yearsFrom(uploadDate) < 1 {
      let monthNumber = NSCalendar.currentCalendar().components([.Month], fromDate: uploadDate).month
      let month = NSCalendar.currentCalendar().monthSymbols[monthNumber - 1] // subtract one since arrays start with 0
      return month
    } else {
      let components = NSCalendar.currentCalendar().components([.Month, .Year], fromDate: uploadDate)
      let month = NSCalendar.currentCalendar().monthSymbols[components.month - 1] // subtract one since arrays start with 0
      let year = components.year
      return "\(month) \(year)"
    }
  }

 
}


//DELEGATES
extension DocumentArray {
  
  //adds new docs from vk to root directory
  func processDocumentsCaches() -> BFTask {
    let task = BFTaskCompletionSource()
    for i in self.documents {
      let cache = DocumentCache(forPrimaryKey: i.id)
      if cache==nil {
        CurrentUser.sharedCurrentUser().rootDir.addCache(i)
      }
    }
    
    task.setResult("PROCCESSED")
    sleep(5)
    
    return task.task

  }
  
}


extension DocumentArray {
  
  func binarySearchDocumentForID(id: Int) -> Document? {
    
    var left = 0
    var right = documents.count - 1
    
    while (left <= right) {
      let mid = (left + right) / 2
      let value = documents[mid].id
      
      if (value == id) {
        return documents[mid]
      }
      
      if (value < id) {
        left = mid + 1
      }
      
      if (value > id) {
        right = mid - 1
      }
    }
    
    return nil
  }
  
}









