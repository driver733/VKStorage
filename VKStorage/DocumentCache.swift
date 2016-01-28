//
//  DocumentCache.swift
//  VKStorage
//
//  Created by Timofey on 1/26/16.
//  Copyright © 2016 BIBORAM. All rights reserved.
//

import Foundation

class DocumentCache : RLMObject {
  
  dynamic var id: Int = 404
  dynamic var title: String = "NONAME"
  dynamic var size: String = "0"
  
  var associatedDocument: Document? {
    return CurrentUser.sharedCurrentUser().documentArray.binarySearchDocumentForID(id)
  }
  
  convenience init(doc: Document) {
    self.init()
    id = doc.id
    title = doc.title
    size = doc.size
  }
  
  override class func primaryKey() -> String {
    return "id"
  }
  
}

//Class methods
extension DocumentCache {
  
//  static var idsOfAllCaches: [Int] {
//    var caches = [Int]()
//    let realm_caches = DocumentCache.objectsWithPredicate(nil)
//    for var i=0; i<Int(realm_caches.count);i++ {
//      caches.append((realm_caches.objectAtIndex(UInt(i)) as! DocumentCache).id)
//    }
//    return caches
//  }
  
}

//extension DocumentCache : Equatable {
//  
//  func ==(lhs: DocumentCache, rhs: DocumentCache) -> Bool {
//  
//  }
//
//}