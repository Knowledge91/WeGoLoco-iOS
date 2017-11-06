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
class TabBarController: UITabBarController, LoadingAnimationProtocol {
   
    // MARK: LoadingAnimationProtocol
    var loadingAnimationView: UIView!
    var loadingAnimationOverlay: UIView!
    var loadingAnimationIndicator: UIActivityIndicatorView!
    
    var user: User!
    let layerGradient = CAGradientLayer()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //LoadingAnimationProtocol
        loadingAnimationView = view
        
        updateItems()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layerGradient.colors = [CGColor]()
        for color in Colors.subuGradientColors {
            layerGradient.colors?.append(color.cgColor)
        }
        layerGradient.startPoint = CGPoint(x: 0, y: 0.5)
        layerGradient.endPoint = CGPoint(x: 1, y: 0.5)
        layerGradient.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        self.tabBar.layer.insertSublayer(layerGradient, at: 0)
        
        self.tabBar.unselectedItemTintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    public func showSwiper() {
        self.selectedIndex = 0
    }
    
    // MARK: Helper
    public func updateItems() {
        // load user and
        // remove Manager Tab if user is not a retailer
        startLoadingAnimation()
        firstly {
            UserAPI.getUser()
            }.then { user -> Void in
                self.user = user
                if !self.user.isRetailer {
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
                self.stopLoadingAnimation()
            }.catch { error in
                print(error)
        }
    }
    
    private func hasManagerVC() -> Bool {
        for vc in self.viewControllers! {
            if let _ = vc.childViewControllers[0] as? ManagerViewController {
                return true
            }
        }
        return false
    }
}
