//
//  FirstViewController.swift
//  VKStorage
//
//  Created by Mike on 1/3/16.
//  Copyright © 2016 BIBORAM. All rights reserved.
//

import UIKit
import QuickLook

@objc protocol ProgressDelegate {
  func progressDidChange(completionPercentage: Float)
}

class NimbusCellInfo {
  var image: UIImage!
  var description: String!
}

class FilesVC: UIViewController {
  var searchQuery: SearchQuery!
  let tableView = UITableView()
  var searchBar = NimbusSearchBar()
  var searchBarController: UISearchDisplayController!
  let addTableView = UITableView()
  let tintView = UIView()
  var refreshControl = UIRefreshControl()
  var searchResults = [(String, [SearchConfig])]()
  var searchBarCellData = [String]()
  
  override func viewDidLoad() {

    view.addSubview(tableView)
    
//    search.defaultSuggest().keys
    

    tableView.dataSource = self
    tableView.delegate = self
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 44.0
    tableView.tableFooterView = UIView(frame: CGRectZero)
    tableView.registerNib(UINib(nibName: "DocumentCell", bundle: nil), forCellReuseIdentifier: "DocumentCell")
    tableView.frame = UIScreen.mainScreen().bounds
    tableView.addSubview(refreshControl)
    
    addTableView.hidden = true
    addTableView.scrollEnabled = false
    addTableView.dataSource = self
    addTableView.rowHeight = UITableViewAutomaticDimension
    addTableView.estimatedRowHeight = 44.0
    addTableView.tableFooterView = UIView(frame: CGRectZero)
    addTableView.registerNib(UINib(nibName: "AddCell", bundle: nil), forCellReuseIdentifier: "AddCell")
    
    refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
  

  //  edgesForExtendedLayout = .None
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "didTapAddButton:")
    

//    self.navigationController!.navigationBar.translucent = true
    searchBar = NimbusSearchBar()
    searchBar.frame = CGRectMake(0, 0, view.bounds.width, 44)
    searchBar.nimbusSearchBarDelegate = self
    searchBar.dimsBackgroundDuringPresentation = false
    
    refreshControl.beginRefreshing()
    refresh(nil)
    
//    searchBarCellsInfo.append("trip")
//    searchBarCellsInfo.append("michael")
//    searchBarCellsInfo.append("university")
    
    
    super.viewDidLoad()
  }
  


  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
//  override func viewDidLayoutSubviews() {
//    super.viewDidLayoutSubviews()
//    self.searchBar.layoutIfNeeded()
//    self.searchBar.layoutSubviews()
//   
////    var currentTextFieldBounds = self.searchBar.subviews[0].subviews[1].bounds
////    currentTextFieldBounds.size.width = 100
////    self.searchBar.subviews[0].subviews[1].bounds = currentTextFieldBounds
//   
//  }
  
  func didTapAddTableViewDimmingView(rec: UITapGestureRecognizer) {
    dismissAddTableView()
  }
  
  override func viewDidAppear(animated: Bool) {
    tintView.frame = UIScreen.mainScreen().bounds
    tintView.alpha = 0
    tintView.backgroundColor = UIColor.blackColor()
    let tap = UITapGestureRecognizer(target: self, action: "didTapAddTableViewDimmingView:")
    tintView.addGestureRecognizer(tap)
    view.addSubview(tintView)
    tableView.tableHeaderView = searchBar
    tableView.contentOffset = CGPoint(x: 0, y: -64+tableView.tableHeaderView!.frame.height)
    NSNotificationCenter.defaultCenter().postNotificationName(MAIN_TAB_BAR_VC_VIEW_DID_APPEAR, object: nil)
    addTableView.frame = CGRectMake(0, -44*4, view.bounds.size.width, 44*4)
    addTableView.hidden = true
    self.view.addSubview(addTableView)
    searchBarController = UISearchDisplayController(searchBar: searchBar, contentsController: self)
    searchDisplayController!.delegate = self
    searchDisplayController!.searchResultsDataSource = self
    searchDisplayController!.searchResultsDelegate = self
    super.viewDidAppear(animated)
  }
  
  func rec(view: UIView) {
    NSTimer.after(10) { () -> Void in
        if view.isKindOfClass(UIButton) {
//          (view as! UIButton).addTarget(self, action: "push:", forControlEvents: .TouchUpInside)

        }
  //  print(view)
    for subView in view.subviews {
      self.rec(subView)
    }
    }
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
        CurrentUser.sharedCurrentUser().documentArray.sortByName(.OrderedAscending)
        self.title = "\(CurrentUser.sharedCurrentUser().documentArray.documents.count) Документов"
        self.refreshControl.endRefreshing()
        self.tableView.reloadData()
        self.searchQuery = SearchQuery()
        
//        let docs = CurrentUser.sharedCurrentUser().rootDir.docs
//        CurrentUser.sharedCurrentUser().rootDir.mkdir("abdul")
//        CurrentUser.sharedCurrentUser().rootDir.moveDocument(docs[0], toDir: CurrentUser.sharedCurrentUser().rootDir.childrenDirectories.objectAtIndex(0) as! AbstractDirectory)
//        CurrentUser.sharedCurrentUser().currentDir = CurrentUser.sharedCurrentUser().rootDir.childrenDirectories.objectAtIndex(0) as! AbstractDirectory
//        for doc in CurrentUser.sharedCurrentUser().currentDir.docs {
//          print(doc.title)
//        }
      })
      return nil
    }
    }

  func didTapAddButton(sender: UIBarButtonItem) {
    NSTimer.after(3) { () -> Void in
     // self.searchBarCellsInfo.append("sheesh")
      //self.searchBar.tableView.reload()
    }
    
//    if addTableView.hidden {
//      addTableView.hidden = false
//      UIView.animateWithDuration(0.35) { () -> Void in
//        self.addTableView.frame.origin = CGPointMake(0, self.addTableView.frame.origin.y + self.addTableView.bounds.height + 64)
//        self.tintView.alpha = 0.5
//      }
//    } else {
//      dismissAddTableView()
//    }
  }
  func dismissAddTableView() {
    UIView.animateWithDuration(0.35, animations: { () -> Void in
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
    } else if tableView == addTableView {
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
    } else {
      let cell = UITableViewCell()
      let searchRes = searchResults[indexPath.section].1[indexPath.row]
      cell.textLabel?.text = searchRes.name
      
      return cell
    }
    return UITableViewCell()
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if tableView == self.tableView {
      if let docs = CurrentUser.sharedCurrentUser().documentArray {
        return docs.sortInfo.numberOfRowsInSections[section]
      } else {
        return 0
      }
    } else if tableView == searchDisplayController?.searchResultsTableView {
      return searchResults[section].1.count
    } else {
      return 4
    }
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if tableView == self.tableView {
      if let docs = CurrentUser.sharedCurrentUser().documentArray {
        return docs.sortInfo.titleForHeaderInSection[section]
      }
    }
    else {
      return searchResults[section].0
    }
    return ""
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    if tableView == self.tableView {
      if let docs = CurrentUser.sharedCurrentUser().documentArray {
        return docs.sortInfo.numberOfSections
      }
    }
    else {
      return searchResults.count
    }
    return 1
  }


}

