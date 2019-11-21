//
//  AnimatedCard.swift
//  CoreDataNew
//
//  Created by Stephan Guingor on 11/14/19.
//  Copyright © 2019 Stephan Guingor. All rights reserved.
//

import UIKit

@IBDesignable
class AnimatedCard: UIImageView {
    
    
    func humanInteractionEnabled(){
        self.isUserInteractionEnabled = true
    }
    
    func startingPosition(){
        
        self.layer.isHidden = true
        self.layer.transform = CATransform3DRotate(self.layer.transform, CGFloat.pi, 0, 0.0, -0.5)
        self.layer.zPosition = self.bounds.width
        
        
    }
    func serve(indexCard: inout Int){
        var tmp = indexCard
        if tmp >= 5{
            indexCard = -1
            tmp = 0
            
        }else if tmp >= 3{
            tmp *= -1
            tmp += 2
        }
        self.layer.isHidden = false
        //GROUP ANIMATION SETUP
        CATransaction.begin()
        CATransaction.setAnimationDuration(2.0)
//
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut))
        
        //POSITION ANIMATION
        let positionAnimation = CABasicAnimation(keyPath: "position")
        positionAnimation.duration = 1
        positionAnimation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 20, y: self.center.y - 15)) // we have to wrap c types in NSVAlUE in order to animate
        positionAnimation.toValue = NSValue(cgPoint: CGPoint(x: (superview?.center.x)! - CGFloat(tmp * 50), y: (superview?.bounds.maxY)!))
        
        //SETTING ROTATION FUNCTION
        let transformAnimation = CABasicAnimation(keyPath: "transform")
        transformAnimation.duration = 1
        transformAnimation.fromValue = NSValue(caTransform3D: self.layer.transform)
        transformAnimation.toValue = NSValue(caTransform3D: CATransform3DRotate(self.layer.transform, CGFloat.pi, 0.0, 0.0, 0.5))
        
        //SETTING SCALE FUNCTION
        let scaleAnimation = CABasicAnimation(keyPath: "bounds")
        scaleAnimation.duration = 1
        scaleAnimation.fromValue = NSValue(cgRect: self.layer.bounds )
        scaleAnimation.toValue = NSValue(cgRect: CGRect(x: self.center.x, y: self.center.y, width: self.layer.bounds.height * 50, height: self.layer.bounds.width * 50))
        
        //SETTING SCALE
        self.layer.bounds = CGRect(x: self.center.x, y: self.center.y, width: self.layer.bounds.height * 50, height: self.layer.bounds.width * 50)
        //SETTING TRANSFORM
        self.layer.transform = CATransform3DRotate(self.layer.transform, CGFloat.pi, 0.0, 0, 0.5)
        //SETTING POSITION VALUE
        self.layer.position.x = (superview?.center.x)! - CGFloat(tmp * 50)
        self.layer.position.y = (superview?.bounds.maxY)!
        
        
        //ADDING ANIMATIONS
        self.layer.add(positionAnimation, forKey: "position") // adding the animation to the layer
        self.layer.add(transformAnimation, forKey: "transform")
        self.layer.add(scaleAnimation,forKey: "bounds")
        
       
        //FINAL TOUCHES OF CATRANSACTION
        CATransaction.commit()
        
        
        
    }
}
