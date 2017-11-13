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

struct User {
    var isRetailer: Bool
}

class UserAPI {
    static func getUser(completion: @escaping (Error?, User?)->() ) {
        firstly {
            getUserAttributes()
        }.then { attributes -> Void in
            var isRetailer = false
            for attribute in attributes {
                if attribute.name == "custom:role" && attribute.value == "retailer" {
                    isRetailer = true
                }
            }
            let user = User(isRetailer: isRetailer)
            completion(nil, user)
        }.catch { error in
            completion(error, nil)
        }
    }
    static func getUser() -> Promise<User?> {
        return PromiseKit.wrap{ getUser(completion: $0) }
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
        signOut()
        // tabBar -> navigation -> view
        for vc in tabBarController.viewControllers! {
            // reset navigationControllers
            vc.navigationController?.popToRootViewController(animated: false)
            if let resetVC = vc.childViewControllers[0] as? Authentication {
                // reset viewControllers
                resetVC.clean()
            }
        }
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
    
//    static func isRetailer(_ completion: @escaping (Bool?, Error?)->()) {
//        firstly {
//            self.getUserAttributes()
//        }.then { attributes -> Void in
//            for attribute in attributes {
//                if attribute.name == "custom:role" && attribute.value == "retailer" {
//                    completion(true, nil)
//                }
//            }
//            completion(false, nil)
//        }
//    }
//    static func isRetailer() -> Promise<Bool> {
//        return PromiseKit.wrap(isRetailer)
//    }
    
    static func updateAttribute(role: String, value: String, completion: @escaping (Error?)->() ) {
        let awsUser = UserPool.pool.currentUser()
        var attributes = [AWSCognitoIdentityUserAttributeType]()
        let retailerAttribute = AWSCognitoIdentityUserAttributeType()
        retailerAttribute?.name = role
        retailerAttribute?.value = value
        attributes.append(retailerAttribute!)
        awsUser?.update(attributes).continueWith { task -> Void in
            if let error = task.error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    static func updateAttribue(role: String, value: String) -> Promise<Void> {
        return PromiseKit.wrap{ updateAttribute(role: role, value: value, completion: $0) }
    }

    
}
