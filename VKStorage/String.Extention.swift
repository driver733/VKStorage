//
//  String.Extention.swift
//  VKStorage
//
//  Created by Timofey on 1/26/16.
//  Copyright © 2016 BIBORAM. All rights reserved.
//

import Foundation

extension String {
  func md5() -> String! {
    let str = self.cStringUsingEncoding(NSUTF8StringEncoding)
    let strLen = CUnsignedInt(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
    let digestLen = Int(CC_MD5_DIGEST_LENGTH)
    let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
    
    CC_MD5(str!, strLen, result)
    
    let cache = NSMutableString()
    for i in 0..<digestLen {
      cache.appendFormat("%02x", result[i])
    }
    
    result.destroy()
    
    return String(format: cache as String)
  }
}