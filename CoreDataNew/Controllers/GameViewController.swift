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
    
    //Variables para debug sin Handler
//    var peerID: MCPeerID!
//    var mcSession: MCSession!
//    var mcAdvertiserAssistant: MCAdvertiserAssistant!
    
    
    var messageToSend: String!
    
    
    @IBOutlet weak var readyUpButton: UIButton!
    
    var fontAttributes = [kCTStrokeWidthAttributeName as NSAttributedString.Key : NSNumber(integerLiteral: 6), kCTFontAttributeName as NSAttributedString.Key : UIFont(name: "Impact", size: 25.0)! ]
    
    
    //MARK: Variable check joining state
    var join:Bool?
    
    var appDelegate:AppDelegate?
    
    //MARK: Game Settings
    //in order to map index value and peers
    
    var playersConnected:[Int:MCPeerID]?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(56, forKey: "score")
        let getVar  = UserDefaults.standard.double(forKey: "score")
        print(getVar)
        //ReadyUpButtonSetUp
        
        settingTheButton()
        
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.mpcHandler.initialSetUp()
        
        //Is joining to session?
//        peerID = MCPeerID(displayName: UIDevice.current.name)
//        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
//        mcSession.delegate = self
        
//        showConnections()
        
        
        //Check si el usuario hizo click en el button de join o de host
        if join ?? false{
            joinSession2()
        }else{
            hostSession2()
        }
        
        
        //Observers
        ///This observer is in charge of handling data notifications, and running the desired function
        NotificationCenter.default.addObserver(self, selector: #selector(recievedDataNotification(_:)), name: NSNotification.Name(rawValue: "MPC_DidRecieveDataNotification"), object: nil)
        
        ///This observer is in charge of handling change in state notifications, adn running desired function
        NotificationCenter.default.addObserver(self, selector: #selector(peerChangedStateNotification), name: NSNotification.Name(rawValue: "MPC_DidChangeStateNotification"), object: nil)
    }
    
    //MARK: Game SetUp
    ///Esta funcion es solo para debugging, muestra una alerta para unirse o hacer host


    @IBAction func sendMCPeerIDToPlayersInSession(_ sender: UIButton){
        messageToSend = "\(appDelegate?.mpcHandler.peerID.displayName ?? "none")"
        
        guard let msg = messageToSend.data(using: .utf8,
                                           allowLossyConversion: true) else {return}
        do{
            try appDelegate!.mpcHandler.mcSession.send(msg, toPeers: appDelegate!.mpcHandler.mcSession.connectedPeers, with: .unreliable)
            
        }catch{
            print(error.localizedDescription)
        }
    }
    
    
    
    func everyOneReadyUp(){
        
    }
    
    
    
    //MARK:DEBUG
    ///Function for debug only, to coroborate players in session
    @IBAction func checkConnectedPeers(_ sender: Any) {
        print(appDelegate!.mpcHandler.mcSession.connectedPeers)
    }
    
    ///Displays an alert controller, for user to choose between joining or hosting, this should only be used for debug purposes
        func showConnections(){
            let alert = UIAlertController(title: "Available Connections", message: "Choose the best one", preferredStyle: .alert)
            
            let hostAction  = UIAlertAction(title: "host session", style: .default, handler: hostSession)
            
            let joinAction = UIAlertAction(title: "join session", style: .default, handler: joinSession)
            
            let cancel = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
            
            alert.addAction(hostAction)
            alert.addAction(joinAction)
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
        }
    
        ///Funcion de hosting para alert view, solo para debug
        func hostSession(sender: UIAlertAction?){
    //        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "chat", discoveryInfo: nil, session: mcSession)
    //        mcAdvertiserAssistant.start()
        }
    
        ///Funcion de join para alert view, solo para debug
        func joinSession(sender: UIAlertAction?){
    //        let browser = MCBrowserViewController(serviceType: "chat", session: mcSession)
    //        browser.delegate = self
    //        present(browser, animated: true) {
    //            print("browser presented")
    //        }
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
    
     ///Brings up MCBrowser Controller in order to join to an existing session
     func joinSession2(){
         appDelegate?.mpcHandler.joinSession(delegate: self, from: self)
     }
    
     /// Via de MCAdvertiserAssistant, it advertises current session  to other devices
     func hostSession2(){
         appDelegate?.mpcHandler.hostSession()
     }
     
    @objc func recievedDataNotification(_ notification: Notification){
        let data = notification.userInfo!["data"] as? Data
        let recievedString = String(bytes: data!, encoding: .utf8)

        readyUpButton.setAttributedTitle(NSAttributedString(string: recievedString!, attributes: fontAttributes), for: .normal)
        print("Data recieved")
        
    }
    
    
    ///Function runned by the obverver in charge of state changes in session, it will only fire if player state is connected
    @objc func peerChangedStateNotification(){
        print(appDelegate!.mpcHandler.mcSession.connectedPeers)
    }

    
}


extension GameViewController : MCBrowserViewControllerDelegate{
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        
        
        dismiss(animated: true) {
            print("finished")
        }
        
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        
        dismiss(animated: true) {
            print("canceled from the handler")
        }
    }
    
    
    
}
