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
  
  var numberOfSections = 0
  var sortType = SortType.Name
  var numberOfRowsInSections = [0]
  var titleForHeaderInSection = [""]
  
}