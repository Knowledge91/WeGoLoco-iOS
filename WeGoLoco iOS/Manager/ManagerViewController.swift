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

        firstly {
            API.getNotSwipedTinpons()
        }.then { tinpons -> Void in
//            print(tinpons?.first?.id)
//            print(tinpons?.last?.id)
        }.catch { error in
            print(error)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
