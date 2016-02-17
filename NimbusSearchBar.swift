//
//  NimbusSearchBar.swift
//  VKStorage
//
//  Created by Mike on 1/19/16.
//  Copyright © 2016 BIBORAM. All rights reserved.
//

import Foundation

extension UIView {
  
  func subviewOfClass(ofClass: UIView.Type) -> UIView? {
    if self.isKindOfClass(ofClass) {
      return self
    }
    for view in subviews {
      return view.subviewOfClass(ofClass)
    }
    return nil
  }
  
  func superviewOfClass(ofClass: UIView.Type) -> UIView? {
    if self.isKindOfClass(ofClass) {
      return self
    }
    return superview?.superviewOfClass(ofClass)
  }
  
}

extension NimbusCell {
  
  func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
    let rect = CGRectMake(0, 0, size.width, size.height)
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    color.setFill()
    UIRectFill(rect)
    let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
  }
  
}

let nimbusCellReuseIdentifier = "NimbusSearchBarCellReuseIdentifier"
//let nimbusTextFieldCellReuseIdentifier = "NimbusSearchBarTextFieldCellReuseIdentifier"


//class NimbusTextFieldCell: UITableViewCell {
//  
//  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
//    super.init(style: style, reuseIdentifier: reuseIdentifier)
//    
//    
//    
//  }
//  
//  required init?(coder aDecoder: NSCoder) {
//    super.init(coder: aDecoder)
//  }
//  
//  convenience init() {
//    self.init(style: .Default, reuseIdentifier: nimbusTextFieldCellReuseIdentifier)
//  }
//  
//}

class NimbusCell: UITableViewCell {
  
  let baseView = UITextField()
  let label = UILabel()
  let iconImageView = UIImageView()
  
  var iconImageViewHeight: CGFloat!
  let iconImageViewLeading = CGFloat(5)
  let labelLeadingOffset = CGFloat(5)
  let labelTrailing = CGFloat(5)
  var textSize: CGSize!
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }
  
  convenience init(description: String) {
    self.init(style: .Default, reuseIdentifier: nimbusCellReuseIdentifier)
    selectionStyle = .None
    baseView.delegate = self
   // NSNotificationCenter.defaultCenter().addObserver(self, selector: "cellTextDidChange:", name: UITextFieldTextDidChangeNotification, object: nil)
    baseView.tintColor = UIColor.clearColor()
    baseView.textColor = .clearColor()
   // baseView.font = UIFont.systemFontOfSize(0)
    baseView.backgroundColor = UIColor.searchBarBaseViewColor()
    baseView.layer.cornerRadius = 4
    iconImageView.image = imageWithColor(.greenColor(), size: CGSizeMake(20, 20))
    label.text = description
    label.font =  label.font?.fontWithSize(UIFont.systemFontSize())
    label.textColor = .whiteColor()
    textSize = (description as NSString).sizeWithAttributes([NSFontAttributeName : label.font])
    textSize = CGSizeMake(textSize.width+6, textSize.height+6)
    baseView.addSubview(label)
    baseView.addSubview(iconImageView)
    contentView.addSubview(baseView)
    contentView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI)/2) // rotate by 90 degrees
    iconImageViewHeight = textSize.height/2
    baseView.snp_makeConstraints { (make) -> Void in
      make.top.leading.equalTo(3)
      make.bottom.trailing.equalTo(-3)
    }
    iconImageView.snp_makeConstraints { (make) -> Void in
      make.leading.equalTo(iconImageViewLeading)
      make.centerY.equalTo(baseView.bounds.midY)
      make.width.equalTo(iconImageView.snp_height)
      make.height.equalTo(textSize.height/2)
    }
    label.snp_makeConstraints { (make) -> Void in
      make.leading.equalTo(iconImageView.snp_trailing).offset(labelLeadingOffset)
      make.trailing.equalTo(labelTrailing).priorityLow()
      make.width.lessThanOrEqualTo(120).priorityRequired()
      make.centerY.equalTo(baseView.bounds.midY)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
}

extension NimbusCell : UITextFieldDelegate {
  
  func textFieldDidBeginEditing(textField: UITextField) {
    textField.backgroundColor = UIColor.searchBarSelectionBarColor()
  }
  
