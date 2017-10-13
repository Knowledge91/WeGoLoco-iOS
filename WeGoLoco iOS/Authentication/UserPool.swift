//
//  UserPool.swift
//  WeGoLoco iOS
//
//  Created by Dirk Hornung on 13/10/17.
//  Copyright © 2017 Dirk Hornung. All rights reserved.
//

import Foundation
import AWSCognitoIdentityProvider

// Following: https://stackoverflow.com/questions/37260766/ios-aws-mobilehub-sign-in-with-developer-authenticated-provider/40268100#40268100
class UserPool {
    static var serviceConfiguration: AWSServiceConfiguration!
    static var userPoolConfiguration: AWSCognitoIdentityUserPoolConfiguration!
    static var pool: AWSCognitoIdentityUserPool!
    static var user: AWSCognitoIdentityUser?
    
    static func register() {
        // setup service configuration
        self.serviceConfiguration = AWSServiceConfiguration(
            region: .EUWest1,
            credentialsProvider: nil)
        // create user pool configuration
        self.userPoolConfiguration = AWSCognitoIdentityUserPoolConfiguration(clientId: "65fdrigc1ot1bcac93q1miuh5c",
                                                                            clientSecret: "1r2pkpqhr9ubhcf7mhctprn0hqj9qsevqd4q910rgnpn3sbv1lif",
                                                                            poolId: "eu-west-1_3pXUAmj5o")
        // initialize pool configuration
        AWSCognitoIdentityUserPool.register(with: serviceConfiguration, userPoolConfiguration: userPoolConfiguration, forKey: "UserPool")
        // init userPool
        self.pool = AWSCognitoIdentityUserPool(forKey: "UserPool")
    }
}
