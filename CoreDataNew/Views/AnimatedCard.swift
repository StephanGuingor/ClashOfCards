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
    
    ///this variable will control the availability of the on tap and pan animation, if card becomes active then it will change the gameViewController value
    var selectedCard:Bool = false
    var animatedCard:AnimatedCard?
    ///will be used in order to send data to other players when dropped
    var idName:String!
    ///Will be used to display elixir damage when displayed
    var elixirCost:Int!
    var checkForOtherCardsFunction:(Bool,Bool) -> Void = {_,_ in return}
    var elxImg:UIImageView = UIImageView(image: UIImage(named:"elixirDrop"))
    var elixirCardIdx:Int!
    var parent: GameViewController!
   
    
    
    
    //    let elixirImage = UIImageView(image: UIImage(named:"elixirDrop"))
    ///designated initializer
    override init(image: UIImage?) {
        super.init(image: image)
    }
    ///this initializer will recieve the variable from the gameview controller in order to notify and update the value whenever is changes.
    convenience init(image: UIImage?,selectedCard:inout AnimatedCard, function: @escaping (Bool,Bool)-> Void,idName: String,elixirCost:Int, elxCardIdx:inout Int, parent: GameViewController) {
        self.init(image: image)
        self.animatedCard = selectedCard
        self.checkForOtherCardsFunction = function
        self.idName = idName
        self.elixirCost = elixirCost
        self.elixirCardIdx = elxCardIdx
        self.parent = parent
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func humanInteractionEnabled(_ bool: Bool){
        self.isUserInteractionEnabled = bool
    }
    
    func startingPosition(viewC : UIViewController){
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.animationOnTap)))
        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(animationOnPan)))
        
        //        self.image = image DEBUG
        viewC.view.addSubview(self)
        self.bounds = CGRect(x: viewC.view.bounds.width * 0.025, y: viewC.view.bounds.width * 0.10, width: viewC.view.bounds.width * 0.060, height: viewC.view.bounds.width * 0.025)
        
        self.layer.isHidden = false
        self.layer.position = viewC.view.center
        self.layer.transform = CATransform3DRotate(self.layer.transform, CGFloat.pi, 0, 0, -0.5)
        self.layer.zPosition = 1
        
        
        addElixirCost(view: viewC as! GameViewController)
        
    }
    
    //MARK:Animation on Pan
    /// function to send an atack via drag and drop
    @objc func animationOnPan(_ gesture: UIPanGestureRecognizer){
        
        
        //        guard let sView = UIViewController as? GameViewController else {
        //            return
        //        }
        
            
            
            switch gesture.state {
            case .began:
                print("Began")
            case .changed:
//                print("Chaged")
                let translation = gesture.translation(in: self)
               
                let viewToSend = superview?.subviews.filter({ (v) -> Bool in
                    return v is newView && v.frame.intersects(self.frame)
                })
               
                if viewToSend?.first != nil{
                    if viewToSend!.first!.frame.contains(gesture.location(in: parent.view)) {
                        print("ahuevoputo")
                    }
                }
                
//                gesture.location(in: viewToSend!.first!)
                //                    .first!.bounds.contains(translation){
//                    print("fuck yes, send it")
//                }
                
//                self.frame.origin = translation
                self.transform = CGAffineTransform(translationX:translation.x, y: translation.y)
            case .ended:
                
                UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                    print("animation")
                   
                    self.transform = .identity
                   
                }) { (finished) in
                    if finished{
                        print("it really did finished")
                    }
                }
            default:
                break
            }
        
    }
    
    ///if card becomes active then it will change the gameViewController value. DEBUG
    func ifAnimationUpdateSelectedPlayer(card:inout AnimatedCard){
        card = self
    }
    
    //MARK:Animation on Tap
    ///this function will select the card
    @objc func animationOnTap(_ gesture: UITapGestureRecognizer){
        
        //        if gesture.state == .began{
        if !selectedCard{
            checkForOtherCardsFunction(true,false)
            selectedCard = true
            elxImg.isHidden = false
            
            
            print("animation began")
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.5)
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear))
            
            
            let zAnimation = CABasicAnimation(keyPath: "zPosition")
            zAnimation.duration = animationDuration
            zAnimation.fromValue = self.layer.zPosition
            zAnimation.toValue = CGFloat(1)
            
            self.layer.zPosition = CGFloat(1)
            //SCALE
            //        let scaleAnimation =  CABasicAnimation(keyPath: "bounds")
            //        scaleAnimation.duration = animationDuration
            //        scaleAnimation.fromValue = NSValue(cgRect: CGRect(x: self.bounds.maxX, y: self.bounds.maxY, width: self.layer.bounds.height, height: self.layer.bounds.width))
            
            //        scaleAnimation.toValue = NSValue(cgRect: CGRect(x: self.center.x, y: self.center.y, width: self.layer.bounds.height, height: self.layer.bounds.width))
            
            //        SETTING SCALE
            //        self.layer.bounds = CGRect(x: self.center.x, y: self.center.y, width: self.layer.bounds.height, height: self.layer.bounds.width)
            
            let borderColorAnimation = CABasicAnimation(keyPath: "borderColor")
            borderColorAnimation.duration = 0.3
            borderColorAnimation.fromValue = UIColor.clear.cgColor
            borderColorAnimation.toValue = UIColor.purple.cgColor
            
            //Set color
            self.layer.borderColor = UIColor.purple.cgColor
            
            //BORDER WIDTH
            let borderAnimation =  CABasicAnimation(keyPath: "borderWidth")
            borderAnimation.duration = 0.3
            borderAnimation.fromValue = self.layer.borderWidth
            borderAnimation.toValue = 2
            
            //Setting Border
            self.layer.borderWidth = 2
            
            let positionAnimation = CABasicAnimation(keyPath: "position")
            positionAnimation.duration = 0.3
            positionAnimation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x , y: self.center.y )) // we have to wrap c types in NSVAlUE in order to animate
            positionAnimation.toValue = NSValue(cgPoint: CGPoint(x:
                
                
                self.center.x + CGFloat(0), y: self.center.y + CGFloat(-15)))
            
            
            self.layer.position.y = self.center.y + CGFloat(-15)
            
            self.layer.add(zAnimation, forKey: "zAnimation")
            self.layer.add(positionAnimation, forKey: "position")
            self.layer.add(borderColorAnimation, forKey: "borderColor")
            self.layer.add(borderAnimation, forKey: "borderWidth")
            //        self.layer.add(scaleAnimation,forKey: "bounds")
            
            CATransaction.commit()
            
            //        }
        }else{
            selectedCard = false
            reverseOnTapAnimation()
        }
    }
    
    func addElixirCost(view:GameViewController){
        //        let elixirImage = UIImageView(image: UIImage(named:"elixirDrop"))
        //        let margins = self.layoutMarginsGuide
        elxImg.isHidden = true
        self.addSubview(elxImg)
        
        elxImg.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: elxImg, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view.view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: view.view.layer.frame.size.width * 0.18 + CGFloat(elixirCardIdx! * 50)).isActive = true
        NSLayoutConstraint(item: elxImg, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view.view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: view.view.layer.frame.size.height * 0.88).isActive = true
        NSLayoutConstraint(item: elxImg, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: view.view.layer.frame.size.width * 0.2).isActive = true
        NSLayoutConstraint(item: elxImg, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant:  view.view.layer.frame.size.width * 0.2).isActive = true
        //        elxImg.bounds = CGRect(x: elxImg.center.x, y: elxImg.center.y, width: 60, height: 60)
        //
        //
        //        elxImg.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        //
        //        elxImg.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        
        
        
        let valueForElixir = UILabel()
        
        valueForElixir.text = String(elixirCost)
        print(elixirCost!)
        valueForElixir.textColor = .white
        valueForElixir.font = UIFont(name: "Impact", size: 15.0)!
        valueForElixir.textAlignment = .center
        valueForElixir.translatesAutoresizingMaskIntoConstraints = false
        elxImg.addSubview(valueForElixir)
        
        NSLayoutConstraint(item: valueForElixir, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: elxImg, attribute:
            NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: valueForElixir, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: elxImg, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: valueForElixir, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute:
            NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: elxImg.layer.frame.size.width * 0.5).isActive = true
        
        NSLayoutConstraint(item: valueForElixir, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute:
            NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant:  elxImg.layer.frame.size.width * 0.5).isActive = true
        
        
        
        //        valueForElixir.centerXAnchor.constraint(equalTo: elxImg.centerXAnchor).isActive = true
        //        valueForElixir.layer.position = elxImg.center
    }
    ///will retrun card to original value
    func reverseOnTapAnimation(){
        print("reverse animation began")
        elxImg.isHidden = true
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.5)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear))
        
        
        let zAnimation = CABasicAnimation(keyPath: "zPosition")
        zAnimation.duration = animationDuration
        zAnimation.fromValue = self.layer.zPosition
        zAnimation.toValue = CGFloat(0)
        
        self.layer.zPosition = CGFloat(0)
        //SCALE
        //        let scaleAnimation =  CABasicAnimation(keyPath: "bounds")
        //        scaleAnimation.duration = animationDuration
        //        scaleAnimation.fromValue = NSValue(cgRect: CGRect(x: self.bounds.maxX, y: self.bounds.maxY, width: self.layer.bounds.height, height: self.layer.bounds.width))
        
        //        scaleAnimation.toValue = NSValue(cgRect: CGRect(x: self.center.x, y: self.center.y, width: self.layer.bounds.height, height: self.layer.bounds.width))
        
        //        SETTING SCALE
        //        self.layer.bounds = CGRect(x: self.center.x, y: self.center.y, width: self.layer.bounds.height, height: self.layer.bounds.width)
        
        let borderColorAnimation = CABasicAnimation(keyPath: "borderColor")
        borderColorAnimation.duration = 0.3
        borderColorAnimation.fromValue = UIColor.purple.cgColor
        borderColorAnimation.toValue = UIColor.clear.cgColor
        
        //Set color
        self.layer.borderColor = UIColor.clear.cgColor
        
        //BORDER WIDTH
        let borderAnimation =  CABasicAnimation(keyPath: "borderWidth")
        borderAnimation.duration = 0.3
        borderAnimation.fromValue = 2
        borderAnimation.toValue = 0
        
        //Setting Border
        self.layer.borderWidth = 0
        
        let positionAnimation = CABasicAnimation(keyPath: "position")
        positionAnimation.duration = 0.3
        positionAnimation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x , y: self.center.y )) // we have to wrap c types in NSVAlUE in order to animate
        positionAnimation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + CGFloat(0), y: self.center.y - CGFloat(-15)))
        
        
        self.layer.position.y = self.center.y - CGFloat(-15)
        
        self.layer.add(zAnimation, forKey: "zAnimation")
        self.layer.add(positionAnimation, forKey: "position")
        self.layer.add(borderColorAnimation, forKey: "borderColor")
        self.layer.add(borderAnimation, forKey: "borderWidth")
        //        self.layer.add(scaleAnimation,forKey: "bounds")
        
        CATransaction.commit()
    }
    ///Animation for the serve, i could tune this
    func serve(indexCard: inout Int, viewC: UIViewController){
        
        var tmp = indexCard
        
        if tmp >= 5{
            indexCard = -1
            tmp = 0
            
        } //else if tmp >= 3{
        
        //            tmp *= -1
        //            tmp += 2
        //
        //        }
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
        positionAnimation.fromValue = NSValue(cgPoint: CGPoint(x: viewC.view.layer.bounds.minX + 50, y: self.center.y - 15)) // we have to wrap c types in NSVAlUE in order to animate
        positionAnimation.toValue = NSValue(cgPoint: CGPoint(x: (viewC.view.center.x * 0.5) + CGFloat(tmp * 50), y: (viewC.view.bounds.maxY)))
        
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
        self.layer.position.x = viewC.view.center.x * 0.5 + CGFloat(tmp * 50)
        self.layer.position.y = (viewC.view.bounds.maxY)
        
        
        //ADDING ANIMATIONS
        self.layer.add(positionAnimation, forKey: "position") // adding the animation to the layer
        self.layer.add(transformAnimation, forKey: "transform")
        self.layer.add(scaleAnimation,forKey: "bounds")
        
        //FINAL TOUCHES OF CATRANSACTION
        CATransaction.commit()
        
        
     
    }
}