  func textFieldDidEndEditing(textField: UITextField) {
     textField.backgroundColor = UIColor.searchBarBaseViewColor()
  }
  
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    label.hidden = true
    iconImageView.hidden = true
    baseView.backgroundColor = .clearColor()
    baseView.layer.cornerRadius = 0
    baseView.font = UIFont.systemFontOfSize(UIFont.systemFontSize())
    baseView.tintColor = .blueColor()
    baseView.textColor = .blackColor()
    let searchBar = superviewOfClass(NimbusSearchBar) as? NimbusSearchBar
    let tableView = superviewOfClass(EasyTableView) as? EasyTableView
    if let searchBar = searchBar, tableView = tableView, indexPath = tableView.tableView.indexPathForCell(self) {
      if searchBar.editingIndexPaths.contains(indexPath) {
        searchBar.editingTextForRowAtEditingIndexPath[indexPath.row] = textField.text!  // replace string in range
      } else {
        searchBar.editingIndexPaths.append(indexPath)
        searchBar.editingTextForRowAtEditingIndexPath.append(textField.text!)  // replace string in range
      }
      
      if bounds.size.height < (textField.text! as NSString).sizeWithAttributes([NSFontAttributeName : textField.font!]).width {
        NSNotificationCenter.defaultCenter().addObserver(self, name: UITextFieldTextDidChangeNotification, object: nil, handler: { (observer, notification) -> Void in
          if let _ = (notification.object as! UITextField).superviewOfClass(NimbusCell) {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
              tableView.tableView.beginUpdates()
              tableView.tableView.endUpdates()
            })
          }
        })
      }
      //searchBar.nimbusSearchBarDelegate?.nimbusSearchBar(searchBar, shouldChangeTextInRange: range, replacementText: string)
    }
    return true
  }
  
}

class HorizontalUITextField: UITextField {
  
//  override var frame: CGRect {
//    get {
//      return CGRectMake(super.frame.origin.x, super.frame.origin.y, super.frame.size.height, super.frame.size.width)
//    }
//    set {
//      super.frame = CGRectMake(newValue.origin.x, newValue.origin.y, newValue.size.height, newValue.size.width)
//    }
//  }
//  
//  override var bounds: CGRect {
//    get {
//      return CGRectMake(super.bounds.origin.x, super.bounds.origin.y, super.bounds.size.height, super.bounds.size.width)
//    }
//    set {
//      super.bounds = CGRectMake(newValue.origin.x, newValue.origin.y, newValue.size.height, newValue.size.width)
//    }
//  }

  override init(frame: CGRect) {
    super.init(frame: CGRectZero)
    transform = CGAffineTransformMakeRotation(CGFloat(M_PI)/2) // rotate by 90 degrees
    self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.height, frame.size.width-50)
    clearButtonMode = .Always
    font = UIFont.systemFontOfSize(UIFont.systemFontSize())
    placeholder = "Search"
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
}



class NimbusSearchBar: UISearchBar {
  
  var backgroundView: UIView!
  var nimbusSearchBarDelegate: NimbusSearchBarDelegate?
  var cancel = false
  
  private (set) var tableView: EasyTableView!
  private (set) var textField: HorizontalUITextField!
  private var oldNumberOfRows = 0
  private var defaultTextFieldWidth: CGFloat!
  private var defaultEditingTextFieldWidth: CGFloat! {
    return defaultTextFieldWidth - 60 - 23
  }
  private var currentTextFieldWidth: CGFloat! {
    return currentEditingTextFieldWidth + 60    // + 25
  }
  private var currentEditingTextFieldWidth: CGFloat!
  private var defaultHeaderWidth: CGFloat!
  private var editingIndexPaths = [NSIndexPath]()
  private var editingTextForRowAtEditingIndexPath = [String]()

  var dimsBackgroundDuringPresentation = true
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func drawRect(rect: CGRect) {
    addTableView()
  }
  
  
  func removeGestureRecognizersInSubViews(view: UIView) {
//    if view.isKindOfClass(UIButton) {
//      (view as! UIButton).addTarget(self, action: "push:", forControlEvents: .TouchUpInside)
//    }
    
    view.gestureRecognizers?.removeAll(keepCapacity: false)
    for subView in view.subviews {
      removeGestureRecognizersInSubViews(subView)
    }
  }
  

