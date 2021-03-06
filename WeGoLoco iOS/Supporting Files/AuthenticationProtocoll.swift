//
//  ResetProtocoll.swift
//  WeGoLoco iOS
//
//  Created by Dirk Hornung on 26/10/17.
//  Copyright © 2017 Dirk Hornung. All rights reserved.
//

import Foundation

protocol Authentication {
    var needsRefresh: Bool { get set }
    
    func refresh()
    func clean()
}

