//
//  TabBarController.swift
//  WeGoLoco iOS
//
//  Created by Dirk Hornung on 13/10/17.
//  Copyright © 2017 Dirk Hornung. All rights reserved.
//

import UIKit
import AWSS3
import PromiseKit

// Hides Manager Tab-item if user is not retailer
class TabBarController: UITabBarController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // remove Manager Tab if user is not a retailer
        firstly {
            User.isRetailer()
        }.then { isRetailer -> Void in
            if !isRetailer {
                for (index, vc) in self.viewControllers!.enumerated() {
                    // navigationController.child -> ManagerController
                    if let _ = vc.childViewControllers[0] as? ManagerViewController {
                        self.viewControllers?.remove(at: index)
                    }
                }
            } else {
                if !self.hasManagerVC() {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let managerNavigationController = storyboard.instantiateViewController(withIdentifier: "managerNavigationController")
                    self.viewControllers?.insert(managerNavigationController, at: 1)
                }
            }
        }.catch { error in
            print(error)
        }
    }
    
    public func showSwiper() {
        self.selectedIndex = 0
    }
    
    // MARK: Helper
    private func hasManagerVC() -> Bool {
        for vc in self.viewControllers! {
            if let _ = vc.childViewControllers[0] as? ManagerViewController {
                return true
            }
        }
        return false
    }
}
