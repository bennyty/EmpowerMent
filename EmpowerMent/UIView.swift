//
//  UIView.swift
//  PainPals
//
//  Created by Espey, Benjamin G on 9/9/17.
//  Copyright © 2017 bennyty. All rights reserved.
//

import UIKit

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set(newRadius) {
            self.layer.cornerRadius = newRadius
            self.clipsToBounds = (newRadius != 0)
        }
    }

    func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.06
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = CGPoint(x: self.center.x - 10, y: self.center.y)
        animation.toValue = CGPoint(x: self.center.x + 10, y: self.center.y)
        layer.add(animation, forKey: "position")
    }
}
