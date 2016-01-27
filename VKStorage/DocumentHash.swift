//
//  DocumentHash.swift
//  VKStorage
//
//  Created by Timofey on 1/26/16.
//  Copyright © 2016 BIBORAM. All rights reserved.
//

import Foundation

class DocumentHash : RLMObject {
  
  static var array: [String] {
    var hashes = [String]()
    let realm_hashes = DocumentHash.objectsWithPredicate(nil)
    for var i=0; i<Int(realm_hashes.count);i++ {
      hashes.append((realm_hashes.objectAtIndex(UInt(i)) as! DocumentHash).urlHash!)
    }
    return hashes
  }
  
  dynamic var urlHash: String?
  
  convenience init(doc: Document) {
    self.init()
    urlHash = doc.url.md5()
  }
  
  //?
//  func save() {
//    let realm = RLMRealm.defaultRealm()
//    realm.beginWriteTransaction()
//    realm.addOrUpdateObject(self)
//    try! realm.commitWriteTransaction()
//  }
  
  override class func primaryKey() -> String {
    return "urlHash"
  }
  
}