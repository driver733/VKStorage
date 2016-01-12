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
  private(set) var sortInfo = SortInfo()
  
  init(vkDocsArray: VKDocsArray) {
    documents = [Document]()
    for vkDocument in vkDocsArray.items {
      let doc = Document(vkDoc: vkDocument as! VKDocs)
      documents.append(doc)
    }
  }
  
  func sortByName(sortType: NSComparisonResult) {
    documents.sortInPlace({$0.vkDoc.title.localizedCompare($1.vkDoc.title) == sortType})
    sortInfo.sortType = .Name
    let sortResult = nameSortInfo()
    sortInfo.numberOfSections = sortResult.numberOfUniquePrefixChars
    sortInfo.numberOfRowsInSections = sortResult.numberOfPrefixCharsForEachPrefix
    sortInfo.titleForHeaderInSection = sortResult.prefixChars
  }
  
  func sortByUploadDate(sortType: NSComparisonResult) {
    documents.sortInPlace({$0.date.compare($1.date) == sortType})
    sortInfo.sortType = .UploadDate
  }
  
  func sortBySize(sortType: NSComparisonResult) {
    documents.sortInPlace({$0.vkDoc.size.compare($1.vkDoc.size) == sortType})
    sortInfo.sortType = .Size
    let sortResult = sizeSortInfo()
    sortInfo.numberOfSections = sortResult.numberOfUniquePrefixChars
    sortInfo.numberOfRowsInSections = sortResult.numberOfPrefixCharsForEachPrefix
    sortInfo.titleForHeaderInSection = sortResult.prefixChars
  }
  
  private func sizeSortInfo() -> (numberOfUniquePrefixChars: Int, numberOfPrefixCharsForEachPrefix: [Int], prefixChars: [String]) {
    var numberOfDocsForEachSize = [Int](count: 7, repeatedValue: 0)
    let sizes = ["1MB", "5MB", "10MB", "25MB", "50MB", "100MB", "200MB"]
    for doc in documents {
      let sizeInMB = Int(doc.vkDoc.size)/1024/1024
      print(sizeInMB)
      switch sizeInMB {
      case _ where sizeInMB < 1:
        numberOfDocsForEachSize[0]++
      case _ where sizeInMB > 1 && sizeInMB < 5:
        numberOfDocsForEachSize[1]++
      case _ where sizeInMB > 5 && sizeInMB < 10:
        numberOfDocsForEachSize[2]++
      case _ where sizeInMB > 10 && sizeInMB < 25:
       numberOfDocsForEachSize[3]++
      case _ where sizeInMB > 25 && sizeInMB < 50:
        numberOfDocsForEachSize[4]++
      case _ where sizeInMB > 50 && sizeInMB < 100:
        numberOfDocsForEachSize[5]++
      case _ where sizeInMB > 100 && sizeInMB < 200:
        numberOfDocsForEachSize[6]++
      default: break
      }
    }
    return (sizes.count, numberOfDocsForEachSize, sizes)
  }
  
  
  
  
  private func nameSortInfo() -> (numberOfUniquePrefixChars: Int, numberOfPrefixCharsForEachPrefix: [Int], prefixChars: [String]) {
    var numberOfUniquePrefixChars = 0
    var numberOfPrefixCharsForEachPrefix = [0]
    var tempPrefixChar = documents[0].vkDoc.title[0]
    var index = 0
    var prefixChars: [String] = [String(tempPrefixChar)]
    for doc in documents {
      if String(doc.vkDoc.title[0]).lowercaseString != String(tempPrefixChar).lowercaseString {
        prefixChars.append(String(doc.vkDoc.title[0]))
        numberOfPrefixCharsForEachPrefix.append(1)
        index++
        numberOfUniquePrefixChars++
        tempPrefixChar = doc.vkDoc.title[0]
      } else {
        numberOfPrefixCharsForEachPrefix[index]++
      }
    }
    numberOfUniquePrefixChars++ //
    return (numberOfUniquePrefixChars, numberOfPrefixCharsForEachPrefix, prefixChars)
  }
  
  
  
  

}








