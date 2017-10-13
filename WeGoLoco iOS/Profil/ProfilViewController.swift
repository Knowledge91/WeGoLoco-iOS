//
//  MainViewController.swift
//  AWS Mobile SDK
//
//  Created by Dirk Hornung on 9/10/17.
//  Copyright © 2017 Dirk Hornung. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import AWSS3

class ProfilViewController: UIViewController {
    var user: AWSCognitoIdentityUser?
    var userPool: AWSCognitoIdentityUserPool?
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func signOut(_ sender: AnyObject) {
        User.signOut()
    }

}
