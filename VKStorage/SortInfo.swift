//
//  DocumentSortInfo.swift
//  VKStorage
//
//  Created by Mike on 1/10/16.
//  Copyright © 2016 BIBORAM. All rights reserved.
//

import Foundation

enum SortType {
  case Name
  case Size
  case UploadDate
}

class SortInfo {
    
  private(set) var numberOfSections = 0
  private(set) var sortType = SortType.Name
  private(set) var numberOfRowsInSections = [0]
  private(set) var titleForHeaderInSection = [""]
  
  init(numberOfSections: Int, sortType: SortType, numberOfRowsInSections: [Int], titleForHeaderInSection: [String]) {
    self.numberOfSections = numberOfSections
    self.sortType = sortType
    self.numberOfRowsInSections = numberOfRowsInSections
    self.titleForHeaderInSection = titleForHeaderInSection
  }
}