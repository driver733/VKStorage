//
//  UploadController.swift
//  VKStorage
//
//  Created by Timofey on 1/9/16.
//  Copyright © 2016 BIBORAM. All rights reserved.
//

import Foundation

class UploadController {

    func upload(url: NSURL) -> BFTask {
        
        return getUploadServer().continueWithSuccessBlock({ (task: BFTask) -> AnyObject? in
            let vkURL = task.result as! String
            return self.uploadToDocs(vkURL, fileWithURL: url).continueWithSuccessBlock({ (task: BFTask) -> AnyObject? in
                let fileName = task.result as! String
                return self.saveToDocs(fileName).continueWithBlock({ (task: BFTask) -> AnyObject? in
                    return nil
                })
            })
        })
        
    }
    
    private func getUploadServer() -> BFTask {
        let task = BFTaskCompletionSource()
        
        let req = VKApiDocs().getUploadServer()
        req.executeWithResultBlock({ (response: VKResponse!) -> Void in
            let json = JSON(response.json)
            let uploadServerURL = json["upload_url"].string!
            task.setResult(uploadServerURL)
            }) { (error: NSError!) -> Void in
        }
        return task.task
    }
    
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
    
    private func saveToDocs(file: String) -> BFTask {
        let task = BFTaskCompletionSource()
        VKApiDocs().save(file).executeWithResultBlock({(
            response: VKResponse!) -> Void in
            task.setResult("Successfuly loaded file")
            },
            errorBlock: {(error: NSError!) -> Void in
                task.setError(error)
        })
        return task.task
    }
    
}

