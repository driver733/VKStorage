//
//  FirstViewController.swift
//  VKStorage
//
//  Created by Mike on 1/3/16.
//  Copyright © 2016 BIBORAM. All rights reserved.
//

import UIKit
import QuickLook

protocol ProgressDelegate {
  func progressDidChange(completionPercentage: Float)
}

class FilesVC: UIViewController {
  
  let tableView = UITableView()
  let addTableView = UITableView()

  var refreshControl = UIRefreshControl()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    var urls = [NSURL]()
    for _ in 1...10 {
        urls.append(NSBundle.mainBundle().URLForResource("1", withExtension: "jpg")!)
    }
    //UploadController.uploadFilesFromURLs(urls)
    
    view = tableView
    tableView.dataSource = self
    tableView.delegate = self
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 44.0
    tableView.tableFooterView = UIView(frame: CGRectZero)
    tableView.registerNib(UINib(nibName: "DocumentCell", bundle: nil), forCellReuseIdentifier: "DocumentCell")
    tableView.addSubview(refreshControl)
    
    addTableView.backgroundColor = UIColor.blackColor()
  
    addTableView.dataSource = self
    addTableView.rowHeight = UITableViewAutomaticDimension
    addTableView.estimatedRowHeight = 44.0
    addTableView.tableFooterView = UIView(frame: CGRectZero)
    addTableView.registerNib(UINib(nibName: "AddCell", bundle: nil), forCellReuseIdentifier: "AddCell")
    view.addSubview(addTableView)
    
    refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
    
    automaticallyAdjustsScrollViewInsets = false
    edgesForExtendedLayout = .None
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "didTapAddButton:")
    
    refreshControl.beginRefreshing()
    refresh(nil)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewDidAppear(animated: Bool) {
    NSNotificationCenter.defaultCenter().postNotificationName(MAIN_TAB_BAR_VC_VIEW_DID_APPEAR, object: nil)
    addTableView.frame = CGRectMake(0, 0, view.bounds.size.width, 176)
  }
  
  func refresh(sender: AnyObject?) {
    CurrentUser.sharedCurrentUser().loadDocuments().continueWithSuccessBlock { (task: BFTask) -> AnyObject? in
       dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.title = "\(CurrentUser.sharedCurrentUser().documents.documents.count) Документов"
        self.refreshControl.endRefreshing()
        self.tableView.reloadData()
      })
      return nil
    }
  }
  
  func didTapAddButton(sender: UIBarButtonItem) {
  

  }
  
}

extension FilesVC : UITableViewDataSource {
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if tableView == self.tableView {
      let cell = tableView.dequeueReusableCellWithIdentifier("DocumentCell", forIndexPath: indexPath) as! DocumentCell
      let doc = CurrentUser.sharedCurrentUser().documents.documents[indexPath.row]
      doc.progressDelegate = cell
      if doc.isLoading {
        cell.progressView.hidden = false
      }
      cell.previewImageView.sd_setImageWithURL(NSURL(string: "http://www.metrogeotechnics.org/images/doc_icon1_40.png"))
      cell.titleLabel.text = doc.vkDoc.title
      cell.infoLabel.text = doc.size
      cell.separatorInset = UIEdgeInsets(top: 0, left: cell.titleLabel.frame.minX, bottom: 0, right: 7)
      return cell
    } else {
      let cell = tableView.dequeueReusableCellWithIdentifier("AddCell", forIndexPath: indexPath) as! AddCell
      if indexPath.row + 1 == tableView.numberOfRowsInSection(0) {
        cell.separatorInset = UIEdgeInsets(top: 0, left: self.view.bounds.size.width, bottom: 0, right: 0)
      }
      cell.iconImageView.sd_setImageWithURL(NSURL(string: "http://www.dreamtemplate.com/dreamcodes/web_icons/gray-camera-icon.png"))
      switch indexPath.row {
      case 0:
        cell.uploadTypeLabel.text = "Загрузить фото"
      case 1:
        cell.uploadTypeLabel.text = "Загрузить документ"
      case 2:
        cell.uploadTypeLabel.text = "Создать папку"
      case 3:
        cell.uploadTypeLabel.text = "Создать документ"
      default: break
      }
      return cell
    }
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if tableView == self.tableView {
      if let docs = CurrentUser.sharedCurrentUser().documents {
        return docs.documents.count
      } else {
        return 0
      }
    } else {
      return 4
    }
  }
  
}


extension FilesVC : UITableViewDelegate {
  
  func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    CurrentUser.sharedCurrentUser().documents.documents[indexPath.row].progressDelegate = nil
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let doc = CurrentUser.sharedCurrentUser().documents.documents[indexPath.row]
    if doc.isCached {
      let previewQL = QLPreviewController()
      previewQL.dataSource = self
      if #available(iOS 8.0, *) {
        showViewController(previewQL, sender: nil)
      } else {
        presentViewController(previewQL, animated: true, completion: nil)
      }
    } else if !doc.isLoading {
      let cell = tableView.cellForRowAtIndexPath(indexPath) as! DocumentCell
      cell.progressView.hidden = false
      doc.downloadVK()
    }
  }

}


extension FilesVC : QLPreviewControllerDataSource {
  
  func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int {
    return 1
  }
  
  func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem {
    let doc = CurrentUser.sharedCurrentUser().documents.documents[(tableView.indexPathForSelectedRow?.row)!]
    let title = Defaults[doc.vkDoc.title].string
    let fileURL = NSURL.fileURLWithPath(FCFileManager.pathForDocumentsDirectoryWithPath(title))
    return fileURL
  }
  
}