  private func addTableView() {

    removeGestureRecognizersInSubViews(self) // remove all gesture recognizers
    
    let searchBarTextField = subviews[0].subviews[1]
    let magnifyingGlass = subviews[0].subviews[1].subviews[1] as! UIImageView
  
    delegate = self
  
    tableView = EasyTableView(frame: searchBarTextField.frame, ofWidth: 0)
    tableView.tableView.separatorStyle = .None
    tableView.orientation = .Horizontal
    tableView.delegate = self
    tableView.tableView.allowsSelection = true

    backgroundView = UIView(frame: searchBarTextField.frame)
    backgroundView.layer.cornerRadius = 5
    backgroundView.clipsToBounds = true
    tableView.frame = backgroundView.bounds
    backgroundView.addSubview(tableView)
    insertSubview(backgroundView, belowSubview: searchBarTextField)
    searchBarTextField.removeFromSuperview()
    defaultTextFieldWidth = searchBarTextField.bounds.width
    currentEditingTextFieldWidth = defaultEditingTextFieldWidth
    textField = HorizontalUITextField(frame: CGRectMake(0, 0, defaultEditingTextFieldWidth, 0))
 
    // NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldTextDidChange:", name: UITextFieldTextDidChangeNotification, object: nil)
    textField.delegate = self
    tableView.tableView.tableFooterView = textField
    tableView.contentOffset = CGPointMake(0, 0)
    let width = (textField.placeholder! as NSString).sizeWithAttributes([NSFontAttributeName : textField.font!]).width - 6
    let headerView = UIView(frame: CGRectMake(0, 0, searchBarTextField.bounds.height, searchBarTextField.bounds.midX - width/2))
    defaultHeaderWidth = headerView.bounds.height
    magnifyingGlass.transform = CGAffineTransformMakeRotation(CGFloat(M_PI)/2) // rotate by 90 degrees
    headerView.addSubview(magnifyingGlass)
    tableView.tableView.tableHeaderView = headerView
    magnifyingGlass.snp_makeConstraints { (make) -> Void in
      make.bottom.equalTo(-10)
      make.centerX.equalTo(0)
    }
  }
  
  func click(rec: UITapGestureRecognizer) {
    textField.endEditing(true)
  }
  
  func textFieldTextDidChange(notif: NSNotification) {
    delegate?.searchBar?(self, textDidChange: textField.text!)
  }
  
}

extension NimbusSearchBar : EasyTableViewDelegate {
  
  func easyTableView(easyTableView: EasyTableView!, heightOrWidthForCellAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
    let cell = easyTableView.delegate!.easyTableView(easyTableView, cellForRowAtIndexPath: indexPath) as! NimbusCell
    if editingIndexPaths.contains(indexPath) {
      return (cell.baseView.text! as NSString).sizeWithAttributes([NSFontAttributeName : cell.baseView.font!]).width + 10
    } else {
      var size = CGSizeMake(0, cell.textSize.width + cell.iconImageViewHeight + cell.iconImageViewLeading + cell.labelLeadingOffset + cell.labelTrailing)
      if size.height > 120 {
        size.height += 25
      }
      return size.height
    }
  }
  
