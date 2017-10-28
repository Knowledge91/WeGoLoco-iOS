//
//  User.swift
//  WeGoLoco iOS
//
//  Created by Dirk Hornung on 13/10/17.
//  Copyright © 2017 Dirk Hornung. All rights reserved.
//

import Foundation
import AWSCognitoIdentityProvider
import PromiseKit

class User {
    static func getUserData() {
        let awsUser = UserPool.pool.currentUser()
        awsUser?.getDetails().continueOnSuccessWith { (task) -> AnyObject? in
            DispatchQueue.main.async(execute: {
                let userAttributes = (task.result)?.userAttributes
//                print(isRetailer(attributes: userAttributes!))
            })
            return nil
        }
    }
    
    static func identityId() -> String {
        return FederatedIdentities.credentialsProvider.identityId!
    }
    
    static func isSignedIn() -> Bool {
        let awsUser = UserPool.pool.currentUser()
        return (awsUser?.isSignedIn)!
    }

    static func signOut() {
        FederatedIdentities.credentialsProvider.clearCredentials()
        let awsUser = UserPool.pool.currentUser()
        awsUser?.signOut()
        awsUser?.getDetails()
    }
    
    static func signOutAndClean(tabBarController: UITabBarController) {

        // tabBar -> navigation -> view
        for vc in tabBarController.viewControllers! {
            // reset navigationControllers
            vc.navigationController?.popToRootViewController(animated: false)
            if let resetVC = vc.childViewControllers[0] as? Authentication {
                // reset viewControllers
                resetVC.clean()
            }
        }
        signOut()
    }
    
    static func getUserAttributes(_ completion: @escaping ([AWSCognitoIdentityProviderAttributeType]?, Error?)->()) {
        let awsUser = UserPool.pool.currentUser()
        awsUser?.getDetails().continueOnSuccessWith { (task) -> Void in
            let userAttributes = (task.result)?.userAttributes
            completion(userAttributes, nil)
        }
    }
    static func getUserAttributes() -> Promise<[AWSCognitoIdentityProviderAttributeType]> {
        return PromiseKit.wrap(getUserAttributes)
    }
    
    static func isRetailer(_ completion: @escaping (Bool?, Error?)->()) {
        firstly {
            self.getUserAttributes()
        }.then { attributes -> Void in
            for attribute in attributes {
                if attribute.name == "custom:role" && attribute.value == "retailer" {
                    completion(true, nil)
                }
            }
            completion(false, nil)
        }
    }
    static func isRetailer() -> Promise<Bool> {
        return PromiseKit.wrap(isRetailer)
    }

    
}
