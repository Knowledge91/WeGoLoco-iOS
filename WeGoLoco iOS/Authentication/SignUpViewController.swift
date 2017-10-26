//
//  SignUpViewController.swift
//  WeGoLoco iOS
//
//  Created by Dirk Hornung on 11/10/17.
//  Copyright © 2017 Dirk Hornung. All rights reserved.
//

import UIKit
import Eureka
import Whisper
import AWSCognitoIdentityProvider

class SignUpViewController: FormViewController {

    private var userPool: AWSCognitoIdentityUserPool?
    private var emailToConfirm: String?
    private var email: String! {
        let emailRow =  form.rowBy(tag: "emailRow") as! EmailRow
        return emailRow.value
    }
    private var password: String! {
        let passwordRow = form.rowBy(tag: "passwordRow") as! PasswordRow
        return passwordRow.value
    }
    private var gender: String! {
        let genderRow = form.rowBy(tag: "genderRow") as! SegmentedRow<String>
        return genderRow.value
    }
    private var birthdate: String! {
        let birthdateRow = form.rowBy(tag: "birthdateRow") as! DateRow
        let birthdate = birthdateRow.value
        return birthdate?.DDMMyyyy
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userPool = AWSCognitoIdentityUserPool(forKey: "UserPool")
        
        form
            +++ Section("Email & Password")
            <<< EmailRow() {
                $0.title = "Email"
                $0.tag = "emailRow"
                $0.placeholder = "here@wegoloco.es"
            }
            <<< PasswordRow() {
                $0.title = "Password"
                $0.tag = "passwordRow"
            }
        
            +++ Section("Birthday & Gender")
                <<< DateRow() {
                    $0.title = "Birthdate"
                    $0.tag = "birthdateRow"
                    $0.value = Date()
                }
                <<< SegmentedRow<String>() {
                    $0.title = "Gender"
                    $0.tag = "genderRow"
                    $0.options = ["male", "female"]
                    $0.value = "male"
                }
        
            +++ Section()
                <<< ButtonRow() {
                    $0.title = "Sign Up"
                }.onCellSelection { _, _ in
                    self.signUp()
                }
    }
    
    // MARK: - Helper
    private func getUserAttributes() -> [AWSCognitoIdentityUserAttributeType] {
        var attributes = [AWSCognitoIdentityUserAttributeType]()
        
        let genderAttribute = AWSCognitoIdentityUserAttributeType()
        genderAttribute?.name = "gender"
        genderAttribute?.value = self.gender
        attributes.append(genderAttribute!)
        
        let birthdateAttribute = AWSCognitoIdentityUserAttributeType()
        birthdateAttribute?.name = "birthdate"
        birthdateAttribute?.value = birthdate
        attributes.append(birthdateAttribute!)
        
        let roleAttribute = AWSCognitoIdentityUserAttributeType()
        roleAttribute?.name = "custom:role"
        roleAttribute?.value = "retailer"
        attributes.append(roleAttribute!)

        
        return attributes
    }
    
    private func signUp() {
        userPool?.signUp(email, password: password, userAttributes: getUserAttributes(), validationData: nil).continueWith { [weak self] task -> Void in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async(execute: {
                if let error = task.error as NSError? {
                    let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                            message: error.userInfo["message"] as? String,
                                                            preferredStyle: .alert)
                    let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
                    alertController.addAction(retryAction)
                    
                    self?.present(alertController, animated: true, completion:  nil)
                } else if let result = task.result  {
                    // handle the case where user has to confirm his identity via email / SMS
                    if (result.user.confirmedStatus != AWSCognitoIdentityUserStatus.confirmed) {
                        strongSelf.emailToConfirm = result.codeDeliveryDetails?.destination
                        strongSelf.performSegue(withIdentifier: "confirmSignUpSegue", sender:self)
                    } else {
                        let _ = strongSelf.navigationController?.popToRootViewController(animated: true)
                    }
                }
            })
        }
    }
    
    
     // MARK: - Navigation
     
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let emailConfirmationViewController = segue.destination as! EmailConfirmationViewController
        emailConfirmationViewController.emailToConfirm = emailToConfirm
        emailConfirmationViewController.user = self.userPool?.getUser(self.email)
     }
}
