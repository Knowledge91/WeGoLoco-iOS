//
//  AppDelegate.swift
//  AWS Mobile SDK
//
//  Created by Dirk Hornung on 8/10/17.
//  Copyright © 2017 Dirk Hornung. All rights reserved.
//

import UIKit
import AWSCore
import AWSCognito
import AWSCognitoIdentityProvider
import IQKeyboardManager

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var signInViewController: SignInViewController?
    var navigationController: UINavigationController?
    var storyboard: UIStoryboard?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UIFont.overrideInitialize()
        // default tint color
        self.window?.tintColor = Colors.first
        
        // setup logs
        AWSDDLog.sharedInstance.logLevel = .verbose
        
        // MARK: - User Pool
        UserPool.register()
        // MARK: - Federated Identities
        FederatedIdentities.register()
        
        // fetch the user pool client we initialized in above step
        self.storyboard = UIStoryboard(name: "Main", bundle: nil)
        UserPool.pool.delegate = self

        // IQKeyboardManger
        // prevent keyboard of hiding textviews
        IQKeyboardManager.shared().isEnabled = true
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

// MARK: - AWSCognitoIdentityInteractiveAuthenticationDelegate protocol delegate


// API: http://docs.aws.amazon.com/AWSiOSSDK/latest/Protocols/AWSCognitoIdentityInteractiveAuthenticationDelegate.html
extension AppDelegate: AWSCognitoIdentityInteractiveAuthenticationDelegate {
    
    func startPasswordAuthentication() -> AWSCognitoIdentityPasswordAuthentication {
        if (self.navigationController == nil) {
            self.navigationController = self.storyboard?.instantiateViewController(withIdentifier: "signInNavigationController") as? UINavigationController
        }
        
        if (self.signInViewController == nil) {
            self.signInViewController = self.navigationController?.viewControllers[0] as? SignInViewController
        }
        
        DispatchQueue.main.async {
            self.navigationController!.popToRootViewController(animated: true)
            if (!self.navigationController!.isViewLoaded
                || self.navigationController!.view.window == nil) {

                self.window?.rootViewController?.present(self.navigationController!,
                                                         animated: true,
                                                         completion: nil)
            }
        }
        
        return self.signInViewController!
    }
}

