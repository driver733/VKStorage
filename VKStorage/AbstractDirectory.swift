//
//  AbstractDirectory.swift
//  VKStorage
//
//  Created by Timofey on 1/12/16.
//  Copyright © 2016 BIBORAM. All rights reserved.
//

import Foundation

class AbstractDirectory : RLMObject {
  
  dynamic var childrenDirectories: RLMArray = RLMArray(objectClassName: AbstractDirectory.className())
  dynamic var files: RLMArray = RLMArray(objectClassName: Document.className())
  dynamic var path = ""
  dynamic var name = ""
  
  dynamic var parentDirectory: AbstractDirectory?
  
//  var delegate: AbstractDirectoryDelegate
  
  let defaultRealm = RLMRealm.defaultRealm()
  
  
  convenience init(name: String, parent: AbstractDirectory?) {
    
    self.init()
    self.parentDirectory = parent
    self.name = name
//    self.delegate = delegate
//    self.delegate.directoryWasCreated(self)
  }
  
  func mkdir(name: String) -> AbstractDirectory {
    let newDir = AbstractDirectory(name: name, parent: self)
    newDir.path = newDir.parentDirectory!.path+"/"+name
    childrenDirectories.addObject(newDir)
    return newDir
  }
  
  func addfile(file: Document) {
    files.addObject(file)
  }
  
}

protocol AbstractDirectoryDelegate {

  func directoryWasCreated(dir: AbstractDirectory)
  
}