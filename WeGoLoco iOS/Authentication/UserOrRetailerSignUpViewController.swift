//
//  UserOrRetailerSignUpViewController.swift
//  WeGoLoco iOS
//
//  Created by Dirk Hornung on 25/11/17.
//  Copyright © 2017 Dirk Hornung. All rights reserved.
//

import UIKit

class UserOrRetailerSignUpViewController: UIViewController {

    var isRetailer: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func userButtonTouched(_ sender: UIButton) {
        isRetailer = false
        performSegue(withIdentifier: "segueToSignUpViewController", sender: self)
    }
    
    @IBAction func retailerButtonTouched(_ sender: UIButton) {
        isRetailer = true
        performSegue(withIdentifier: "segueToSignUpViewController", sender: self)
    }

    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let signUpVC = segue.destination as? SignUpViewController {
            signUpVC.isRetailer = self.isRetailer
        }
    }

}
