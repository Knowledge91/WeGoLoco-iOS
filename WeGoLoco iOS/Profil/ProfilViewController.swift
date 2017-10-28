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
        
        // Sign Out
        +++ Section()
            <<< ButtonRow() {
                $0.title = "Sign Out"
            }.onCellSelection { _, _ in
                self.signOut()
            }
        
    }

    // MARK: Helper
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
    
//    @IBAction func signOut(_ sender: AnyObject) {
//        User.signOut()
//    }


