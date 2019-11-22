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
    
    
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCAdvertiserAssistant!
    var messageToSend: String!
    
    
    @IBOutlet weak var readyUpButton: UIButton!
    
    var fontAttributes = [kCTStrokeWidthAttributeName as NSAttributedString.Key : NSNumber(integerLiteral: 6), kCTFontAttributeName as NSAttributedString.Key : UIFont(name: "Impact", size: 25.0)! ]
    
    
    //MARK: Variable check joining state
    var join:Bool?
    
    
    
    //MARK: Game Settings
    //in order to map index value and peers
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ReadyUpButtonSetUp
        
        settingTheButton()
        
        
        //Is joining to session?
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
        
//        showConnections()
        
        if join ?? false{
            joinSession(sender: nil)
        }else{
            hostSession(sender: nil)
        }
        
        
    }
    
    //MARK: Game SetUp
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
    func hostSession(sender: UIAlertAction?){
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "chat", discoveryInfo: nil, session: mcSession)
        mcAdvertiserAssistant.start()
    }
    
    func joinSession(sender: UIAlertAction?){
        let browser = MCBrowserViewController(serviceType: "chat", session: mcSession)
        browser.delegate = self
        present(browser, animated: true) {
            print("browser presented")
        }
    }
    
   
    
    @IBAction func sendMCPeerIDToPlayersInSession(_ sender: UIButton){
        messageToSend = "\(peerID.displayName)"
        
        guard let msg = messageToSend.data(using: .utf8,
                                           allowLossyConversion: true) else {return}
        do{
            try self.mcSession.send(msg, toPeers: self.mcSession.connectedPeers, with: .unreliable)
            
        }catch{
            print(error.localizedDescription)
        }
    }
    
    
    @objc func recievedDataNotification(_ notification: Notification){
        let data = notification.userInfo!["data"]
        readyUpButton.setTitle(data as? String, for: .normal)
        print("Data recieved")
        
    }
    @objc func peerChangedStateNotification(){
        print(mcSession.connectedPeers)
    }
    func everyOneReadyUp(){
        
    }
    
    
    
    
    
    
    
    
    //MARK:DEBUG
    @IBAction func checkConnectedPeers(_ sender: Any) {
        
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
extension GameViewController:MCSessionDelegate{
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
        switch state {
        case .connected:
            break
        case .connecting:
            break
        case .notConnected:
            break
        @unknown default:
            print("error")
        }
    }
    
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            let recievedString = String(bytes: data, encoding: .utf8)
            
            self.readyUpButton.setAttributedTitle(NSAttributedString(string: recievedString!, attributes: self.fontAttributes), for: .normal)
            
            print("recieved!")
            
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    
}
