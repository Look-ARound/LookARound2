//
//  LAColor.swift
//  LookARound
//
//  Created by Angela Yu on 10/11/17.
//  Copyright © 2017 LookARound. All rights reserved.
//

import UIKit

extension UIColor {
    struct LABrand {
        // USAGE: myButton.tintColor = UIColor.LABrand.primary
        static let primary = UIColor(red:0.00, green:0.59, blue:0.65, alpha:1.0)    // navbar, icon outlines, buttons #0097A7 rgb(0, 151, 167)
        static let unselected = UIColor.darkGray                                    // #555555 rgb(85, 85, 85)
        static let accent = UIColor(red:0.15, green:0.78, blue:0.85, alpha:1.0)     // pins, highlighted info #26C6DA rgb(38, 198, 218)
        static let buttons = UIColor.white // white UI buttons on clear background, #FFF rgb(255, 255, 255)
        static let standard = UIColor.black // black default text
        static let detail = UIColor.lightGray
        
        // From https://developer.apple.com/ios/human-interface-guidelines/visual-design/color/
        // purple #5856d6 rgb(88, 86, 214) UIColor(red:0.35, green:0.34, blue:0.84, alpha:1.0)
        // green #4cd964 rgb(76, 217, 100) UIColor(red:0.30, green:0.85, blue:0.39, alpha:1.0)
        // blue #007aff rgb(0, 122, 255) UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.0)
        // pink #ff2d55 rgb(255, 45, 85) UIColor(red:1.00, green:0.18, blue:0.33, alpha:1.0)
    }
}