  func easyTableView(easyTableView: EasyTableView!, numberOfRowsInSection section: Int) -> Int {
    var numberOfRows = nimbusSearchBarDelegate!.nimbusSearchBarTableViewNumberOfRows(self)
    if cancel {
      numberOfRows = 0
    }
    if let footer = tableView.tableView.tableFooterView {
      switch numberOfRows {
      case _ where numberOfRows < oldNumberOfRows:
        break
      case _ where numberOfRows == 0:
        textField.placeholder = "Search"
        footer.frame.size = CGSizeMake(backgroundView.frame.height, backgroundView.frame.width)
      case _ where numberOfRows > oldNumberOfRows:
        if self.textField != nil {
          self.textField.text = ""
        }
        textField.placeholder = ""
        let lastCellWidth = easyTableView.delegate?.easyTableView?(easyTableView, heightOrWidthForCellAtIndexPath: NSIndexPath(forRow: numberOfRows-1, inSection: 0))
        if footer.bounds.size.width - lastCellWidth! < 70 {
          tableView.tableView.scrollEnabled = true
          footer.bounds.size.width = 70
          self.currentEditingTextFieldWidth = footer.bounds.size.width
        } else {
       //   tableView.tableView.scrollEnabled = false
          if let currentEditingTextFieldWidth = currentEditingTextFieldWidth {
            footer.bounds.size.width = currentEditingTextFieldWidth - lastCellWidth!
          } else {
            footer.bounds.size.width = footer.bounds.size.width - lastCellWidth!
          }
          self.currentEditingTextFieldWidth = footer.bounds.size.width
        }
        NSTimer.after(0.1, { () -> Void in
          // MARK: Refactor to scrollViewDidScroll
          if footer.bounds.size.width == 70 {
            if numberOfRows == 2 {
              self.tableView.setContentOffset(CGPointMake(self.tableView.tableView.tableFooterView!.bounds.maxX, 0), animated: true)
            } else {
              self.tableView.setContentOffset(CGPointMake(self.tableView.tableView.contentSize.height - self.tableView.bounds.width, 0), animated: true) // -49
            }
          }
          //        self.tableView.setContentOffset(CGPointMake(self.tableView.tableView.contentSize.height - self.tableView.bounds.width, 0), animated: true)
          self.tableView.tableView.tableFooterView = self.tableView.tableView.tableFooterView
        })
      default:
        break
      }
    }
    oldNumberOfRows = numberOfRows
    return numberOfRows
  }
  func easyTableView(easyTableView: EasyTableView!, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell = easyTableView.tableView.dequeueReusableCellWithIdentifier(nimbusCellReuseIdentifier) as? NimbusCell
    let description = nimbusSearchBarDelegate!.nimbusSearchBarTableView(self, descriptionForRow: indexPath.row)
    // let iconImage = nimbusSearchBarDelegate?.nimbusSearchBarTableView(self, descriptionForRow: indexPath.row)
    if cell == nil {
      cell = NimbusCell(description: description)
    }
    if editingIndexPaths.contains(indexPath) {
      cell!.label.hidden = true
      cell!.iconImageView.hidden = true
      cell!.baseView.backgroundColor = .whiteColor()
      cell!.baseView.text = editingTextForRowAtEditingIndexPath[indexPath.row]
    } else {
      cell!.label.text = description
      cell!.textSize = (description as NSString).sizeWithAttributes([NSFontAttributeName : cell!.label.font])
      cell!.textSize = CGSizeMake(cell!.textSize.width+5, cell!.textSize.height+5)
    }

    return cell!
  }
  
//  func easyTableView(easyTableView: EasyTableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
//    let cell = tableView.tableView.cellForRowAtIndexPath(indexPath) as! NimbusCell
//    cell.baseView.backgroundColor = UIColor.searchBarSelectionBaseViewColor()
//    (cell.contentView.subviews[0] as! UITextField).becomeFirstResponder()
//   // textField.endEditing(true)
//  }
//  
//  func easyTableView(easyTableView: EasyTableView!, didDeselectRowAtIndexPath indexPath: NSIndexPath!) {
//    let cell = tableView.tableView.cellForRowAtIndexPath(indexPath) as! NimbusCell
//    cell.baseView.backgroundColor = UIColor.searchBarBaseViewColor()
//  }
  
}
extension NimbusSearchBar : UITextFieldDelegate {
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    return true
  }
  
  func textFieldShouldClear(textField: UITextField) -> Bool {
    if let currentTextFieldWidth = currentTextFieldWidth {
      tableView.tableView.tableFooterView?.bounds.size.width = currentTextFieldWidth
    }
    tableView.tableView.tableFooterView = tableView.tableView.tableFooterView
    return true
  }
  
  func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
    delegate?.searchBarShouldBeginEditing?(self)
    return true
  }
  
  func textFieldDidBeginEditing(textField: UITextField) {
    // MARK: Investigate why searchResultsTableView.hidden is false initially
    struct Tokens { static var token: dispatch_once_t = 0 }
    dispatch_once(&Tokens.token) { UIViewController.currentViewController().searchDisplayController!.searchResultsTableView.hidden = true }
    if UIViewController.currentViewController().searchDisplayController!.searchResultsTableView.hidden {
      let header = self.tableView.tableView.tableHeaderView!
      let footer = self.tableView.tableView.tableFooterView!
      let magnifyingGlass = header.subviews[0] as! UIImageView
      magnifyingGlass.snp_remakeConstraints(closure: { (make) -> Void in
        make.center.equalTo(CGPointMake(0, 0))
      })
      UIView.animateWithDuration(0.2, animations: { () -> Void in
        self.backgroundView.frame.size = CGSizeMake(self.backgroundView.bounds.width-60, self.backgroundView.bounds.height)
        self.tableView.frame = self.backgroundView.bounds
        header.bounds.size = CGSizeMake(magnifyingGlass.bounds.height, magnifyingGlass.bounds.width + 10)
        self.tableView.tableView.tableHeaderView = header
        footer.bounds.size.width = self.currentEditingTextFieldWidth
        if self.nimbusSearchBarDelegate?.nimbusSearchBarTableViewNumberOfRows(self) > 2 {
          self.tableView.setContentOffset(CGPointMake(self.tableView.tableView.contentSize.height - self.tableView.bounds.width, 0), animated: true)
        }
        self.tableView.tableView.tableFooterView = footer
      })
      delegate?.searchBarTextDidBeginEditing?(self)
    }
    if let selectedRow = tableView.tableView.indexPathForSelectedRow {
      tableView.tableView.deselectRowAtIndexPath(selectedRow, animated: false)
      tableView.delegate?.easyTableView?(tableView, didDeselectRowAtIndexPath: selectedRow)
    }
  }
  
  func textFieldDidEndEditing(textField: UITextField) {
    if UIViewController.currentViewController().searchDisplayController!.searchResultsTableView.hidden || cancel {
      let header = self.tableView.tableView.tableHeaderView!
      let footer = self.tableView.tableView.tableFooterView!
      UIView.animateWithDuration(0.2, animations: { () -> Void in
        self.backgroundView.frame.size = CGSizeMake(self.backgroundView.bounds.width+60, self.backgroundView.bounds.height)
        self.tableView.frame = self.backgroundView.bounds
        if self.nimbusSearchBarDelegate?.nimbusSearchBarTableViewNumberOfRows(self) == 0 {
          header.bounds.size.height = self.defaultHeaderWidth
          self.tableView.tableView.tableHeaderView = header
        }
        let magnifyingGlass = header.subviews[0]
        magnifyingGlass.snp_remakeConstraints { (make) -> Void in
          make.bottom.equalTo(-10)
          make.centerX.equalTo(0)
        }
        if footer.bounds.width != 70 {
       // if footer.frame.maxY + 60 + 23 > self.backgroundView.bounds.maxX {
          self.tableView.tableView.tableFooterView?.bounds.size.width = self.currentTextFieldWidth
          self.tableView.tableView.tableFooterView = self.tableView.tableView.tableFooterView
        } else {
         // footer.bounds.size.width += 60
        }
      })
      delegate?.searchBarTextDidEndEditing?(self)
      }
  }
  
  func textFieldShouldEndEditing(textField: UITextField) -> Bool {
    delegate?.searchBarShouldEndEditing?(self)
    return true
  }
  
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
//    let textFieldWidth = textField.bounds.size.width
    if easyTableView(tableView, numberOfRowsInSection: 0) > 0 {
      let textFieldTextWidth = ((textField.text!) as NSString).sizeWithAttributes([NSFontAttributeName : textField.font!]).width
      if string.characters.count == 0 || string == " " {  // empty string == remove last symbol button
        let toBeRemovedText = (textField.text! as NSString).substringWithRange(range)
        let toBeRemovedTextWidth = (toBeRemovedText as NSString).sizeWithAttributes([NSFontAttributeName : textField.font!]).width
        if textFieldTextWidth >= currentEditingTextFieldWidth! - 40 {
          textField.bounds.size.width -= toBeRemovedTextWidth
          let newContentOffset = tableView.contentOffset.x - toBeRemovedTextWidth
          tableView.setContentOffset(CGPointMake(newContentOffset, 0), animated: false)
        }
      }
      let textWidth = (string as NSString).sizeWithAttributes([NSFontAttributeName : textField.font!]).width
      if textFieldTextWidth + textWidth >= textField.bounds.width - 40 {
        textField.bounds.size.width += textWidth
        let newContentOffset = tableView.contentOffset.x + textWidth
        tableView.setContentOffset(CGPointMake(newContentOffset, 0), animated: false)
      }
    }
    else {
      textField.bounds.size.width = defaultEditingTextFieldWidth
    }
    tableView.tableView.tableFooterView = tableView.tableView.tableFooterView!
    delegate?.searchBar?(self, shouldChangeTextInRange: range, replacementText: string)
    return true
  }
  
}

