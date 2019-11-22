//
//  popUpViewController.swift
//  CoreDataNew
//
//  Created by Stephan Guingor on 11/20/19.
//  Copyright © 2019 Stephan Guingor. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class popUpViewController: UIViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var hostButton: UIButton!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var lastView: UIView!
    
    
    //Multipeer conectivity varibales
    
//    var peerID: MCPeerID!
//    var mcSession: MCSession!
//    var mcAdvertiserAssistant:MCAdvertiserAssistant? = nil
//
//    var displayName:  String?
//    var advertiser:Bool?
//
    
    //MPCHandler

   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
        
        
//        multiPeerConectivitySetUpVariables()
        gestureSetUp()
        shadowSetup()
        
        //USING MPC Handler
        
       
    }
    
    //MARK: MPC Handler
    
    
    //MARK: Multi Peer Conectivity Set Up
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "joinSID"{
                
                let vc = segue.destination as! UINavigationController
                let game = vc.viewControllers.first as? GameViewController
                game?.join = true
            }
        if segue.identifier == "hostSID"{

//            let vc = segue.destination as! UINavigationController
//            let game = vc.viewControllers.first as? GameViewController
//            game?.hostRoom()
        }
        }
    
    @IBAction func joinButton(_ sender: UIButton) {
        //recieve function from destination
        self.performSegue(withIdentifier: "joinSID", sender: self)
       
    }
    
    
    @IBAction func hostButton(_ sender: Any) {
        //recieve function from destination
        self.performSegue(withIdentifier: "hostSID", sender: self)
    }
    
    
    //MARK: Animations
    
    @objc func Close_popupView(_ sender: UITapGestureRecognizer) {
        removeAnimate()
    }
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    func removeAnimate()
    {
        
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }, completion: {(finished : Bool) in
            if(finished)
            {
                self.willMove(toParent: nil)
                self.view.removeFromSuperview()
                self.removeFromParent()
            }
        })
    }
    
    
    //MARK: Shadow SetUp
    
    func shadowSetup(){
        backView.layer.applySketchShadow(color: UIColor.black, alpha: 0.5, x: 0, y: 4, blur: 4, spread: 0)
        
        backView.layer.borderWidth = 1
        
        backView.layer.borderColor = UIColor(displayP3Red: 151/255, green: 151/255, blue: 151/255, alpha: 1).cgColor
        
        
        
        joinButton.layer.applySketchShadow(color: UIColor.black, alpha: 0.5, x: 0, y: 4, blur: 4, spread: 0)
        
        joinButton.layer.borderWidth = 1
        
        joinButton.layer.borderColor = UIColor(displayP3Red: 151/255, green: 151/255, blue: 151/255, alpha: 1).cgColor
        
        
        hostButton.layer.applySketchShadow(color: UIColor.black, alpha: 0.5, x: 0, y: 4, blur: 4, spread: 0)
        
        hostButton.layer.borderWidth = 1
        
        hostButton.layer.borderColor = UIColor(displayP3Red: 151/255, green: 151/255, blue: 151/255, alpha: 1).cgColor
        
        showAnimate()
    }
    
    //MARK: Gesture SetUp
    
    func gestureSetUp(){
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(Close_popupView(_:)))
        self.view.addGestureRecognizer(tap)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
