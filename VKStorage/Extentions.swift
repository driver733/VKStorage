//
//  Extentions.swift
//  VKStorage
//
//  Created by Mike on 1/5/16.
//  Copyright © 2016 BIBORAM. All rights reserved.
//

import Foundation

extension NSDate {
  func yearsFrom(date:NSDate) -> Int{
    return NSCalendar.currentCalendar().components(.Year, fromDate: date, toDate: self, options: []).year
  }
  func monthsFrom(date:NSDate) -> Int{
    return NSCalendar.currentCalendar().components(.Month, fromDate: date, toDate: self, options: []).month
  }
  func weeksFrom(date:NSDate) -> Int{
    return NSCalendar.currentCalendar().components(.WeekOfYear, fromDate: date, toDate: self, options: []).weekOfYear
  }
  func daysFrom(date:NSDate) -> Int{
    return NSCalendar.currentCalendar().components(.Day, fromDate: date, toDate: self, options: []).day
  }
  func hoursFrom(date:NSDate) -> Int{
    return NSCalendar.currentCalendar().components(.Hour, fromDate: date, toDate: self, options: []).hour
  }
  func minutesFrom(date:NSDate) -> Int{
    return NSCalendar.currentCalendar().components(.Minute, fromDate: date, toDate: self, options: []).minute
  }
  func secondsFrom(date:NSDate) -> Int{
    return NSCalendar.currentCalendar().components(.Second, fromDate: date, toDate: self, options: []).second
  }
  func offsetFrom(date:NSDate) -> String {
    if yearsFrom(date)   > 0 { return "\(yearsFrom(date))y"   }
    if monthsFrom(date)  > 0 { return "\(monthsFrom(date))M"  }
    if weeksFrom(date)   > 0 { return "\(weeksFrom(date))w"   }
    if daysFrom(date)    > 0 { return "\(daysFrom(date))d"    }
    if hoursFrom(date)   > 0 { return "\(hoursFrom(date))h"   }
    if minutesFrom(date) > 0 { return "\(minutesFrom(date))m" }
    if secondsFrom(date) > 0 { return "\(secondsFrom(date))s" }
    return ""
  }
}

extension NSDate {
  
  func dateMonthsAgo(monthsAgo: Int) -> NSDate {
    let comps = NSCalendar.currentCalendar().components([.Month], fromDate: self)
    comps.month = -monthsAgo
    return NSCalendar.currentCalendar().dateByAddingComponents(comps, toDate: self, options: NSCalendarOptions.MatchStrictly)!
  }
  
  func dateYearsAgo(yearsAgo: Int) -> NSDate {
    let comps = NSCalendar.currentCalendar().components([.Month], fromDate: self)
    comps.year = -yearsAgo
    return NSCalendar.currentCalendar().dateByAddingComponents(comps, toDate: self, options: NSCalendarOptions.MatchStrictly)!
  }
  
}

extension UIColor {
  convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
    self.init(red: r/255, green: g/255, blue: b/255, alpha: 1.0)
  }
  convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
    self.init(red: r/255, green: g/255, blue: b/255, alpha: a)
  }
  class func searchBarSelectionBaseViewColor() -> UIColor {
    return UIColor(r: 0, g: 122, b: 255)
  }
  class func searchBarSelectionBarColor() -> UIColor {
    return UIColor(r: 20, g: 111, b: 225)
  }
  class func searchBarBaseViewColor() -> UIColor {
    return UIColor(r: 161, g: 161, b: 161)
  }
}

extension String {
  subscript (i: Int) -> Character {
    return self[self.startIndex.advancedBy(i)]
  }
}

extension UIView {
  class func loadFromNibNamed(nibNamed: String, bundle : NSBundle? = nil) -> UIView? {
    return UINib(
      nibName: nibNamed,
      bundle: bundle
      ).instantiateWithOwner(nil, options: nil)[0] as? UIView
  }
}

extension LoadingStateDelegate {
  
  func didStartNetworingActivity() {
    let loadingStateView = LoadingIndicatorView()
    UIViewController.currentViewController().view.addSubview(loadingStateView)
  }
  
  func didEndNetworingActivity() {
    if let loadingView = UIViewController.currentViewController().view.viewWithTag(LoadingIndicatorViewTag) as? LoadingIndicatorView {
      loadingView.toggleTickWithTimeIntervalExpirationBlock({ () -> Void in
      })
    }
  }
  
}

extension UIViewController {
  
  class func currentViewController() -> UIViewController {
    var topController = UIApplication.sharedApplication().keyWindow?.rootViewController
    while ((topController?.presentedViewController) != nil) {
      topController = topController?.presentedViewController
    }
    if let tabBarVC = topController as? UITabBarController {
      topController = tabBarVC.selectedViewController
    }
    if let navC = topController as? UINavigationController {
      topController = navC.viewControllers.first
    }
    return topController!
  }
  
}

extension DefaultsKeys {
  static var isLoggedIn = DefaultsKey<Bool>("isLoggedIn")
}