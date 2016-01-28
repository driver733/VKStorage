//
//  AbstractDirectory.swift
//  VKStorage
//
//  Created by Timofey on 1/12/16.
//  Copyright © 2016 BIBORAM. All rights reserved.
//

import Foundation

class AbstractDirectory : RLMObject {
  
  dynamic var parentDirectory: AbstractDirectory?
  dynamic var childrenDirectories: RLMArray = RLMArray(objectClassName: AbstractDirectory.className())
  dynamic var documentCaches: RLMArray = RLMArray(objectClassName: DocumentCache.className())
  dynamic var path = ""
  dynamic var name = ""
  
  var arrayOfChildrenDirectoriesNames: [String] {
    var names = [String]()
    for var i=0; i<Int(childrenDirectories.count);i++ {
      names.append((childrenDirectories.objectAtIndex(UInt(i)) as! AbstractDirectory).name)
    }
    return names
  }
  
  convenience init(name: String, parent: AbstractDirectory?) {
    
    self.init()
    self.parentDirectory = parent
    self.name = name

  }
  
  func mkdir(name: String) -> AbstractDirectory? {
    let newDir = AbstractDirectory(name: name, parent: self)
    newDir.path = newDir.parentDirectory!.path+"/"+name
    let realm = RLMRealm.defaultRealm()
    realm.beginWriteTransaction()
    childrenDirectories.addObject(newDir)
    try! realm.commitWriteTransaction()
    return newDir
  }
  
  func addCache(file: Document) {
    let realm = RLMRealm.defaultRealm()
    realm.beginWriteTransaction()
    documentCaches.addObject(file.docCache)
    try! realm.commitWriteTransaction()
  }
  
  func removeCache(file: Document) {
    let cache = DocumentCache(forPrimaryKey: file.docCache.id)!

    let realm = RLMRealm.defaultRealm()
    realm.beginWriteTransaction()
    realm.deleteObject(cache)
    try! realm.commitWriteTransaction()
    
  }
  
  func moveCache(file: Document, toDir: AbstractDirectory) {
    self.removeCache(file)
    toDir.addCache(file)
  }
  
  func documents() -> [Document] {
    var documents = [Document]()
    let all_documents = CurrentUser.sharedCurrentUser().documentArray.documents

    for var i=0;i<Int(documentCaches.count);i++ {
      for j in all_documents {
        if j.docCache.id==(documentCaches.objectAtIndex(UInt(i)) as! DocumentCache).id {
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