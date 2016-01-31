//
//  NimbusSearchBar.swift
//  VKStorage
//
//  Created by Mike on 1/19/16.
//  Copyright © 2016 BIBORAM. All rights reserved.
//

import Foundation

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

class NimbusCell: UITableViewCell {
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }
  
  convenience init(text: String) {
    self.init(style: .Default, reuseIdentifier: nil)
    let baseView = UIView()
    baseView.backgroundColor = UIColor.lightGrayColor()
    baseView.layer.cornerRadius = 4
    let imageView = UIImageView(image: imageWithColor(.greenColor(), size: CGSizeMake(20, 20)))
    
    let label = UILabel()
    label.text = text
    label.font = UIFont.systemFontOfSize(UIFont.systemFontSize())
    label.textColor = .whiteColor()
    let height = (text as NSString).sizeWithAttributes([NSFontAttributeName : label.font]).height - 6
    baseView.addSubview(label)
    baseView.addSubview(imageView)
    contentView.addSubview(baseView)
    contentView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI)/2) // rotate by 90 degrees
    
    baseView.snp_makeConstraints { (make) -> Void in
      make.top.leading.equalTo(2.5)
      make.bottom.trailing.equalTo(-2.5)
    }
    imageView.snp_makeConstraints { (make) -> Void in
      make.leading.equalTo(5)
      make.centerY.equalTo(baseView.bounds.midY)
      make.width.equalTo(imageView.snp_height)
      make.height.equalTo(height)
    }
    label.snp_makeConstraints { (make) -> Void in
      make.leading.equalTo(imageView.snp_trailing).offset(6)
      make.width.lessThanOrEqualTo(120)
      make.top.bottom.trailing.equalTo(0)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
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
    self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)
    clearButtonMode = .Always
    font = UIFont.systemFontOfSize(UIFont.systemFontSize())
    placeholder = "Search"
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
}

class NimbusSearchBar: UISearchBar {
  
  var tableView: EasyTableView!
  var textField: HorizontalUITextField!
  var backgroundView: UIView!
  
  var nimbusSearchBarDelegate: NimbusSearchBarDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
   
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func drawRect(rect: CGRect) {
    addTableView()
  }
  
  func rec(view: UIView) {
//    if view.isKindOfClass(UIButton) {
//      (view as! UIButton).addTarget(self, action: "push:", forControlEvents: .TouchUpInside)
//    }
    print(view)
    for subView in view.subviews {
      rec(subView)
    }
    
  }

  func addTableView() {

    let searchBarTextField = subviews[0].subviews[1]
    let magnifyingGlass = subviews[0].subviews[1].subviews[1] as! UIImageView
  
    delegate = self
  
    tableView = EasyTableView(frame: searchBarTextField.frame, ofWidth: 0)
    tableView.tableView.separatorStyle = .None
    tableView.orientation = .Horizontal
    tableView.delegate = self
    backgroundView = UIView(frame: searchBarTextField.frame)
    backgroundView.layer.cornerRadius = 5
    backgroundView.clipsToBounds = true
    tableView.frame = backgroundView.bounds
    backgroundView.addSubview(tableView)
    insertSubview(backgroundView, belowSubview: searchBarTextField)
    searchBarTextField.removeFromSuperview()
    textField = HorizontalUITextField(frame: CGRectMake(0, 0, 0, searchBarTextField.bounds.width - 30))
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldTextDidChange:", name: UITextFieldTextDidChangeNotification, object: nil)
    textField.delegate = self
    tableView.tableView.tableFooterView = textField
    tableView.contentOffset = CGPointMake(0, 0)
    let width = (textField.placeholder! as NSString).sizeWithAttributes([NSFontAttributeName : textField.font!]).width - 6
    let headerView = UIView(frame: CGRectMake(0, 0, searchBarTextField.bounds.height, searchBarTextField.bounds.midX - width/2))
    magnifyingGlass.transform = CGAffineTransformMakeRotation(CGFloat(M_PI)/2) // rotate by 90 degrees
    headerView.addSubview(magnifyingGlass)
    tableView.tableView.tableHeaderView = headerView
    
    
    let tap = UITapGestureRecognizer(target: self, action: "click:")
  //  tap.delegate = self
    tap.numberOfTouchesRequired = 1
    tap.numberOfTapsRequired = 1
    
   // superview?.addGestureRecognizer(tap)

    
    
    
    
    magnifyingGlass.snp_makeConstraints { (make) -> Void in
      make.bottom.equalTo(-10)
      make.centerX.equalTo(0)
    }
    
  }
  
  
  func click(rec: UITapGestureRecognizer) {

    delegate?.searchBarTextDidEndEditing?(self)
  }
  
  
  
  
  
