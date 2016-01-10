//
//  MainTabBarVC.swift
//  VKStorage
//
//  Created by Mike on 1/6/16.
//  Copyright © 2016 BIBORAM. All rights reserved.
//

import Foundation

class MainTabBarVC: UITabBarController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    delegate = self
    let filesVC = UINavigationController(rootViewController: FilesVC())
    self.viewControllers = [filesVC]
  }
  

}

extension MainTabBarVC : UITabBarControllerDelegate {


}