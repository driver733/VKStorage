//
//  AbstractDirectory.swift
//  VKStorage
//
//  Created by Timofey on 1/12/16.
//  Copyright © 2016 BIBORAM. All rights reserved.
//

import Foundation

class AbstractDirectory {
  
  var childrenDirectories: [AbstractDirectory]?
  var files: [AbstractFile]?
  var path: String!
  var name: String!
  
  var parentDirectory: AbstractDirectory?
  
  var delegate: AbstractDirectoryDelegate?
  
  init(name: String, delegate: AbstractFS) {
    self.name = name
    self.delegate = delegate
    delegate.directoryWasCreated(self)
  }
  
  func mkdir(name: String, delegate: AbstractFS) -> AbstractDirectory {
    let newDir = AbstractDirectory(name: name, delegate: delegate)
    newDir.parentDirectory = self
    newDir.path = newDir.parentDirectory!.path+"/"+name
    childrenDirectories?.append(newDir)
    return newDir
  }
  
  func addfile(file: AbstractFile) {
    files?.append(file)
  }
  
}

protocol AbstractDirectoryDelegate {
  
//  var dir: AbstractDirectory { get set }
  func directoryWasCreated(dir: AbstractDirectory)
  
}