  func textFieldTextDidChange(notif: NSNotification) {
    delegate?.searchBar?(self, textDidChange: textField.text!)
  }
  
}





extension NimbusSearchBar : EasyTableViewDelegate {
  func easyTableView(easyTableView: EasyTableView!, heightOrWidthForCellAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
    return 120
  }
  func easyTableView(easyTableView: EasyTableView!, numberOfRowsInSection section: Int) -> Int {
    return 0
  }
  func easyTableView(easyTableView: EasyTableView!, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    return NimbusCell(text: "hesdfgsdfgsdfgsdfgsdgsgsdllo")
  }
}
extension NimbusSearchBar : UITextFieldDelegate {
  func textFieldShouldClear(textField: UITextField) -> Bool {
    self.textField.text = ""
    return true
  }
  func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
    delegate?.searchBarShouldBeginEditing?(self)
    return true
  }
  func textFieldDidBeginEditing(textField: UITextField) {
    let tableViewHeader = self.tableView.tableView.tableHeaderView!
    let magnifyingGlass = self.tableView.tableView.tableHeaderView?.subviews[0] as! UIImageView
    magnifyingGlass.snp_remakeConstraints(closure: { (make) -> Void in
      make.center.equalTo(CGPointMake(0, 0))
    })
    UIView.animateWithDuration(0.2, animations: { () -> Void in
      self.backgroundView.frame.size = CGSizeMake(self.backgroundView.bounds.width-60, self.backgroundView.bounds.height)
      self.tableView.frame = self.backgroundView.bounds
      tableViewHeader.bounds.size = CGSizeMake(magnifyingGlass.bounds.height, magnifyingGlass.bounds.width + 10)
      self.tableView.tableView.tableHeaderView = tableViewHeader
      tableViewHeader.layoutIfNeeded()
      self.tableView.tableView.tableFooterView?.frame.size = CGSizeMake((self.tableView.tableView.tableFooterView?.frame.size.width)!, (self.tableView.tableView.tableFooterView?.frame.size.height)!-55)
    })
     delegate?.searchBarTextDidBeginEditing?(self)
  }
  func textFieldDidEndEditing(textField: UITextField) {
    self.tableView.tableView.tableFooterView?.frame.size = CGSizeMake((self.tableView.tableView.tableFooterView?.frame.size.width)!, (self.tableView.tableView.tableFooterView?.frame.size.height)!+55)
    UIView.animateWithDuration(0.2, animations: { () -> Void in
      self.backgroundView.frame.size = CGSizeMake(self.backgroundView.bounds.width+60, self.backgroundView.bounds.height)
      self.tableView.frame = self.backgroundView.bounds
    })
    delegate?.searchBarTextDidEndEditing?(self)
  }
  
  func textFieldShouldEndEditing(textField: UITextField) -> Bool {
    delegate?.searchBarShouldEndEditing?(self)
    return true
  }
  
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    if easyTableView(tableView, numberOfRowsInSection: 0) > 0 {
      let tableViewFooterView = tableView.tableView.tableFooterView!
      let textFieldTextWidth = ((textField.text!) as NSString).sizeWithAttributes([NSFontAttributeName : textField.font!]).width
      if string.characters.count == 0 {
        let toBeRemovedText = (textField.text! as NSString).substringWithRange(range)
        let toBeRemovedTextWidth = (toBeRemovedText as NSString).sizeWithAttributes([NSFontAttributeName : textField.font!]).width
        
        if tableView.contentOffset.x + tableView.tableView.tableHeaderView!.frame.width + textFieldTextWidth + toBeRemovedTextWidth > tableView.tableView.tableFooterView!.bounds.width - 30 {
          tableViewFooterView.frame.size.height -= toBeRemovedTextWidth
          tableView.tableView.tableFooterView = tableViewFooterView
          tableView.contentOffset.x -= toBeRemovedTextWidth
        }
      }
      let textWidth = (string as NSString).sizeWithAttributes([NSFontAttributeName : textField.font!]).width
      if tableView.contentOffset.x + tableView.tableView.tableHeaderView!.frame.width + textFieldTextWidth + textWidth > tableView.tableView.tableFooterView!.bounds.width - 30 {
        tableViewFooterView.frame.size.height += textWidth
        tableView.tableView.tableFooterView = tableViewFooterView
        tableView.contentOffset.x += textWidth
      }
    }
    delegate?.searchBar?(self, shouldChangeTextInRange: range, replacementText: string)
    return true
  }
  
}

