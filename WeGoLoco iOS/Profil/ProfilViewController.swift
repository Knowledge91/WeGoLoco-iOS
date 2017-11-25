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
import PromiseKit

class ProfilViewController: FormViewController, LoadingAnimationProtocol, NavigationBarGradientProtocol {
    // MARK: LoadingAnimationProtocol
    var loadingAnimationView: UIView!
    var loadingAnimationOverlay: UIView!
    var loadingAnimationIndicator: UIActivityIndicatorView!
    
    // MARK: AuthenticationProtocol
    var needsRefresh = true
    
    var user: User!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if needsRefresh {
            refresh()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //LoadingAnimationProtocol
        loadingAnimationView = view
        
        // NavBar gradient
        setNavigationBarGradient()
        
        // view background color
        self.tableView.backgroundColor = Colors.background
        
        // change Password
        form  +++ Section("Password")
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
            }.cellUpdate{ cell, row in
                cell.textLabel?.textColor = Colors.first
            }.onCellSelection { _, _ in
                let currentPassword = (self.form.rowBy(tag: "currentPassword") as! PasswordRow).value!
                let newPassword = (self.form.rowBy(tag: "newPassword") as! PasswordRow).value!
                self.changePassword(currentPassword: currentPassword, proposedPassword: newPassword)
            }
        
        // Sign Out
        +++ Section()
            <<< ButtonRow() {
                $0.title = "Sign Out"
            }.cellUpdate{ cell, row in
                cell.textLabel?.textColor = Colors.first
            }.onCellSelection { _, _ in
                self.signOut()
            }
        
    }

    // MARK: Helper
    fileprivate func loadUser() {
        startLoadingAnimation()
        firstly {
            UserAPI.getUser()
        }.then { user -> Void in
            self.user = user
            
            if !self.user.isRetailer {
                let retailerSwitchRow = self.form.rowBy(tag: "retailerSwitch") as! SwitchRow
                retailerSwitchRow.value = self.user.isRetailer
                retailerSwitchRow.reload()
            }
            self.stopLoadingAnimation()
        }.catch { error in
            print(error)
        }
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
        UserAPI.signOutAndClean(tabBarController: self.tabBarController!)
    }
    
}

extension ProfilViewController: Authentication {
    func refresh() {
        needsRefresh = false
        loadUser()
    }
    func clean() {
        needsRefresh = true
    }
}

// Section color
extension ProfilViewController {
    func tableView(_: UITableView, willDisplayHeaderView view: UIView, forSection: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel?.textColor = Colors.first
        }
    }
}


