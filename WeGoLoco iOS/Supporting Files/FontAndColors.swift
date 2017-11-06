//
//  FontAndColors.swift
//  WeGoLoco
//
//  Created by Dirk Hornung on 19/8/17.
//
//

import Foundation
final class Fonts {
    static let bodyName = "Jameson SS Round"
    
    static public func body() -> UIFont {
        return UIFont(name: bodyName, size: 40)!
    }
}

final class Colors {
    static let subuGradientColors = [#colorLiteral(red: 0.04705882353, green: 0.9215686275, blue: 0.9215686275, alpha: 1), #colorLiteral(red: 0.1254901961, green: 0.8901960784, blue: 0.6980392157, alpha: 1), #colorLiteral(red: 0.1607843137, green: 1, blue: 0.7764705882, alpha: 1)]
}
