//
//  MainViewController.swift
//  AWS Mobile SDK
//
//  Created by Dirk Hornung on 9/10/17.
//  Copyright © 2017 Dirk Hornung. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class MainViewController: UIViewController {
    var user: AWSCognitoIdentityUser?
    var userPool: AWSCognitoIdentityUserPool?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Main loaded")
        
        self.userPool = AWSCognitoIdentityUserPool(forKey: "UserPool")
        if ( self.user == nil) {
            self.user = self.userPool?.currentUser()
        }

        self.user?.getDetails().continueOnSuccessWith { (task) -> AnyObject? in
            DispatchQueue.main.async(execute: {
                self.title = self.user?.username
                print("Title: \(self.title)")
            })
            return nil
        }
    }
    
    @IBAction func signOut(_ sender: AnyObject) {
        self.user?.signOut()
        self.title = nil
        self.user?.getDetails()
    }

}
