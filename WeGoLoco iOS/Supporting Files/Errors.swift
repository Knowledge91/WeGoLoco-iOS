//
//  Errors.swift
//  WeGoLoco iOS
//
//  Created by Dirk Hornung on 13/10/17.
//  Copyright © 2017 Dirk Hornung. All rights reserved.
//

import Foundation

enum SerializationError: Error {
    case missing(String)
    case invalidType(String)
    case invalid(String, Any)
}
