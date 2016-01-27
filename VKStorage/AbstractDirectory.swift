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
  dynamic var documentHashes: RLMArray = RLMArray(objectClassName: DocumentHash.className())
  dynamic var path = ""
  dynamic var name = ""
  
  var childrenNamesArray: [String] {
    var names = [String]()
//    let realm_names = childrenDirectories
    for var i=0; i<Int(childrenDirectories.count);i++ {
      names.append((childrenDirectories.objectAtIndex(UInt(i)) as! AbstractDirectory).name)
    }
    return names
  }
  
  dynamic var parentDirectory: AbstractDirectory?
  
//  var delegate: AbstractDirectoryDelegate
  
//  let defaultRealm = RLMRealm.defaultRealm()
  
  
  convenience init(name: String, parent: AbstractDirectory?) {
    
    self.init()
    self.parentDirectory = parent
    self.name = name
//    self.delegate = delegate
//    self.delegate.directoryWasCreated(self)
  }
  
  func mkdir(name: String) -> AbstractDirectory? {
    let newDir = AbstractDirectory(name: name, parent: self)
    newDir.path = newDir.parentDirectory!.path+"/"+name
    childrenDirectories.addObject(newDir)
    return newDir
  }
  
  func addHash(file: Document) {
    let realm = RLMRealm.defaultRealm()
    realm.beginWriteTransaction()
    documentHashes.addObject(file.docHash)
    try! realm.commitWriteTransaction()
  }
  
  func removeHash(file: Document) {
    let hash = DocumentHash(forPrimaryKey: file.docHash.urlHash)!

    let realm = RLMRealm.defaultRealm()
    realm.beginWriteTransaction()
    realm.deleteObject(hash)
    try! realm.commitWriteTransaction()
    
  }
  
  func moveHash(file: Document, toDir: AbstractDirectory) {
    self.removeHash(file)
    toDir.addHash(file)
  }
  
  func documents() -> [Document] {
    var documents = [Document]()
    let all_documents = CurrentUser.sharedCurrentUser().documentArray.documents

    for var i=0;i<Int(documentHashes.count);i++ {
      for j in all_documents {
        if j.docHash.urlHash==(documentHashes.objectAtIndex(UInt(i)) as! DocumentHash).urlHash {
          documents.append(j)
        }
      }
    }
    return documents
  }
  
  override class func primaryKey() -> String {
    return "path"
  }
  
}

protocol AbstractDirectoryDelegate {

  func directoryWasCreated(dir: AbstractDirectory)
  
}