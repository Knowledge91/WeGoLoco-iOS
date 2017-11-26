//
//  UIImageExtension.swift
//  WeGoLoco iOS
//
//  Created by Dirk Hornung on 25/11/17.
//  Copyright © 2017 Dirk Hornung. All rights reserved.
//

import Foundation

extension UIImage{
    func resizeImageForS3() -> UIImage {
        return resizeImageWith(newSize: CGSize(width: 640, height: 640))
    }
    
    func resizeImageWith(newSize: CGSize) -> UIImage {
        
        let horizontalRatio = newSize.width / size.width
        let verticalRatio = newSize.height / size.height
        
        let ratio = max(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    
}
