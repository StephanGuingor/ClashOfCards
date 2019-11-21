//
//  GameViewController.swift
//  CoreDataNew
//
//  Created by Stephan Guingor on 11/20/19.
//  Copyright © 2019 Stephan Guingor. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class GameViewController: UIViewController {
    
    
    var appDelegate : AppDelegate!
    
    var join:Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if join ?? false{
            joinWithPlayers()
        }
        
        // Do any additional setup after loading the view.
    }
   
    @IBAction func checkConnectedPeers(_ sender: Any) {
        print(appDelegate.mpcHandler.mcSession.connectedPeers)
    }
    //MARK: MPC Handler
    
    func setUpMPC(){
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        appDelegate.mpcHandler.delegate = self as? MCSessionDelegate
        appDelegate.mpcHandler.setUpPeerDisplayName(displayName: UIDevice.current.name)
        
//        appDelegate.mpcHandler.advertiseSelf(advertise: true)
    }
  //MARK: Navigation
    @IBAction func unwindToGame(_ sender: UIStoryboardSegue){
        
    }
   
    
     
     func hostRoom(){
        readyToPlaySetUp()
        appDelegate.mpcHandler.advertiseSelf(advertise: true)
    }
    
    func joinWithPlayers(){
        readyToPlaySetUp()
        
        guard  let browser = appDelegate.mpcHandler.browser else {
            return
        }
        
        present(browser, animated: true) {
            print("finished")
        }
    }
    
    func readyToPlaySetUp(){
        setUpMPC()
                appDelegate.mpcHandler.setUpSession()
                
        //        if appDelegate.mpcHandler.mcSession != nil{
                   
                appDelegate.mpcHandler.setUpBrowser()
                appDelegate.mpcHandler.browser.delegate = self
    }
}


extension GameViewController : MCBrowserViewControllerDelegate{
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        
        
        appDelegate.mpcHandler.browser.dismiss(animated: true) {
            print("finished")
        }
        
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        
        appDelegate.mpcHandler.browser.dismiss(animated: true) {
            print("canceled from the handler")
        }
    }
    
    
    
}
