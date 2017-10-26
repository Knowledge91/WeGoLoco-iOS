//
//  ForgotPasswordPasswordConfirmationViewController.swift
//  WeGoLoco iOS
//
//  Created by Dirk Hornung on 26/10/17.
//  Copyright © 2017 Dirk Hornung. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import Whisper

class ForgotPasswordPasswordConfirmationViewController: UIViewController {

    var user: AWSCognitoIdentityUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmationCodeTextField: UITextField!
    @IBAction func confirmButtonTouched(_ sender: Any) {
        user.confirmForgotPassword(confirmationCodeTextField.text!, password: newPasswordTextField.text!).continueWith { task -> Void in
            if let error = task.error {
                DispatchQueue.main.async {
                    let message = Message(title: String(describing: error), backgroundColor: .red)
                    Whisper.show(whisper: message, to: self.navigationController!, action: .show)
                }
            } else {
                DispatchQueue.main.async {
                    let message = Message(title: "Password changed!", backgroundColor: .green)
                    Whisper.show(whisper: message, to: self.navigationController!, action: .show)
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }
    
    @IBAction func resendConfirmationCodeButtonTouched(_ sender: UIButton) {
        print("confirmation")
        user.resendConfirmationCode()
    }

}