extension NimbusSearchBar : UISearchBarDelegate {
  func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
    NSTimer.after(0) { () -> Void in
      struct Tokens { static var token: dispatch_once_t = 0 }
      dispatch_once(&Tokens.token) {
        let tap = UITapGestureRecognizer(target: self, action: "click:")
        let view = UIViewController.currentViewController().searchDisplayController?.searchContentsController.view.subviews.last?.subviews[2]
        let newView = UIView(frame: view!.frame)
        newView.addGestureRecognizer(tap)
        UIViewController.currentViewController().searchDisplayController?.searchContentsController.view.subviews.last?.addSubview(newView)
      }
    }
    print(UIViewController.currentViewController().searchDisplayController?.searchContentsController.view.subviews.last)
    
    UIViewController.currentViewController().searchDisplayController?.searchResultsTableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
    UIViewController.currentViewController().searchDisplayController?.setActive(true, animated: true)
    
    if textField.text?.characters.count == 0 {
      UIViewController.currentViewController().searchDisplayController?.searchResultsTableView.hidden = true
      UIViewController.currentViewController().searchDisplayController?.searchContentsController.view.subviews.last?.subviews[2].hidden = false  // dimmingView
    } else {
      UIViewController.currentViewController().searchDisplayController?.searchResultsTableView.hidden = false
      UIViewController.currentViewController().searchDisplayController?.searchContentsController.view.subviews.last?.subviews[2].hidden = true  // dimmingView
    }

    nimbusSearchBarDelegate?.nimbusSearchBarTextDidBeginEditing(self)
  }
  func searchBarTextDidEndEditing(searchBar: UISearchBar) {
    UIViewController.currentViewController().searchDisplayController?.setActive(false, animated: true)
    self.endEditing(true)
    nimbusSearchBarDelegate?.nimbusSearchBarTextDidEndEditing(self)
  }
  func searchBarCancelButtonClicked(searchBar: UISearchBar) {
    UIViewController.currentViewController().searchDisplayController?.setActive(false, animated: true)
    self.textField.text = ""
    self.textField.endEditing(true)
    nimbusSearchBarDelegate?.nimbusSearchBarCancelButtonClicked(self)
  }
  func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    nimbusSearchBarDelegate?.nimbusSearchBar(self, shouldChangeTextInRange: range, replacementText: text)
    return true
  }
  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    
    if textField.text?.characters.count == 0 {
      UIViewController.currentViewController().searchDisplayController?.searchResultsTableView.hidden = true
      UIViewController.currentViewController().searchDisplayController?.searchContentsController.view.subviews.last?.subviews[2].hidden = false  // dimmingView
    } else {
      UIViewController.currentViewController().searchDisplayController?.searchResultsTableView.hidden = false
      UIViewController.currentViewController().searchDisplayController?.searchContentsController.view.subviews.last?.subviews[2].hidden = true  // dimmingView
    }
    UIViewController.currentViewController().searchDisplayController?.delegate?.searchDisplayController?(UIViewController.currentViewController().searchDisplayController!, shouldReloadTableForSearchString: searchText)
    nimbusSearchBarDelegate?.nimbusSearchBar(self, textDidChange: searchText)
  }
  
  
  
  
}



//extension NimbusSearchBar : UIGestureRecognizerDelegate {
//  override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
//    
//    return true
//  }
//  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//    
//    return true
//  }
//}


protocol NimbusSearchBarDelegate {

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
  func nimbusSearchBarShouldBeginEditing(searchBar: NimbusSearchBar) -> Bool {
    return true
  }
  func nimbusSearchBarTextDidBeginEditing(searchBar: NimbusSearchBar) {
  }
  func nimbusSearchBarShouldEndEditing(searchBar: NimbusSearchBar) -> Bool {
    return true
  }
  func nimbusSearchBarTextDidEndEditing(searchBar: NimbusSearchBar) {
  }
  func nimbusSearchBar(searchBar: NimbusSearchBar, textDidChange searchText: String) {
  }
  func nimbusSearchBar(searchBar: NimbusSearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    return true
  }
  func nimbusSearchBarSearchButtonClicked(searchBar: NimbusSearchBar) {
  }
  func nimbusSearchBarBookmarkButtonClicked(searchBar: NimbusSearchBar) {
  }
  func nimbusSearchBarCancelButtonClicked(searchBar: NimbusSearchBar) {
  }
  func nimbusSearchBarResultsListButtonClicked(searchBar: NimbusSearchBar) {
  }
  func nimbusSearchBar(searchBar: NimbusSearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
  }
}





