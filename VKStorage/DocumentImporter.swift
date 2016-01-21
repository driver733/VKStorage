//
//  Importer.swift
//  VKStorage
//
//  Created by Timofey on 1/15/16.
//  Copyright © 2016 BIBORAM. All rights reserved.
//

import Foundation

@available(iOS 8.0, *)
class DocumentImporter: UIViewController, UIDocumentMenuDelegate, UIDocumentPickerDelegate {
  
  var delegate: DocumentImporterDelegate?
  
  override func viewDidLoad() {
    
    //Implement Gaussian Blur?
    view.backgroundColor = UIColor.clearColor()
    
  }
  
  func launch() {
    
    let importMenu = UIDocumentMenuViewController(documentTypes: ["public.data"], inMode: .Import)
    importMenu.delegate = self
    self.presentViewController(importMenu, animated: true, completion: nil)
    
  }
  
  @objc internal func documentMenu(documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
      
    documentPicker.delegate = self
    self.presentViewController(documentPicker, animated: true, completion: nil)
    
  }
  
  internal func documentMenuWasCancelled(documentMenu: UIDocumentMenuViewController) {
    
    self.dismissViewControllerAnimated(true, completion: nil)
    
  }
  
  @objc internal func documentPicker(controller: UIDocumentPickerViewController, didPickDocumentAtURL url: NSURL) {
    
    self.dismissViewControllerAnimated(true, completion: nil)
    delegate?.documentWasPickedAtURL(url)
    
  }
  
  internal func documentPickerWasCancelled(controller: UIDocumentPickerViewController) {
    
    self.dismissViewControllerAnimated(true, completion: nil)
    
  }
  
}

protocol DocumentImporterDelegate {
  func documentWasPickedAtURL(url: NSURL)
}
