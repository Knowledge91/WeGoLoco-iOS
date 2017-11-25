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

    var isRetailer: Bool!
    
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
    private var shopName: String! {
        let shopNameRow = form.rowBy(tag: "shopNameRow") as! TextRow
        let shopName = shopNameRow.value
        return shopName
    }
    private var phone: String! {
        let phoneRow = form.rowBy(tag: "phoneRow") as! PhoneRow
        let phone = phoneRow.value
        return phone
    }
    private var city: String! {
        let cityRow = form.rowBy(tag: "cityRow") as! TextRow
        return cityRow.value
    }
    private var street: String! {
        let streetRow = form.rowBy(tag: "streetRow") as! TextRow
        return streetRow.value
    }
    private var postalCode: String! {
        let postalCodeRow = form.rowBy(tag: "postalCodeRow") as! PhoneRow
        return String(describing: postalCodeRow.value!)
    }
    
    var triedToSignUp = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("isRetailer? \(isRetailer)")
        
        self.tableView.backgroundColor = Colors.background
        self.userPool = AWSCognitoIdentityUserPool(forKey: "UserPool")
        
        if isRetailer {
            retailerForm()
        } else {
            userForm()
        }
    }
    
    // MARK: - Helper
    private func retailerForm() -> Form {
        return form
            +++ Section("Contact & Password")
            <<< TextRow() {
                $0.title = "Shop Name"
                $0.tag = "shopNameRow"
                $0.placeholder = "Adidas"
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                }.cellSetup { cell, row in
                    cell.tintColor = Colors.second
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
            }
            <<< EmailRow() {
                $0.title = "Email"
                $0.tag = "emailRow"
                $0.placeholder = "here@wegoloco.es"
                $0.add(rule: RuleRequired())
                $0.add(rule: RuleEmail())
                $0.validationOptions = .validatesOnChange
                }.cellSetup { cell, row in
                    cell.tintColor = Colors.second
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
            }
            <<< PhoneRow() {
                $0.title = "Phone"
                $0.tag = "phoneRow"
                $0.placeholder = "here@wegoloco.es"
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                }.cellSetup { cell, row in
                    cell.tintColor = Colors.second
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
            }
            <<< TextRow() {
                $0.title = "City"
                $0.tag = "cityRow"
                $0.placeholder = "Barcelona"
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                }.cellSetup { cell, row in
                    cell.tintColor = Colors.second
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
            }
            <<< TextRow() {
                $0.title = "Street"
                $0.tag = "streetRow"
                $0.placeholder = "Carrer de Gracia 12"
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                }.cellSetup { cell, row in
                    cell.tintColor = Colors.second
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
            }
            <<< PhoneRow() {
                $0.title = "Postal Code"
                $0.tag = "postalCodeRow"
                $0.placeholder = "08001"
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                }.cellSetup { cell, row in
                    cell.tintColor = Colors.second
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
            }
            <<< PasswordRow() {
                $0.title = "Password"
                $0.tag = "passwordRow"
                $0.add(rule: RuleRequired())
                $0.add(rule: RuleMinLength(minLength: 6))
                $0.validationOptions = .validatesOnChange
                }.cellSetup { cell, row in
                    cell.tintColor = Colors.second
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
            }
            
            +++ Section("Birthday & Gender")
            <<< DateRow() {
                $0.title = "Birthdate"
                $0.tag = "birthdateRow"
                $0.value = Date()
                }.cellSetup { cell, row in
                    cell.tintColor = Colors.second
            }
            <<< SegmentedRow<String>() {
                $0.title = "Gender"
                $0.tag = "genderRow"
                $0.options = ["male", "female"]
                $0.value = "male"
                }.cellSetup { cell, row in
                    cell.tintColor = Colors.second
            }
            
            +++ Section()
            <<< ButtonRow() {
                $0.title = "Sign Up"
                }.cellUpdate{ cell, row in
                    cell.textLabel?.textColor = Colors.first
                }.onCellSelection { _, _ in
                    self.signUp()
        }
    }
    private func userForm() -> Form {
        return form
            +++ Section("Email & Password")
            <<< EmailRow() {
                $0.title = "Email"
                $0.tag = "emailRow"
                $0.placeholder = "here@wegoloco.es"
                $0.add(rule: RuleRequired())
                $0.add(rule: RuleEmail())
                $0.validationOptions = .validatesOnChange
                }.cellSetup { cell, row in
                    cell.tintColor = Colors.second
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
            }
            <<< PasswordRow() {
                $0.title = "Password"
                $0.tag = "passwordRow"
                $0.add(rule: RuleRequired())
                $0.add(rule: RuleMinLength(minLength: 6))
                $0.validationOptions = .validatesOnChange
                }.cellSetup { cell, row in
                    cell.tintColor = Colors.second
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
            }
            
            +++ Section("Birthday & Gender")
            <<< DateRow() {
                $0.title = "Birthdate"
                $0.tag = "birthdateRow"
                $0.value = Date()
                }.cellSetup { cell, row in
                    cell.tintColor = Colors.second
            }
            <<< SegmentedRow<String>() {
                $0.title = "Gender"
                $0.tag = "genderRow"
                $0.options = ["male", "female"]
                $0.value = "male"
                }.cellSetup { cell, row in
                    cell.tintColor = Colors.second
            }
            
            +++ Section()
            <<< ButtonRow() {
                $0.title = "Sign Up"
                }.cellUpdate{ cell, row in
                    cell.textLabel?.textColor = Colors.first
                }.onCellSelection { _, _ in
                    self.signUp()
        }
    }
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
        roleAttribute?.value = "user"
        attributes.append(roleAttribute!)

        
        return attributes
    }
    
    private func getRetailerAttributes() -> [AWSCognitoIdentityUserAttributeType] {
        var attributes = [AWSCognitoIdentityUserAttributeType]()
        
        attributes.append(userAttribute(name: "gender", value: self.gender))
        attributes.append(userAttribute(name: "birthdate", value: self.birthdate))
        attributes.append(userAttribute(name: "custom:role", value: "retailer"))
        attributes.append(userAttribute(name: "custom:shopName", value: self.shopName))
        attributes.append(userAttribute(name: "custom:phone", value: self.phone))
        attributes.append(userAttribute(name: "custom:city", value: self.city))
        attributes.append(userAttribute(name: "custom:street", value: self.street))
        attributes.append(userAttribute(name: "custom:postalCode", value: self.postalCode))
        
        return attributes
    }

    private func userAttribute(name: String, value: String) -> AWSCognitoIdentityUserAttributeType {
        let attribute = AWSCognitoIdentityUserAttributeType()
        attribute?.name = name
        attribute?.value = value
        return attribute!
    }
    
    private func signUp() {
        if isValid() {
            var userAttributes = [AWSCognitoIdentityUserAttributeType]()
            if isRetailer {
                userAttributes = getRetailerAttributes()
            } else {
                userAttributes = getUserAttributes()
            }
            userPool?.signUp(email, password: password, userAttributes: userAttributes, validationData: nil).continueWith { [weak self] task -> Void in
                guard let strongSelf = self else { return }
                DispatchQueue.main.async(execute: {
                    if let error = task.error as NSError? {
                        let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                                message: error.userInfo["message"] as? String,
                                                                preferredStyle: .alert)
                        let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
                        alertController.addAction(retryAction)

                        self?.present(alertController, animated: true, completion:  nil)
                        if error.userInfo["__type"] as! String == "UsernameExistsException" {
                            let message = Message(title: "Email already registered!", backgroundColor: .red)
                            Whisper.show(whisper: message, to: (self?.navigationController!)!, action: .show)
                        }
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
    }
    
    func tableView(_: UITableView, willDisplayHeaderView view: UIView, forSection: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel?.textColor = Colors.first
        }
    }
    
    
    // MARK: - Helper
    private func isValid() -> Bool {
        let errors = form.validate()
        if errors.isEmpty {
            return true
        }
        let message = Message(title: errors[0].msg, backgroundColor: .red)
        Whisper.show(whisper: message, to: navigationController!, action: .show)
        
        return false
    }
    
     // MARK: - Navigation
     
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let emailConfirmationViewController = segue.destination as! EmailConfirmationViewController
        emailConfirmationViewController.emailToConfirm = emailToConfirm
        emailConfirmationViewController.user = self.userPool?.getUser(self.email)
     }
}
