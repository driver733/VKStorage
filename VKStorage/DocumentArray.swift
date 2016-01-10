//
//  DocumentArray.swift
//  VKStorage
//
//  Created by Mike on 1/7/16.
//  Copyright © 2016 BIBORAM. All rights reserved.
//

import Foundation



class DocumentArray {
  
  var documents: [Document]!
  
  init(vkDocsArray: VKDocsArray) {
    documents = [Document]()
    for vkDocument in vkDocsArray.items {
      let doc = Document(vkDoc: vkDocument as! VKDocs)
      documents.append(doc)
    }
  }
  
  
  
  

}