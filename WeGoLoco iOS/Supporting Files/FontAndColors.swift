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
    static let gothamRoundedMedium = UIFont(name: "GothamRounded-Medium", size: 20)
    static public func body() -> UIFont {
        return UIFont(name: bodyName, size: 40)!
    }
}

final class Colors {
    static let first = #colorLiteral(red: 0.04705882353, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
    static let second = #colorLiteral(red: 0.1254901961, green: 0.8901960784, blue: 0.6980392157, alpha: 1)
    static let third = #colorLiteral(red: 0.1607843137, green: 1, blue: 0.7764705882, alpha: 1)
    static let background = #colorLiteral(red: 0.9676991577, green: 0.9676991577, blue: 0.9676991577, alpha: 1)
    static let subuGradientColors = [#colorLiteral(red: 0.04705882353, green: 0.9215686275, blue: 0.9215686275, alpha: 1), #colorLiteral(red: 0.1254901961, green: 0.8901960784, blue: 0.6980392157, alpha: 1), #colorLiteral(red: 0.1607843137, green: 1, blue: 0.7764705882, alpha: 1)]
}


// http://stackoverflow.com/a/40484460/933770
struct AppFontName {
    static let regular = "GothamRounded-Book"
    static let bold = "GothamRounded-Medium"
    static let italic = "GothamRounded-LightItalic"
}

extension UIFont {
    
    @objc class func mySystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.regular, size: size)!
    }
    
    @objc class func myBoldSystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.bold, size: size)!
    }
    
    @objc class func myItalicSystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.italic, size: size)!
    }
    
    @objc convenience init(myCoder aDecoder: NSCoder) {
        if let fontDescriptor = aDecoder.decodeObject(forKey: "UIFontDescriptor") as? UIFontDescriptor {
            if let fontAttribute = fontDescriptor.fontAttributes[UIFontDescriptor.AttributeName(rawValue: "NSCTFontUIUsageAttribute")] as? String {
                var fontName = ""
                switch fontAttribute {
                case "CTFontRegularUsage":
                    fontName = AppFontName.regular
                case "CTFontEmphasizedUsage", "CTFontBoldUsage":
                    fontName = AppFontName.bold
                case "CTFontObliqueUsage":
                    fontName = AppFontName.italic
                default:
                    fontName = AppFontName.regular
                }
                self.init(name: fontName, size: fontDescriptor.pointSize)!
            }
            else {
                self.init(myCoder: aDecoder)
            }
        }
        else {
            self.init(myCoder: aDecoder)
        }
    }
    
    class func overrideInitialize() {
        if self == UIFont.self {
            let systemFontMethod = class_getClassMethod(self, #selector(systemFont(ofSize:)))
            let mySystemFontMethod = class_getClassMethod(self, #selector(mySystemFont(ofSize:)))
            method_exchangeImplementations(systemFontMethod!, mySystemFontMethod!)
            
            let boldSystemFontMethod = class_getClassMethod(self, #selector(boldSystemFont(ofSize:)))
            let myBoldSystemFontMethod = class_getClassMethod(self, #selector(myBoldSystemFont(ofSize:)))
            method_exchangeImplementations(boldSystemFontMethod!, myBoldSystemFontMethod!)
            
            let italicSystemFontMethod = class_getClassMethod(self, #selector(italicSystemFont(ofSize:)))
            let myItalicSystemFontMethod = class_getClassMethod(self, #selector(myItalicSystemFont(ofSize:)))
            method_exchangeImplementations(italicSystemFontMethod!, myItalicSystemFontMethod!)
            
            let initCoderMethod = class_getInstanceMethod(self, #selector(UIFontDescriptor.init(coder:))) // Trick to get over the lack of UIFont.init(coder:))
            let myInitCoderMethod = class_getInstanceMethod(self, #selector(UIFont.init(myCoder:)))
            method_exchangeImplementations(initCoderMethod!, myInitCoderMethod!)
        }
    }
}
