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
    //MARK: READY UP PHASE
    var playerIsReady:Bool = false
    
    @IBOutlet weak var readyUpButton: UIButton!
  
    var fontAttributes = [kCTStrokeWidthAttributeName as NSAttributedString.Key : NSNumber(integerLiteral: 6), kCTFontAttributeName as NSAttributedString.Key : UIFont(name: "Impact", size: 25.0)! ]
    
    //MARK: MPC SINGLETON
    var appDelegate : AppDelegate!
    var session : MCSession!
    
    //MARK: Variable check joining state
    var join:Bool?
    
    
    
    //MARK: Game Settings
    var playersConnected:[Int:MCPeerID]? //in order to map index value and peers
   
    enum PlayersTurn:Int{
        case Player1 = 1
        case Player2
        case Player3
        case Player4
    }
    
    var currentTurn:PlayersTurn?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ReadyUpButtonSetUp
        
        settingTheButton()
        
        
        //Is joining to session?
        if join ?? false{
            joinWithPlayers()
        }
        
        
        //MARK: NOTIFICATION CENTER OBVSERVERS
        
        NotificationCenter.default.addObserver(self, selector: #selector(peerChangedStateNotification), name: NSNotification.Name(rawValue: "MPC_DidChangeStateNotification"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(recievedDataNotification), name: NSNotification.Name(rawValue: "MPC_DidRecieveDataNotification"), object: nil)
        // Do any additional setup after loading the view.
    }
    
    //MARK: Game SetUp
    
    
    @IBAction func sendMCPeerIDToPlayersInSession(_ sender: UIButton){
        let messageToSend = session.myPeerID.displayName
        
        guard let msgData = messageToSend.data(using: .utf8, allowLossyConversion: false)else{return}
        
        do{
            try self.session.send(msgData, toPeers: session.connectedPeers, with: .unreliable)
        }catch{
            print("Peer ID could not be transfered \(error.localizedDescription)")
        }
    }
    
    
    @objc func recievedDataNotification(){
        print("Data recieved")
    }
    @objc func peerChangedStateNotification(){
        
    }
    func everyOneReadyUp(){
        
    }
    
    
    
    
    
    
    
    
    //MARK:DEBUG
    @IBAction func checkConnectedPeers(_ sender: Any) {
        print(appDelegate.mpcHandler.mcSession.connectedPeers)
    }
    
    //MARK:Set Up Button
    func settingTheButton(){
        readyUpButton.backgroundColor = UIColor.red
        readyUpButton.layer.cornerRadius = 5
        readyUpButton.layer.applySketchShadow(color: UIColor.black, alpha: 1, x: 1, y: 2, blur: 2, spread: 1)
       
        readyUpButton.setAttributedTitle(NSAttributedString(string: "Un-Ready", attributes: fontAttributes), for: .normal)
        
        
        readyUpButton.tintColor = UIColor.white
        
    }
    
    @IBAction func toggleReady(_ sender: Any) {
        
        playerIsReady = !playerIsReady
        switch playerIsReady{
        case true:
            readyUpButton.backgroundColor = UIColor.green
            
            readyUpButton.setAttributedTitle(NSAttributedString(string: "Ready", attributes: fontAttributes), for: .normal)
            
            
        case false:
             readyUpButton.backgroundColor = UIColor.red
      
           readyUpButton.setAttributedTitle(NSAttributedString(string: "Un-Ready", attributes: fontAttributes), for: .normal)
        }
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
//         appDelegate.mpcHandler.advertiseSelf(advertise: true)
        guard  let browser = appDelegate.mpcHandler.browser else {
            return
        }
        
        present(browser, animated: true) {
            print("finished view")
        }
    }
    
    func readyToPlaySetUp(){
        setUpMPC()
                appDelegate.mpcHandler.setUpSession()
                
        //        if appDelegate.mpcHandler.mcSession != nil{
                   
                appDelegate.mpcHandler.setUpBrowser()
                appDelegate.mpcHandler.browser.delegate = self
        
        //Defining Session Variable
                session = appDelegate.mpcHandler.mcSession
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

