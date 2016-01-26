//
//  AbstractFS.swift
//  VKStorage
//
//  Created by Timofey on 1/12/16.
//  Copyright © 2016 BIBORAM. All rights reserved.
//

import Foundation

class AbstractFS  {
  
  dynamic let FS = RLMArray(objectClassName: AbstractDirectory.className())
  
//  convenience override init() {
//    self.init()
//  }

}

extension AbstractFS: AbstractDirectoryDelegate {
  
  func directoryWasCreated(dir: AbstractDirectory) {
    FS.addObject(dir)
  }
  
}