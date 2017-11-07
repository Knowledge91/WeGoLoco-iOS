//
//  CustomAlertController.swift
//  WeGoLoco iOS
//
//  Created by Dirk Hornung on 7/11/17.
//  Copyright © 2017 Dirk Hornung. All rights reserved.
//

import Foundation

class CustomAlertController: UIAlertController {
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.view.tintColor = Colors.first
    }
}
