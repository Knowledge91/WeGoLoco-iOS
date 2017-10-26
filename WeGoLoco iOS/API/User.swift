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

    static func signOut() {
        let awsUser = UserPool.pool.currentUser()
        awsUser?.signOut()
        awsUser?.getDetails()
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
