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
  dynamic var documents: RLMArray = RLMArray(objectClassName: Document.className())
  dynamic var path = ""
  dynamic var name = ""
  var docs: [Document] {
    var temp_docs = [Document]()
    for var i=0;i<Int(documents.count);i++ {
      temp_docs.append(documents.objectAtIndex(UInt(i)) as! Document)
    }
    return temp_docs
  }
  
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

  func mkdir(name: String) -> BFTask? {
    let task = BFTaskCompletionSource()
    
    if arrayOfChildrenDirectoriesNames.contains(name) {
      task.setError(NSError(domain: "Already Exists", code: 0, userInfo: nil))
      return task.task
    }
    
    let newDir = AbstractDirectory(name: name, parent: self)
    newDir.path = newDir.parentDirectory!.path+"/"+name
    let realm = RLMRealm.defaultRealm()
    realm.beginWriteTransaction()
    childrenDirectories.addObject(newDir)
    try! realm.commitWriteTransaction()
    
    task.setResult(newDir)
    return task.task
  }
  
  func addDocument(file: Document) {
    let realm = RLMRealm.defaultRealm()
    realm.beginWriteTransaction()
    documents.addObject(file)
    try! realm.commitWriteTransaction()
  }
  
  func removeDocument(file: Document) {
    let doc = Document(forPrimaryKey: file.id)!

    let realm = RLMRealm.defaultRealm()
    realm.beginWriteTransaction()
    realm.deleteObject(doc)
    try! realm.commitWriteTransaction()
    
  }
  
  func moveDocument(file: Document, toDir: AbstractDirectory) -> BFTask {
    let task = BFTaskCompletionSource()
    
    let NOT_FOUND = UInt(UInt.max/2)
    
    if toDir.documents.indexOfObject(file)==NOT_FOUND {
      toDir.addDocument(file)
      let realm = RLMRealm.defaultRealm()
      realm.beginWriteTransaction()
      documents.removeObjectAtIndex(documents.indexOfObject(file))
      try! realm.commitWriteTransaction()
      task.setResult(true)
    }
    else {
      task.setError(NSError(domain: "Aleady exists", code: 0, userInfo: nil))
    }
    return task.task
  }
  
  //написать удаление кэша удаленных объектов
//  
//  func documents() -> [Document] {
//    var documents = [Document]()
//    let all_documents = CurrentUser.sharedCurrentUser().documentArray.documents
//
//    for var i=0;i<Int(documents.count);i++ {
//      for j in all_documents {
//        if j.id==(documentCaches.objectAtIndex(UInt(i)) as! Document).id {
//          documents.append(j)
//        }
//      }
//    }
//    return documents
//  }
//  
  override class func primaryKey() -> String {
    return "path"
  }
  
  @objc override class func ignoredProperties() -> [String] {
    return ["docs"]
  }
  
}

protocol AbstractDirectoryDelegate {

  func directoryWasCreated(dir: AbstractDirectory)
  
}