extension NimbusSearchBar : UISearchBarDelegate {
  
  func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
    struct Tokens { static var token: dispatch_once_t = 0 }
    dispatch_once(&Tokens.token) {
      NSTimer.after(0) { () -> Void in
        let view = UIViewController.currentViewController().searchDisplayController?.searchContentsController.view.subviews.last?.subviews[2]
        let newView = UIView(frame: view!.frame)  // crash
        let tap = UITapGestureRecognizer(target: self, action: "click:")
        newView.addGestureRecognizer(tap)
        newView.hidden = !self.dimsBackgroundDuringPresentation
        UIViewController.currentViewController().searchDisplayController?.searchContentsController.view.subviews.last?.addSubview(newView)
      }
    }
    
  
     // MARK: Move numbers to constants (navbar 64; tabBar 49)
    UIViewController.currentViewController().searchDisplayController?.searchResultsTableView.contentInset = UIEdgeInsetsMake(64, 0, 49, 0)
    
    UIViewController.currentViewController().searchDisplayController?.setActive(true, animated: true)
    if textField.text?.characters.count == 0 {
      if !dimsBackgroundDuringPresentation {
        delegate?.searchBar?(self, textDidChange: "")
      }
      UIViewController.currentViewController().searchDisplayController?.searchResultsTableView.alpha = 0
      NSTimer.after(0.4, { () -> Void in
        let fromView = UIViewController.currentViewController().searchDisplayController?.searchContentsController.view
        UIView.transitionWithView(fromView!, duration: 0.1, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
          UIViewController.currentViewController().searchDisplayController?.searchResultsTableView.alpha = 1
          }, completion: nil)
      })
      UIViewController.currentViewController().searchDisplayController?.searchContentsController.view.subviews.last?.subviews[2].hidden = !dimsBackgroundDuringPresentation  // dimmingView
    } else {
      UIViewController.currentViewController().searchDisplayController?.searchResultsTableView.hidden = false
      UIViewController.currentViewController().searchDisplayController?.searchContentsController.view.subviews.last?.subviews[2].hidden = true  // dimmingView
    }
    nimbusSearchBarDelegate?.nimbusSearchBarTextDidBeginEditing(self)
  }
  
  func searchBarTextDidEndEditing(searchBar: UISearchBar) {
    UIViewController.currentViewController().searchDisplayController?.searchResultsTableView.alpha = 0
    UIViewController.currentViewController().searchDisplayController?.setActive(false, animated: true)
    nimbusSearchBarDelegate?.nimbusSearchBarTextDidEndEditing(self)
  }
  
  func searchBarCancelButtonClicked(searchBar: UISearchBar) {
    cancel = true
    textField.text = ""
    textField.placeholder = "Search"
    currentEditingTextFieldWidth = defaultEditingTextFieldWidth
    tableView.reload()
    if !textField.isFirstResponder() {
      textField.delegate?.textFieldDidEndEditing?(textField)
    } else {
      textField.endEditing(true)
    }
    cancel = false
    UIViewController.currentViewController().searchDisplayController?.setActive(false, animated: true)
    nimbusSearchBarDelegate?.nimbusSearchBarCancelButtonClicked(self)
  }
  
  func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    nimbusSearchBarDelegate?.nimbusSearchBar(self, shouldChangeTextInRange: range, replacementText: text)
    return true
  }
  
  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    if textField.text?.characters.count == 0 {
      UIViewController.currentViewController().searchDisplayController?.searchResultsTableView.hidden = dimsBackgroundDuringPresentation
      UIViewController.currentViewController().searchDisplayController?.searchContentsController.view.subviews.last?.subviews[2].hidden = !dimsBackgroundDuringPresentation  // dimmingView
      if UIViewController.currentViewController().searchDisplayController?.searchContentsController.view.subviews.last?.subviews.count == 4 {
        UIViewController.currentViewController().searchDisplayController?.searchContentsController.view.subviews.last?.subviews[3].hidden = !dimsBackgroundDuringPresentation  // transparent view put on top of the dimming view (dimming view is incompatible with the gesture recognizer)
      }
    } else {
      UIViewController.currentViewController().searchDisplayController?.searchResultsTableView.hidden = false
      UIViewController.currentViewController().searchDisplayController?.searchContentsController.view.subviews.last?.subviews[2].hidden = true  // dimmingView
      UIViewController.currentViewController().searchDisplayController?.searchContentsController.view.subviews.last?.subviews[3].hidden = true  // transparent view put on top of the dimming view (dimming view is incompatible with the gesture recognizer)
    }
    UIViewController.currentViewController().searchDisplayController?.delegate?.searchDisplayController?(UIViewController.currentViewController().searchDisplayController!, shouldReloadTableForSearchString: searchText)
    nimbusSearchBarDelegate?.nimbusSearchBar(self, textDidChange: searchText)
  }
  
}

