//
//  Extensions.swift
//  WeGoLoco iOS
//
//  Created by Dirk Hornung on 5/11/17.
//  Copyright © 2017 Dirk Hornung. All rights reserved.
//

import Foundation

protocol NavigationBarGradientProtocol {
    func setNavigationBarGradient()
}

extension NavigationBarGradientProtocol where Self: UIViewController {
    func setNavigationBarGradient() {
        // NavBar Gradient
        navigationController?.navigationBar.setGradientBackground(colors: Colors.subuGradientColors)
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
    }
}

extension CAGradientLayer {
    
    convenience init(frame: CGRect, colors: [UIColor]) {
        self.init()
        self.frame = frame
        self.colors = []
        for color in colors {
            self.colors?.append(color.cgColor)
        }
        startPoint = CGPoint(x: 0, y: 0)
        endPoint = CGPoint(x: 1, y: 0)
//        locations = [0.0, 0.5, 1.0]
    }
    
    func creatGradientImage() -> UIImage? {
        
        var image: UIImage? = nil
        UIGraphicsBeginImageContext(bounds.size)
        if let context = UIGraphicsGetCurrentContext() {
            render(in: context)
            image = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
        return image
    }
    
}

extension UINavigationBar {
    func setGradientBackground(colors: [UIColor]) {
        var updatedFrame = bounds
        updatedFrame.size.height += 20
        let gradientLayer = CAGradientLayer(frame: updatedFrame, colors: colors)
        
        setBackgroundImage(gradientLayer.creatGradientImage(), for: UIBarMetrics.default)
    }
}

// https://stackoverflow.com/questions/37903124/set-background-gradient-on-button-in-swift
extension UIView {
    func applyGradient(colours: [UIColor]) -> Void {
        self.applyGradient(colours: colours, locations: nil)
    }
    
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> Void {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.startPoint = CGPoint(x: 0, y:0)
        gradient.endPoint = CGPoint(x:1, y:0)
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
    }
}

