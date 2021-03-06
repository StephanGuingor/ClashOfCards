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
    //UI
       var im = UIImage(named: "cross")
       
    
    
    
    
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
    
    ///Will set the label and image
    func setLabelAndImage(imageIn: UIImage?,name:String?,health:String?){
        let labelName = subviews.filter { (v) -> Bool in
            let v1 = v as? UILabel
            if v1 != nil && v1?.tag == 2{
                return true
            }
            return false
        }
        let image = subviews.filter { (v) -> Bool in
                  let v1 = v as? UIImageView
                  if v1 != nil{
                      return true
                  }
                  return false
              }
       let healthLabel = subviews.filter { (v) -> Bool in
            let v1 = v as? UILabel
            if v1 != nil && v1?.tag == 3{
                return true
            }
            return false
        }
        let rImage = image.first as! UIImageView
        rImage.image = imageIn ?? im
       
       
        let rLabel = labelName.first as! UILabel
        rLabel.text = name ?? "Empty"
        
        let rhealthLabel = healthLabel.first as! UILabel
        rhealthLabel.text = health ?? ""
     
    }
    func deadImage(){
        let image = subviews.filter { (v) -> Bool in
            let v1 = v as? UIImageView
            if v1 != nil{
                return true
            }
            return false
        }
        let rImage = image.first as! UIImageView
               rImage.image = im
    }
   
    func updateHealth(value:Int,parent:GameViewController){
        let healthLabel = subviews.filter { (v) -> Bool in
            let v1 = v as? UILabel
            if v1 != nil && v1?.tag == 3{
                return true
            }
            return false
        }
        let rhealthLabel = healthLabel.first as! UILabel
        rhealthLabel.text = String(Int(rhealthLabel.text ?? "50")! - value)
        
        //Will remove from the game any player that get below or to 0 hitpoints
        if Int(rhealthLabel.text!)! <= 0{
            parent.turnsStructure.popItem(data: targetPlayer!.playerIdx)
            rhealthLabel.isHidden = true
            deadImage()
            
        }
    }
    
}
