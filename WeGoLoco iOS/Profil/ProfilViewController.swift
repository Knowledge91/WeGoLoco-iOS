//
//  MainViewController.swift
//  AWS Mobile SDK
//
//  Created by Dirk Hornung on 9/10/17.
//  Copyright © 2017 Dirk Hornung. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import Eureka
import Whisper

class ProfilViewController: FormViewController {
    var user: AWSCognitoIdentityUser?
    var userPool: AWSCognitoIdentityUserPool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // change Password
        form +++ Section()
            <<< SwitchRow(){
                $0.title = "Change Password"
                $0.tag = "changePasswordSwitch"
            }
            <<< PasswordRow(){
                $0.title = "Current Password"
                $0.tag = "currentPassword"
                $0.hidden = .function(["changePasswordSwitch"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "changePasswordSwitch")
                    return row.value ?? false == false
                })
            }
            <<< PasswordRow(){
                $0.title = "New Password"
                $0.tag = "newPassword"
                $0.hidden = .function(["changePasswordSwitch"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "changePasswordSwitch")
                    return row.value ?? false == false
                })
            }
            <<< ButtonRow(){
                $0.title = "Save New Password"
                $0.hidden = .function(["changePasswordSwitch"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "changePasswordSwitch")
                    return row.value ?? false == false
                })
            }.onCellSelection { _, _ in
                let currentPassword = (self.form.rowBy(tag: "currentPassword") as! PasswordRow).value!
                let newPassword = (self.form.rowBy(tag: "newPassword") as! PasswordRow).value!
                self.changePassword(currentPassword: currentPassword, proposedPassword: newPassword)
            }
        
        // Become a Retailer
            <<< SwitchRow() {
                $0.title = "I am a retailer"
                $0.tag = "retailerSwitch"
            }.onChange { row in
                if row.value! {
                    let message = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec nec vestibulum nisi. Donec tristique iaculis est, at tincidunt nisi. Quisque magna enim, vehicula sed lectus vitae, auctor scelerisque turpis. Ut condimentum auctor enim a pulvinar. Integer id lorem luctus, maximus ipsum sed, consectetur velit. Maecenas eget turpis quis dolor porta molestie. Sed imperdiet suscipit orci. In erat elit, maximus in lectus id, venenatis fringilla velit. Vestibulum interdum molestie iaculis. Fusce id tellus eu erat pharetra venenatis eget in velit. Donec pellentesque felis urna, sit amet consectetur ipsum efficitur non. Lorem ipsum dolor sit amet, consectetur adipiscing elit."
                    let alertController = UIAlertController(title: "title",
                                                            message: message,
                                                            preferredStyle: .alert)
                    let disagreeAction = UIAlertAction(title: "I Disagree", style: .cancel, handler: self.setRetailerSwitchToFalse)
                    let agreeAction = UIAlertAction(title: "I Agree", style: .default, handler: nil)
                    alertController.addAction(disagreeAction)
                    alertController.addAction(agreeAction)
                 
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        
        // Sign Out
            <<< ButtonRow() {
                $0.title = "Sign Out"
            }.onCellSelection { _, _ in
                self.signOut()
            }
        
    }

    // MARK: Helper
    private func setRetailerSwitchToFalse(alert: UIAlertAction!) {
        print("retailer disagree")
        let retailerSwitchRow = form.rowBy(tag: "retailerSwitch") as! SwitchRow
        retailerSwitchRow.value = false
        retailerSwitchRow.cell.switchControl.setOn(false, animated: true)
    }
    
    private func changePassword(currentPassword: String, proposedPassword: String) -> Void {
         let user = UserPool.pool.currentUser()
        user?.changePassword(currentPassword, proposedPassword: proposedPassword).continueWith { task -> () in
            if let error = task.error {
                DispatchQueue.main.async {
                    let message = Message(title: String(describing: error), backgroundColor: .red)
                    Whisper.show(whisper: message, to: self.navigationController!, action: .show)
                }
            } else {
                DispatchQueue.main.async {
                    let message = Message(title: "Password Changed", backgroundColor: .green)
                    Whisper.show(whisper: message, to: self.navigationController!, action: .show)
                }
            }
        }
    }
    
    private func signOut() {
        User.signOutAndClean(tabBarController: self.tabBarController!)
    }
    
}

extension ProfilViewController: Authentication {
    func clean() {
        
    }
}


