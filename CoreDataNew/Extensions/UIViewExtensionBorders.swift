//
//  UIViewExtensionBorders.swift
//  CoreDataNew
//
//  Created by Stephan Guingor on 11/27/19.
//  Copyright © 2019 Stephan Guingor. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
    class newView:UIView{
    
    ///-1 is the defualt value for the target peer, it should never be called with this value
    var targetPlayer : Player?
    
    
    

    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }

    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    ///Function that will set the target player, in order to send information to that device.
    func setTargetPeer(target: Player){
        targetPlayer = target
    }
}