protocol NimbusSearchBarDelegate {
  // Reqired
  func nimbusSearchBarTableViewNumberOfRows(searchBar: NimbusSearchBar!) -> Int
  func nimbusSearchBarTableView(searchBar: NimbusSearchBar!, descriptionForRow row: Int) -> String
  func nimbusSearchBarTableView(searchBar: NimbusSearchBar!, iconImageForRow row: Int) -> UIImage
  // Optional
  func nimbusSearchBarShouldBeginEditing(searchBar: NimbusSearchBar) -> Bool // return NO to not become first responder
  func nimbusSearchBarTextDidBeginEditing(searchBar: NimbusSearchBar) // called when text starts editing
  func nimbusSearchBarShouldEndEditing(searchBar: NimbusSearchBar) -> Bool // return NO to not resign first responder
  func nimbusSearchBarTextDidEndEditing(searchBar: NimbusSearchBar) // called when text ends editing
  func nimbusSearchBar(searchBar: NimbusSearchBar, textDidChange searchText: String) // called when text changes (including clear)
  func nimbusSearchBar(searchBar: NimbusSearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool // called before text changes
  func nimbusSearchBarSearchButtonClicked(searchBar: NimbusSearchBar) // called when keyboard search button pressed
  func nimbusSearchBarBookmarkButtonClicked(searchBar: NimbusSearchBar) // called when bookmark button pressed
  func nimbusSearchBarCancelButtonClicked(searchBar: NimbusSearchBar) // called when cancel button pressed
  func nimbusSearchBarResultsListButtonClicked(searchBar: NimbusSearchBar) // called when search results button pressed
  func nimbusSearchBar(searchBar: NimbusSearchBar, selectedScopeButtonIndexDidChange selectedScope: Int)
}

extension NimbusSearchBarDelegate {
  func nimbusSearchBarShouldBeginEditing(searchBar: NimbusSearchBar) -> Bool {return true}
  func nimbusSearchBarTextDidBeginEditing(searchBar: NimbusSearchBar) {}
  func nimbusSearchBarShouldEndEditing(searchBar: NimbusSearchBar) -> Bool {return true}
  func nimbusSearchBarTextDidEndEditing(searchBar: NimbusSearchBar) {}
  func nimbusSearchBar(searchBar: NimbusSearchBar, textDidChange searchText: String) {}
  func nimbusSearchBar(searchBar: NimbusSearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {return true}
  func nimbusSearchBarSearchButtonClicked(searchBar: NimbusSearchBar) {}
  func nimbusSearchBarBookmarkButtonClicked(searchBar: NimbusSearchBar) {}
  func nimbusSearchBarCancelButtonClicked(searchBar: NimbusSearchBar) {}
  func nimbusSearchBarResultsListButtonClicked(searchBar: NimbusSearchBar) {}
  func nimbusSearchBar(searchBar: NimbusSearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {}
}





