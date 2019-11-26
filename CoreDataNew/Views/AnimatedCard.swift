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
    
    func startingPosition(viewC : UIViewController){
//        self.image = image DEBUG
        viewC.view.addSubview(self)
        self.bounds = CGRect(x: viewC.view.bounds.width * 0.025, y: viewC.view.bounds.width * 0.10, width: viewC.view.bounds.width * 0.060, height: viewC.view.bounds.width * 0.025)
        
        self.layer.isHidden = false
        self.layer.position = viewC.view.center
        self.layer.transform = CATransform3DRotate(self.layer.transform, CGFloat.pi, 0, 0, -0.5)
        self.layer.zPosition = 1
        
        
    }
    func serve(indexCard: inout Int, viewC: UIViewController){
        
        var tmp = indexCard
        
        if tmp >= 5{
            indexCard = -1
            tmp = 0
            
        }else if tmp >= 3{
            tmp *= -1
            tmp += 2
            
        }
        
        let animationDuration = 1 / (Double(tmp) + 0.5)
        
        self.layer.isHidden = false
        //GROUP ANIMATION SETUP
        CATransaction.begin()
        CATransaction.setAnimationDuration(1.5)
//
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut))
        
        //POSITION ANIMATION
        let positionAnimation = CABasicAnimation(keyPath: "position")
        positionAnimation.duration = animationDuration
        positionAnimation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 30, y: self.center.y - 15)) // we have to wrap c types in NSVAlUE in order to animate
        positionAnimation.toValue = NSValue(cgPoint: CGPoint(x: (viewC.view.center.x) - CGFloat(tmp * 50), y: (viewC.view.bounds.maxY)))
        
        //SETTING ROTATION FUNCTION
        let transformAnimation = CABasicAnimation(keyPath: "transform")
        transformAnimation.duration = animationDuration
        transformAnimation.fromValue = NSValue(caTransform3D: self.layer.transform)
        transformAnimation.toValue = NSValue(caTransform3D: CATransform3DRotate(self.layer.transform, CGFloat.pi, 0.0, 0.0, 0.5))
        
        //SETTING SCALE FUNCTION
        let scaleAnimation = CABasicAnimation(keyPath: "bounds")
        scaleAnimation.duration = animationDuration
        scaleAnimation.fromValue = NSValue(cgRect: self.layer.bounds )
        scaleAnimation.toValue = NSValue(cgRect: CGRect(x: self.center.x, y: self.center.y, width: self.layer.bounds.height * 10, height: self.layer.bounds.width * 10))
        
        //SETTING SCALE
        self.layer.bounds = CGRect(x: self.center.x, y: self.center.y, width: self.layer.bounds.height * 10, height: self.layer.bounds.width * 10)
        //SETTING TRANSFORM
        self.layer.transform = CATransform3DRotate(self.layer.transform, CGFloat.pi, 0.0, 0, 0.5)
        //SETTING POSITION VALUE
        self.layer.position.x = (viewC.view.center.x) - CGFloat(tmp * 50)
        self.layer.position.y = (viewC.view.bounds.maxY)
        
        
        //ADDING ANIMATIONS
        self.layer.add(positionAnimation, forKey: "position") // adding the animation to the layer
        self.layer.add(transformAnimation, forKey: "transform")
        self.layer.add(scaleAnimation,forKey: "bounds")
        
        //FINAL TOUCHES OF CATRANSACTION
        CATransaction.commit()
        
        
        
    }
}
