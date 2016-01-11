//
//  UploadController.swift
//  VKStorage
//
//  Created by Timofey on 1/9/16.
//  Copyright © 2016 BIBORAM. All rights reserved.
//

import Foundation

class UploadController {

    static func uploadFiles(files: [NSURL]?) -> Void {
        if let fileURL = NSBundle.mainBundle().URLForResource("1", withExtension: "jpg") {
            if let _ = NSData(contentsOfURL: fileURL) {
                let myRequest = VKRequest(method: "docs.getUploadServer", andParameters: nil)
                myRequest.executeWithResultBlock(
                    { (response: VKResponse!) -> Void in
                        var json = JSON(response.json)
                        if let uploadURL = json["upload_url"].string {
                            print(uploadURL)
                            
                            upload(
                                .POST,
                                uploadURL,
                                multipartFormData: { multipartFormData in
                                    multipartFormData.appendBodyPart(fileURL: fileURL, name:"file")
                                },
                                encodingCompletion: { encodingResult in
                                    switch encodingResult {
                                    case .Success(let upload, _, _):
                                        upload.responseJSON { response in
                                            json = JSON(response.result.value!)
                                            VKApiDocs().save(json["file"].string).executeWithResultBlock({ (response: VKResponse!) -> Void in
                                                print(response)
                                                }, errorBlock: { (error: NSError!) -> Void in
                                                    print(error)
                                            })
                                        }
                                        case .Failure(let encodingError):
                                            print(encodingError)
                                    }
                                }
                            )
                        }
                    }, errorBlock: {(error: NSError!) -> Void in
                        print(error)
                })
            }
        }
    }
    
}

