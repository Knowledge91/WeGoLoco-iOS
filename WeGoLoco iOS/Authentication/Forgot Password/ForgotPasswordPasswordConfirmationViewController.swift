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
        if isValid() {
            user.confirmForgotPassword(confirmationCodeTextField.text!, password: newPasswordTextField.text!).continueWith { task -> Void in
                if let error = task.error {
                    DispatchQueue.main.async {
                        let message = Message(title: "Wrong verification code!", backgroundColor: .red)
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
    }
    
    @IBAction func resendConfirmationCodeButtonTouched(_ sender: UIButton) {
        user.resendConfirmationCode()
    }
    
    // MARK: Helper
    private func isValid() -> Bool {
        if newPasswordTextField.text!.count < 6 {
            let message = Message(title: "A password needs min 6 characters!", backgroundColor: .red)
            Whisper.show(whisper: message, to: self.navigationController!, action: .show)
            return false
        }
        return true
    }
    

}
