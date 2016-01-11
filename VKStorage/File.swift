//  File.swift
//  VKStorage
//
//  Created by Timofey on 1/11/16.
//  Copyright © 2016 BIBORAM. All rights reserved.
//

import Foundation

class we {

private func uploadToDocs(URL: String, fileWithURL: NSURL) -> BFTask {
  let task = BFTaskCompletionSource()
  
  upload(
    .POST,
    URL,
    multipartFormData: { multipartFormData in
      multipartFormData.appendBodyPart(fileURL: fileWithURL, name:"file")
    },
    encodingCompletion: { encodingResult in
      switch encodingResult {
      case .Success(let upload, _, _):
        upload.responseJSON { response in
          let json = JSON(response.result.value!)
          task.setResult(json["file"].string)
        }
      case .Failure(_):
        task.setError(NSError(domain: "EncodingError", code: 1, userInfo: nil))
      }
    }
  )
  
  return task.task
}
}