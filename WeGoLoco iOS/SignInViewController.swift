//
//  ViewController.swift
//  AWS Mobile SDK
//
//  Created by Dirk Hornung on 8/10/17.
//  Copyright © 2017 Dirk Hornung. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>?
    var emailText: String?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.passwordTextField.text = nil
        self.emailTextField.text = nil
    }

    @IBAction func signInButtonTouched(_ sender: UIButton) {
        let authDetails = AWSCognitoIdentityPasswordAuthenticationDetails(username: self.emailTextField.text!, password: self.passwordTextField.text!)
        self.passwordAuthenticationCompletion?.set(result: authDetails)
    }

}


// API: http://docs.aws.amazon.com/AWSiOSSDK/latest/Protocols/AWSCognitoIdentityPasswordAuthentication.html
extension SignInViewController: AWSCognitoIdentityPasswordAuthentication {
    public func getDetails(_ authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource passwordAuthenticationComplectionSource: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>) {
        self.passwordAuthenticationCompletion = passwordAuthenticationComplectionSource
    }
    
    public func didCompleteStepWithError(_ error: Error?) {
        DispatchQueue.main.async {
            if let error = error as? NSError {
                let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                        message: error.userInfo["message"] as? String,
                                                        preferredStyle: .alert)
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
                alertController.addAction(retryAction)
                
                self.present(alertController, animated: true, completion:  nil)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
