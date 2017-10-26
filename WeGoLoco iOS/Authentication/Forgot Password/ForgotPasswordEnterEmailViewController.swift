//
//  ForgotPasswordEnterEmailViewController.swift
//  WeGoLoco iOS
//
//  Created by Dirk Hornung on 26/10/17.
//  Copyright © 2017 Dirk Hornung. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class ForgotPasswordEnterEmailViewController: UIViewController {

    var user: AWSCognitoIdentityUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var emailTextField: UITextField!
    @IBAction func SendConfirmationCodeButtonTouched(_ sender: UIButton) {
        user = UserPool.pool.getUser(emailTextField.text!)
        user!.forgotPassword()
        self.performSegue(withIdentifier: "passwordConfirmationSegue", sender: self)
    }

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let forgotPasswordConfirmationVC = segue.destination as? ForgotPasswordPasswordConfirmationViewController {
            forgotPasswordConfirmationVC.user = self.user
        }
    }
 

}
