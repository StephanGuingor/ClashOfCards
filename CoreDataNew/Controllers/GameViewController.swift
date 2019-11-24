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
    
    ///Manages the state of the game, if its set to true it means that the game is currently or about to be executed
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
    ///Keep track of all connected players
    var playersConnected :Set<MCPeerID> = []
    ///Will change to true when everyone is ready
    var playersReady:Bool = false
    ///Contains information to manage the turns
    var playerIndexAndPeerID:[Int:MCPeerID] = [:]
    ///Dictionary of the players connected and their ready state
    var playersAndReadyStatus:[MCPeerID:Bool] = [:]
    ///This struct is in charge of sending all the data across devices
    var dataToSendAsJSON: dataToJSON?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(56, forKey: "score")
        let getVar  = UserDefaults.standard.double(forKey: "score")
        print(getVar)
        
        //ReadyUpButtonSetUp
        
        settingTheButton()
        
        //Initial set up
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.mpcHandler.initialSetUp()
        
      
        //Check si el usuario hizo click en el button de join o de host
            joinOrHost()
        
        
        //Observers
        ///This observer is in charge of handling data notifications, and running the desired function
        NotificationCenter.default.addObserver(self, selector: #selector(recievedDataNotification(_:)), name: NSNotification.Name(rawValue: "MPC_DidRecieveDataNotification"), object: nil)
        
        ///This observer is in charge of handling change in state notifications, adn running desired function
        NotificationCenter.default.addObserver(self, selector: #selector(peerChangedStateNotification), name: NSNotification.Name(rawValue: "MPC_DidChangeStateNotification"), object: nil)
    }
    
    
    //MARK: JSON FUNCTIONS
    ///Function designed to convert objects into data , so it can be sent
    func encodeToJSON(_ object: dataToJSON) -> Data{
        let encoder = JSONEncoder()
        let messageToSend = object
        
        do {
            let dataToSend = try encoder.encode(messageToSend)
            
            return dataToSend
            //For Debug Use
            //            if let jsonString = String(data: dataToSend, encoding: .utf8) {
            //                print(jsonString)
            //            }
        } catch {
            print(error.localizedDescription)
        }
        return Data()
    }
    
    ///Function designed to recieve information from other peers, by decoding data into objects
    func decodeToJSON(_ data: Data) -> dataToJSON{
        
        do{
            
            let peerMessageRecieved = try JSONDecoder().decode(dataToJSON.self, from: data)
            print(peerMessageRecieved.name)
            return peerMessageRecieved
        }catch{
            print("JSON Decode Failed \(error.localizedDescription)")
        }
        //default
        return dataToJSON(name: "", index: -1, ready: false, cardID: nil, targetPeer: nil)
    }
    
    
    //MARK: Game SetUp
    
    //MARK:GS: Getting Ready
    @IBAction func toggleReady(_ sender: Any) {
        
        playerIsReady.toggle()
        
        switch playerIsReady{
        case true:
            readyUpButton.backgroundColor = UIColor.green
            
            readyUpButton.setAttributedTitle(NSAttributedString(string: "Ready", attributes: fontAttributes), for: .normal)
            //updates the status in local dictionary
            playersAndReadyStatus[appDelegate!.mpcHandler.mcSession.myPeerID] = true
            //sending information about ready status
            sendStateIsReadyOrUnReady(true)
            
        case false:
            readyUpButton.backgroundColor = UIColor.red
            
            readyUpButton.setAttributedTitle(NSAttributedString(string: "Un-Ready", attributes: fontAttributes), for: .normal)
            
            playersAndReadyStatus[appDelegate!.mpcHandler.mcSession.myPeerID] = true
            sendStateIsReadyOrUnReady(true)
        }
    }
    
    ///Sends an object from dataToJSON that everyone will recieve, the important piece is if the player is ready
    func sendStateIsReadyOrUnReady(_ ready: Bool){
        
        let message = dataToJSON(name: appDelegate?.mpcHandler.mcSession.myPeerID.displayName ?? "No-Name", index: -1, ready: ready, cardID: nil, targetPeer: nil)
        
        let msgData = encodeToJSON(message)
        
        
        do{
            ///Encoded object will be sent to every player
            try appDelegate!.mpcHandler.mcSession.send(msgData, toPeers: appDelegate!.mpcHandler.mcSession.connectedPeers, with: .unreliable)
            
        }catch{
            print(error.localizedDescription)
        }
    }
    
    ///Function will check for everyone state, reeady and unready, if it matches the players connected count, game starts.
    func checkIfEveryoneIsReady() -> Bool{
        var readyCount = 0
        
        for element in playersAndReadyStatus{
            if element.value{
                readyCount += 1
            }
        }
        
        //if every connected player is ready it will return true
        if playersConnected.count >= 2{
            return playersConnected.count == readyCount
        }
        return false
    }
    
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
    
    
    
    //MARK: MPC Handler
    
    //Check si el usuario hizo click en el button de join o de host
    func joinOrHost(){
        
        if join ?? false{
            joinSession2()
        }else{
            hostSession2()
            ///Adding hosting device to the connected players set
            playersConnected.insert(appDelegate!.mpcHandler.mcSession.myPeerID)
            print("Welcome \(appDelegate!.mpcHandler.mcSession.myPeerID) to your session!")
        }
    }
    ///Brings up MCBrowser Controller in order to join to an existing session
    func joinSession2(){
        appDelegate?.mpcHandler.joinSession(delegate: self, from: self)
    }
    
    /// Via de MCAdvertiserAssistant, it advertises current session  to other devices
    func hostSession2(){
        appDelegate?.mpcHandler.hostSession()
    }
    
    ///Function runned by observer in charge of data notifications
    @objc func recievedDataNotification(_ notification: Notification){
        let data = notification.userInfo!["data"] as? Data
        let peer = notification.userInfo!["peerID"] as? MCPeerID
        
        //this variable is for debug purposes, this will name of device.
        let recievedString = String(bytes: data!, encoding: .utf8)
        
        let decodedData = decodeToJSON(data!)
        
        
        ///This is to manage all the ready states in the game in order to begin, once the game is runnning; this function will not keep running
        if !playersReady{
            //sets the peer and state in a dictionary
            playersAndReadyStatus[peer!] = decodedData.ready
            
            
            //if everyone is ready, game will start
            if checkIfEveryoneIsReady(){
                playersReady = true
            }
        }
        
        readyUpButton.setAttributedTitle(NSAttributedString(string: recievedString!, attributes: fontAttributes), for: .normal)
        print("Data recieved")
        
    }
    
    
    ///Function runned by the obverver in charge of state changes in session, it will only fire if player state is connected
    @objc func peerChangedStateNotification(_ notifaction: Notification){
        print(appDelegate!.mpcHandler.mcSession.connectedPeers)
        
        let state = notifaction.userInfo!["state"] as! Int
        let peerID = notifaction.userInfo!["peerID"] as! MCPeerID
        switch  MCSessionState.init(rawValue: state){
        case .connected:
            ///It will only add the player if device is not already registered
            if checkIfAvailableSpace(peerID){
                playersConnected.insert(peerID)
                print("The player \(peerID.displayName) join the session!")
            }
        case .connecting:
            print("player is connecting")
        default:
            break
        }
    }
    ///This function return will tell if we should keep adding players to the connected players set or if we have reached a maximum capacity.
    func checkIfAvailableSpace(_ peer: MCPeerID) -> Bool{
        if playersConnected.count < 4{
            return true
        }else{
            //Checking if the extra peer connected, so he can be kicked
            if appDelegate?.mpcHandler.mcSession.myPeerID == peer{
                appDelegate?.mpcHandler.mcSession.disconnect()
                print("Sorry, there was not enough space for \(peer.displayName). Max space is 4 players.")
            }
            //Stops advertising th host, we do a nil check in order to see who is the host. Non-Host will be nil
            if appDelegate!.mpcHandler.mcAdvertiserAssistant != nil{
                appDelegate?.mpcHandler.mcAdvertiserAssistant!.stop()
                print("\(appDelegate!.mpcHandler.mcSession.myPeerID.displayName) has stopped advertising your game")
            }
            return false
        }
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