extension FilesVC : UITableViewDelegate {
  
//  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//    let view = UIView(frame: CGRectMake(0, 0, 200, 40))
//    view. add
//  }
  
  func scrollViewDidScroll(scrollView: UIScrollView) {
    if scrollView == searchDisplayController?.searchResultsTableView && scrollView.contentOffset != CGPointMake(0, -64) {
      searchBar.textField.endEditing(true)
    }
  }
 
  
  func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    CurrentUser.sharedCurrentUser().documentArray.documents[indexPath.row+skip(indexPath)].progressDelegate = nil
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    switch tableView {
    case self.tableView:
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
    case searchBar.tableView:
      print("seeeee")
    case searchDisplayController!.searchResultsTableView:
      let searchObj = searchResults[indexPath.section].1[indexPath.row]
      
      if let shortName = searchObj.shortName {
        searchBarCellData.append(shortName)
      } else {
        searchBarCellData.append(searchObj.name)
      }
      searchBar.tableView.reload()
    case addTableView:
      break
    default:
      break
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

extension FilesVC : UISearchDisplayDelegate {
  
  
  
//  func searchDisplayControllerWillBeginSearch(controller: UISearchDisplayController) {
//    print("")
//  }
//  
//  func searchDisplayController(controller: UISearchDisplayController, didShowSearchResultsTableView tableView: UITableView) {
//    print("")
//  }
  
  func searchDisplayController(controller: UISearchDisplayController, willUnloadSearchResultsTableView tableView: UITableView) {
    
  }
  
  
  func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchScope searchOption: Int) -> Bool {
    
    return true
  }
 
  
  func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String?) -> Bool {
    

    return true
  }
  
}


extension FilesVC : NimbusSearchBarDelegate {

  func nimbusSearchBarTableView(searchBar: NimbusSearchBar!, descriptionForRow row: Int) -> String {
    return searchBarCellData[row]
  }
  
  func nimbusSearchBarTableView(searchBar: NimbusSearchBar!, iconImageForRow row: Int) -> UIImage {
    return UIImage()
  }
  
  func nimbusSearchBarTableViewNumberOfRows(searchBar: NimbusSearchBar!) -> Int {
    return searchBarCellData.count
  }
  func nimbusSearchBarCancelButtonClicked(searchBar: NimbusSearchBar) {
    searchBarCellData.removeAll(keepCapacity: false)
  }
  func nimbusSearchBarTextDidBeginEditing(searchBar: NimbusSearchBar) {
    searchResults = searchQuery.defaultSuggest()
  }
  
  func nimbusSearchBar(searchBar: NimbusSearchBar, textDidChange searchText: String) {
    searchQuery.suggestConfiguration(searchText, completion: { (result: [(String, [SearchConfig])]) -> Void in
      self.searchResults = result
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.searchDisplayController?.searchResultsTableView.reloadData()
      })
    })
  }
  
  
}
extension FilesVC : DocsProcessingDelegate {
  func didFinishProcessingDocs() {
    print("DID FINISH PROCESSING DOCS")
  }
}











