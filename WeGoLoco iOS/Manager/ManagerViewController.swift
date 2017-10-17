//
//  ManagerViewController.swift
//  WeGoLoco iOS
//
//  Created by Dirk Hornung on 13/10/17.
//  Copyright © 2017 Dirk Hornung. All rights reserved.
//

import UIKit
import AWSAPIGateway
import PromiseKit


class ManagerViewController: UIViewController {

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let image = UIImage(named: "test")
        
        firstly {
            API.tinponUploadMainImage(tinponId: "1", image: image!)
        }.then {
            print("uploaded")
        }.catch { error in
            print(error)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
