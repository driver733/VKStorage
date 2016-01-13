//
//  AbstractFS.swift
//  VKStorage
//
//  Created by Timofey on 1/12/16.
//  Copyright © 2016 BIBORAM. All rights reserved.
//

import Foundation

class AbstractFS {
  
  var FS: [AbstractDirectory]?
  
  init() {
  }

}

extension AbstractFS: AbstractDirectoryDelegate {
  
  func directoryWasCreated(dir: AbstractDirectory) {
    FS?.append(dir)
  }
  
}