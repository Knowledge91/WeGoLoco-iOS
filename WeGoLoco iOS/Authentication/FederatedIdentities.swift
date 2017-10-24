//
//  FederatedIdentities.swift
//  WeGoLoco iOS
//
//  Created by Dirk Hornung on 13/10/17.
//  Copyright © 2017 Dirk Hornung. All rights reserved.
//

import Foundation
import AWSCore
import AWSCognitoIdentityProvider

class FederatedIdentities {
    static var credentialsProvider: AWSCognitoCredentialsProvider!
    static var serviceConfiguration: AWSServiceConfiguration!
    
    static func register() {
        self.credentialsProvider = AWSCognitoCredentialsProvider(
            regionType: .EUWest1,
            identityPoolId: "eu-west-1:1ebd8c6e-2b3f-4732-83af-7e2aa2fd20d8",
            identityProviderManager: AWSCognitoIdentityUserPool(forKey: "UserPool"))
        self.serviceConfiguration = AWSServiceConfiguration(
            region: .EUWest1,
            credentialsProvider: credentialsProvider)
            
        // setup AWS service configuration
        AWSServiceManager.default().defaultServiceConfiguration = serviceConfiguration
    }
}

