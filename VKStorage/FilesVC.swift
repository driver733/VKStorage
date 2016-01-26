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
  let tintView = UIView()
  var refreshControl = UIRefreshControl()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view = tableView
    tableView.dataSource = self
    tableView.delegate = self
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 44.0
    tableView.tableFooterView = UIView(frame: CGRectZero)
    tableView.registerNib(UINib(nibName: "DocumentCell", bundle: nil), forCellReuseIdentifier: "DocumentCell")
    tableView.addSubview(refreshControl)
    
    addTableView.hidden = true
    addTableView.scrollEnabled = false
    addTableView.dataSource = self
    addTableView.rowHeight = UITableViewAutomaticDimension
    addTableView.estimatedRowHeight = 44.0
    addTableView.tableFooterView = UIView(frame: CGRectZero)
    addTableView.registerNib(UINib(nibName: "AddCell", bundle: nil), forCellReuseIdentifier: "AddCell")
    
    refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
    
    automaticallyAdjustsScrollViewInsets = false
    edgesForExtendedLayout = .None
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "didTapAddButton:")
    
    refreshControl.beginRefreshing()
    refresh(nil)
    
    providesPresentationContextTransitionStyle = true
    definesPresentationContext = true
    
    
//    if #available(iOS 8.0, *) {
//      let a = DocumentImporter()
//      a.launch()
//      a.modalPresentationStyle = .Custom
//      self.presentViewController(a, animated: false, completion: nil)
//    } else {
//      // Fallback on earlier versions
//    }
    
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewDidAppear(animated: Bool) {
    tintView.frame = UIScreen.mainScreen().bounds
    tintView.alpha = 0
    tintView.backgroundColor = UIColor.blackColor()
    view.addSubview(tintView)
    
    NSNotificationCenter.defaultCenter().postNotificationName(MAIN_TAB_BAR_VC_VIEW_DID_APPEAR, object: nil)
    addTableView.frame = CGRectMake(0, -176, view.bounds.size.width, 176)
    view.addSubview(addTableView)
  }
  
  func skip(indexPath: NSIndexPath) -> Int {
    var skip = 0
    for var section=0; section<indexPath.section; section++ {
      skip += tableView.numberOfRowsInSection(section)
    }
    return skip
  }
  
  func refresh(sender: AnyObject?) {
    CurrentUser.sharedCurrentUser().loadDocuments().continueWithSuccessBlock { (task: BFTask) -> AnyObject? in
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        CurrentUser.sharedCurrentUser().documentArray.sortByUploadDate(.OrderedAscending)
        self.title = "\(CurrentUser.sharedCurrentUser().documentArray.documents.count) Документов"
        self.refreshControl.endRefreshing()
        self.tableView.reloadData()
        
        let realm = RLMRealm.defaultRealm()
        print(realm.isEmpty)
        print(realm.path)

        let a = AbstractDirectory(name: "1", parent: nil)
        let b = AbstractDirectory(name: "2", parent: a)
        b.mkdir("3")
        b.mkdir("4")
        for i in CurrentUser.sharedCurrentUser().documentArray.documents {
          b.addfile(i as Document)
        }

        realm.beginWriteTransaction()
        realm.addObject(a)
        realm.addObject(b)
        try! realm.commitWriteTransaction()
        print(realm.isEmpty)

      })
      return nil
    }
  }
  
  func didTapAddButton(sender: UIBarButtonItem) {
    if addTableView.hidden {
      addTableView.hidden = false
      UIView.animateWithDuration(0.26) { () -> Void in
        let addTableViewBounds = self.addTableView.bounds
        self.addTableView.frame = CGRectMake(0, 0, addTableViewBounds.width, addTableViewBounds.height)
        self.tintView.alpha = 0.5
      }
    } else {
      UIView.animateWithDuration(0.26, animations: { () -> Void in
        let addTableViewBounds = self.addTableView.bounds
        self.addTableView.frame = CGRectMake(0, -addTableViewBounds.height, addTableViewBounds.width, addTableViewBounds.height)
        self.tintView.alpha = 0
        }, completion: { (result: Bool) -> Void in
          if result {
            self.addTableView.hidden = true
          }
      })
    }
  }
  
}

extension FilesVC : UITableViewDataSource {
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if tableView == self.tableView {
      let cell = tableView.dequeueReusableCellWithIdentifier("DocumentCell", forIndexPath: indexPath) as! DocumentCell
      let doc = CurrentUser.sharedCurrentUser().documentArray.documents[indexPath.row+skip(indexPath)]
      doc.progressDelegate = cell
      if doc.isLoading {
        cell.progressView.hidden = false
      }
      cell.previewImageView.sd_setImageWithURL(NSURL(string: "http://www.metrogeotechnics.org/images/doc_icon1_40.png"))
      cell.titleLabel.text = doc.title
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
      if let docs = CurrentUser.sharedCurrentUser().documentArray {
        return docs.sortInfo.numberOfRowsInSections[section]
      } else {
        return 0
      }
    } else {
      return 4
    }
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if let docs = CurrentUser.sharedCurrentUser().documentArray {
      return docs.sortInfo.titleForHeaderInSection[section]
    }
    return ""
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    if tableView == self.tableView {
      if let docs = CurrentUser.sharedCurrentUser().documentArray {
        return docs.sortInfo.numberOfSections
      }
    }
    return 1
  }


}

extension FilesVC : UITableViewDelegate {
  
  func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    CurrentUser.sharedCurrentUser().documentArray.documents[indexPath.row+skip(indexPath)].progressDelegate = nil
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let doc = CurrentUser.sharedCurrentUser().documentArray.documents[indexPath.row+skip(indexPath)]
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
    let realIndex = (tableView.indexPathForSelectedRow?.row)!+skip(tableView.indexPathForSelectedRow!)
    let doc = CurrentUser.sharedCurrentUser().documentArray.documents[realIndex]
    let title = Defaults[doc.title].string
    let fileURL = NSURL.fileURLWithPath(FCFileManager.pathForDocumentsDirectoryWithPath(title))
    return fileURL
  }
  
}

extension FilesVC : DocumentImporterDelegate {
  
  func documentWasPickedAtURL(url: NSURL) {
    
//    presentViewController(<#T##viewControllerToPresent: UIViewController##UIViewController#>, animated: <#T##Bool#>, completion: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
    let docToUpload = UploadDocument(url: url)
    
  }
  
}









