//
//  GameViewController.swift
//  CoreDataNew
//
//  Created by Stephan Guingor on 11/20/19.
//  Copyright © 2019 Stephan Guingor. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import Macaw



class GameViewController: UIViewController {
    //MARK: READY UP PHASE
    
    //Variables para debug sin Handler
    //    var peerID: MCPeerID!
    //    var mcSession: MCSession!
    //    var mcAdvertiserAssistant: MCAdvertiserAssistant!
    
    @IBOutlet weak var checkDebugWhoIsConnected: UIButton!
    ///Manages the state of the game, if its set to true it means that the game is currently or about to be executed
    var playerIsReady:Bool = false
    
    var messageToSend: String!
    
    
    @IBOutlet weak var gameIsLiveView: MacawView!
    var viewReadyState = Color.rgb(r: 0, g: 255, b: 0)
    
    @IBOutlet weak var gameIsLiveLabel: UILabel!
    
    @IBOutlet weak var readyUpButton: UIButton!
    
    var fontAttributes = [kCTStrokeWidthAttributeName as NSAttributedString.Key : NSNumber(integerLiteral: 6), kCTFontAttributeName as NSAttributedString.Key : UIFont(name: "Impact", size: 25.0)! ]
    
    
    //MARK: Variable check joining state
    var join:Bool?
    
    var appDelegate:AppDelegate?
    
    //MARK: Game Settings
    //in order to map index value and peers
    //Player Bounds
    @IBOutlet weak var player1BoundsView: newView!
    @IBOutlet weak var imagePlayer1: UIImageView!
    @IBOutlet weak var player1Label: UILabel!
    @IBOutlet weak var healthLabelP1: UILabel!
    
    @IBOutlet weak var player2BoundsView: newView!
    @IBOutlet weak var imagePlayer2: UIImageView!
    @IBOutlet weak var player2Label: UILabel!
    @IBOutlet weak var healthLabelP2: UILabel!
    
    @IBOutlet weak var player3BoundsView: newView!
    @IBOutlet weak var imagePlayer3: UIImageView!
    @IBOutlet weak var player3Label: UILabel!
    @IBOutlet weak var healthLabelP3: UILabel!
    
    
    //MARK: GS Getting Ready - Variables
    ///Keep track of all connected players
    var playersConnected:Set<MCPeerID> = []
    ///Will change to true when everyone is ready
    var playersReady:Bool = false
    ///Dictionary of the players connected and their ready state
    var playersAndReadyStatus:[MCPeerID:Bool] = [:]
    ///This struct is in charge of sending all the data across devices
    var dataToSendAsJSON: dataToJSON?
    
    //MARK: GS Game Start
    ///Contains information to manage the turns
    var playerIndexAndPeerID:[Int:MCPeerID] = [:]
    ///this variable will be used to send information about the players and then assign playerIndexAndPeerID
    var playerIndexAndNames:[Int:String] = [:]
    ///The HomeStack variable, here the host will serve cards to other devices
    var homeStack:HomeStack = HomeStack()
    ///The player class, will have its own stack
    var listOfPlayers:[Player] = []
    ///Dictionary of cards, here you can access with the name id the different cards
    var dictionaryOfCards:[String:Cards] = [:]
    ///Has player index
    var playerIndex:Int?
    ///Array of all the animated card views
    var animatedCardArray:[AnimatedCard]?
    ///Value of the selected card
    var selectedAnimatedCard = AnimatedCard(image: nil)
    ///Manages the index for elixir drop
    var elixirDropIdx:Int!
    ///List of the available drop zones, new views
    var dropZonesView:[newView] = []
    
    @IBOutlet weak var healthImageView: UIImageView!
    
    @IBOutlet weak var playerHealth: UILabel!
    
    //MARK:Turns
    ///Structure that will handle turns in game
    let turnsStructure = CircularLinkedList()
    ///Depending on the state, the player will be able to interact with his cards
    var isTurnActive = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(56, forKey: "score")
        let getVar  = UserDefaults.standard.double(forKey: "score")
        print(getVar)
       
        //ReadyUpButtonSetUp
        //         checkDebugWhoIsConnected.isHidden = true DEBUG
        setUpCircleView(Color.red,Color.red)
        
        
        settingTheButton()
        healthImageView.layer.applySketchShadow(color: .black, alpha: 0.5, x: 2, y: 1, blur: 1, spread: 2)
        
        //Initial set up
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.mpcHandler.initialSetUp()
        
        //GameStart SetUp:
        homeStack.generateCards {
            self.mapHomeStackToDictionary() // maps cards to a dictionary
        } // generates from the start all cards needed
        
        
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
    func decodeToJSON(_ data: Data) -> dtJson{
        
        do{
            
            let peerMessageRecieved = try JSONDecoder().decode(dtJson.self, from: data)
            // let strData =  String(bytes: data, encoding: .utf8)
            print(peerMessageRecieved)
            return peerMessageRecieved
        }catch{
            print("JSON Decode Failed \(error.localizedDescription)")
        }
        //default
        return dtJson(name: "", index: -1, ready: false, cardIDs: [], targetPeer: -1,sendingIndexes: false, indexesAndNames: [-1:""],sendingCards: false)
    }
    //MARK:Set Up Circle View
    func setUpCircleView(_ initialColor:Color,_ secondaryColor:Color){
        gameIsLiveView.node = Shape(form: Circle(cx: Double(gameIsLiveView.bounds.height) * 0.5, cy: Double(gameIsLiveView.bounds.height) * 0.5, r: Double(gameIsLiveView.bounds.height) * 0.25),
                                    fill: LinearGradient(degree: 90, from: initialColor, to: secondaryColor),
                                    stroke: Stroke(fill: Color.white, width: 2))
        
    }
    //MARK:Set Up Button
    func settingTheButton(){
        readyUpButton.backgroundColor = UIColor.red
        readyUpButton.layer.cornerRadius = 5
        readyUpButton.layer.applySketchShadow(color: UIColor.black, alpha: 1, x: 1, y: 2, blur: 2, spread: 1)
        
        readyUpButton.setAttributedTitle(NSAttributedString(string: "Un-Ready", attributes: fontAttributes), for: .normal)
        
        
        readyUpButton.tintColor = UIColor.white
        
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
            
            //Will check if ready when sending data
            if checkIfEveryoneIsReady(){
                updateViewToStartGame()
                
                //it will also send the idx and names
                stopAdvertisingIfAdvertising()
                
                //Cards ids will be sent to other players
                sendCardsToPlayerExceptHost()
                
            }
            
        case false:
            readyUpButton.backgroundColor = UIColor.red
            
            readyUpButton.setAttributedTitle(NSAttributedString(string: "Un-Ready", attributes: fontAttributes), for: .normal)
            
            playersAndReadyStatus[appDelegate!.mpcHandler.mcSession.myPeerID] = true
            sendStateIsReadyOrUnReady(true)
        }
    }
    
    ///Sends an object from dataToJSON that everyone will recieve, the important piece is if the player is ready
    func sendStateIsReadyOrUnReady(_ ready: Bool){
        
        let message = dataToJSON(name: appDelegate?.mpcHandler.mcSession.myPeerID.displayName ?? "No-Name", index: -1, ready: ready, cardIDs: nil, targetPeer: nil,sendingIndexes: nil, idxAndNames: nil, sendingCards: false)
        
        let msgData = encodeToJSON(message)
        
        
        do{
            ///Encoded object will be sent to every player
            try appDelegate!.mpcHandler.mcSession.send(msgData, toPeers: appDelegate!.mpcHandler.mcSession.connectedPeers, with: .unreliable)
            
        }catch{
            print("Error in sendState \n \(error.localizedDescription)")
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
        
        //if every connected player is ready it will return true, at least two players
        if playersConnected.count >= 2{
            //            print(readyCount) -debug
            //            print(playersConnected.count) - debug
            return playersConnected.count == readyCount
        }
        return false
    }
    
    ///Function that will change label to playing, and circle to green only when everyone is ready. And remove ready up button
    func updateViewToStartGame(){
        gameIsLiveLabel.text = "Playing..."
        setUpCircleView(Color.yellow, Color.yellow)
        removeButton()
    }
    
    ///When game is live, the ready up button will disappear.
    func removeButton(){
        UIView.animate(withDuration: 0.25, animations: {
            self.readyUpButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.readyUpButton.backgroundColor = UIColor.systemPink
            self.readyUpButton.alpha = 0.0
        }, completion: {(finished : Bool) in
            if(finished)
            {
                if self.readyUpButton != nil{
                    self.readyUpButton.removeFromSuperview()
                }
                
                
                
            }
        })
    }
    //MARK: GS Game Start
    ///Will generate players from playerIndexAndPeerID, this function should only be called when the game is live
    func createPlayers(){
        listOfPlayers = playerIndexAndPeerID.map { (args) -> Player in
            
            let (index, peerID) = args
            
            return Player(peerID: peerID, index: index)
        }
    }
    ///Initial serve to players, everyone will recieve five cards, Only executed by host, and creates players.
    func serveCardsToPlayers(){
        homeStack.shuffle()
        createPlayers()
        
        for player in listOfPlayers{
            for _ in 0 ..< 25{
                
                homeStack.serve(player: player)
                
            }
        }
        
        populateCircularLinkedList() //for turn managment
        firstTurn() //sets host to have first turn
    }
    
    ///This will map all the cards to a dictionary that can be accesed via the id name
    func mapHomeStackToDictionary(){
        for card in homeStack.listStack{
            dictionaryOfCards[card.idName!] = card
        }
        
    }
    
    ///Will return an Int, the index value of the player. AKA the turn.
    func retrieveIndexValue(){
        for i in playerIndexAndPeerID{
            if appDelegate?.mpcHandler.mcSession.myPeerID == i.value{
                playerIndex = i.key
                break
            }
        }
    }
    
    ///when player has two cards left, he will recieve more cards
    func serveIfEmpty(){
        
        if listOfPlayers[playerIndex!].playerStack.listStack.count <= 0 && playerIndex! == 0{
            for _ in 0 ..< 5{
                homeStack.serve(player: listOfPlayers[playerIndex!])
                
            }
            
            
            let cardsToServe = listOfPlayers[playerIndex!].playerStack.listStack
            elixirDropIdx = -1
            animatedCardArray = cardsToServe.map { (Card) -> AnimatedCard in
                do{
                    let dataImage =  try Data(contentsOf: URL(string: Card.imageUrl)!)
                    elixirDropIdx += 1
                    return AnimatedCard(image: UIImage(data: dataImage),selectedCard: &selectedAnimatedCard, function: checkPlayerStackAndSelectedCardToDisable, idName: Card.idName!, elixirCost: Card.elixirCost!,elxCardIdx: &elixirDropIdx, parent: self)
                }catch{
                    print("Cant convert data")
                    return AnimatedCard(image: nil)
                }
                
            }
            
            var idx = 0
            
            for card in animatedCardArray!{
                DispatchQueue.main.async {
                    card.startingPosition(viewC: self)
                    card.layer.zPosition = 0
                    card.serve(indexCard: &idx, viewC: self)
                    idx += 1
                    
                }
            }
        }
    }
    
    func retrieveListOfIndexes() -> [Int]{
        return [1]
    }
    ///sets initial values for display of other devices stats.
    func setTargetPlayers(){
        
        retrieveDropZonesAvailable()
        let otherPlayers = popCurrentDeviceFromListOfPlayers()
        
        for i in 0 ... dropZonesView.count - 1{
            ///This will set a peer to another view, this way the ui can get updated with player information. It adds them in an unordered way.
            dropZonesView[i].setTargetPeer(target: otherPlayers[i])
            dropZonesView[i].setLabelAndImage(imageIn: UIImage(named: "heart"), name: otherPlayers[i].peerID.displayName,health: "50")
        }
    }
    
    ///populates dropZonesView, in order to keep track of available zones
    func retrieveDropZonesAvailable(){
        let dropZonesArray = [player1BoundsView,player2BoundsView,player3BoundsView]
        
        let otherPlayers = popCurrentDeviceFromListOfPlayers()
        let numberOfPlayers = otherPlayers.count - 1
        
        
        for i in 0 ... numberOfPlayers{
            ///This will set the available dropZones
            dropZonesView.append(dropZonesArray[i]!)
        }
    }
    
    ///retrieves view that link to player index
    func comparesIndexWithDropZone(index:Int) -> newView{
        for i in dropZonesView{
            if i.targetPlayer?.playerIdx == index{
                return i
            }
        }
        print("view was not found")
        return newView()
    }
    func popCurrentDeviceFromListOfPlayers() -> [Player]{
        return listOfPlayers.filter { (ply) -> Bool in
            return ply.peerID != appDelegate?.mpcHandler.mcSession.myPeerID
        }
    }
    
    //MARK:Animation in GS Start
    ///Creates all the animated cards for the player and serves them to the player
    func mapToAnimatedCardsAndServe(){
        let cardsToServe = listOfPlayers[playerIndex!].playerStack.listStack
        elixirDropIdx = -1
        animatedCardArray = cardsToServe.map { (Card) -> AnimatedCard in
            do{
                if cardsToServe.firstIndex(of: Card)! <= 4{
                    let dataImage =  try Data(contentsOf: URL(string: Card.imageUrl)!)
                    elixirDropIdx += 1
                    return AnimatedCard(image: UIImage(data: dataImage),selectedCard: &selectedAnimatedCard, function: checkPlayerStackAndSelectedCardToDisable, idName: Card.idName!, elixirCost: Card.elixirCost!,elxCardIdx: &elixirDropIdx, parent: self)
                }
                return AnimatedCard(image: nil)
            }catch{
                print("Cant convert data")
                return AnimatedCard(image: nil)
            }
        }
        
        var idx = 0
        
        for i in 0 ..< 5{
            let card = animatedCardArray![i]
            DispatchQueue.main.async {
                card.startingPosition(viewC: self)
                card.layer.zPosition = 0
                card.serve(indexCard: &idx, viewC: self)
                idx += 1
                
            }
        }
    }
    
    func serveCards(){
        var idx = 0
        
        for i in 0 ..< 5{
            let card = animatedCardArray![i]
            DispatchQueue.main.async {
                card.startingPosition(viewC: self)
                card.layer.zPosition = 0
                card.serve(indexCard: &idx, viewC: self)
                idx += 1
                
            }
        }
    }
    //disables the selected card inside given view
    func checkPlayerStackAndSelectedCardToDisable(reset: Bool, retrieveSelected: Bool ){
        if playerIndex != nil{
            for card in animatedCardArray!{
                if reset{
                    if card.selectedCard{
                        card.reverseOnTapAnimation()
                        card.selectedCard = false
                    }
                    
                    //I might call a back function for the animation
                }
            }
        }else{
            print("player index has not been set")
        }
    }
    
    ///This should only be runned by host, so playerIDx cant be 0
    func retrieveCardIDS(playerIdx: Int) -> [String]{
        return listOfPlayers[playerIdx].playerStack.listStack.reduce(into: []) { (res, card) in
            return res.append(card.idName!)
        }
    }
    
    ///This functions sends cards to the other players, always sent from host
    func sendCardsToServePlayer(player: Player){
        
        let cardsToSend = retrieveCardIDS(playerIdx: player.playerIdx)
        
        
        ///will send player to serve
        let message = dataToJSON(name: appDelegate?.mpcHandler.mcSession.myPeerID.displayName ?? "No-Name", index: player.playerIdx, ready: false, cardIDs: cardsToSend, targetPeer: nil,sendingIndexes: nil, idxAndNames: nil, sendingCards: true)
        
        let msgData = encodeToJSON(message)
        
        
        do{
            ///Encoded object will be sent to every player
            try appDelegate!.mpcHandler.mcSession.send(msgData, toPeers: appDelegate!.mpcHandler.mcSession.connectedPeers, with: .unreliable)
            
        }catch{
            print("Error in sendState \n \(error.localizedDescription)")
        }
        
    }
    
    ///Will send cards to every device connected, in order to recieve cards. Runned by host.
    func sendCardsToPlayerExceptHost(){
        if playerIndex == 0{
            for player in listOfPlayers where player.playerIdx != 0{
                sendCardsToServePlayer(player: player)
            }
        }
    }
    
    //MARK: MPC Handler
    
    //Check si el usuario hizo click en el button de join o de host
    func joinOrHost(){
        ///Adding hosting device to the connected players set
        //we have to add both players to connected players, because they wont recieve notifications about theirselves
        playersConnected.insert(appDelegate!.mpcHandler.mcSession.myPeerID)
        
        if join ?? false{
            joinSession2()
            
        }else{
            hostSession2()
            
            
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
    
    //MARK: RECIEVED DATA NOTIFICATION
    ///Function runned by observer in charge of data notifications
    @objc func recievedDataNotification(_ notification: Notification){
        let data = notification.userInfo!["data"] as? Data
        let peer = notification.userInfo!["peerID"] as? MCPeerID
        
        //this variable is for debug purposes, this will name of device.
        //        let recievedString = String(bytes: data!, encoding: .utf8) -debug
        
        let decodedData = decodeToJSON(data!)
        
        //MARK:GS Getting Ready - Data
        
        //This is to manage all the ready states in the game in order to begin, once the game is runnning; this function will not keep executing
        gameSetUp(peer, decodedData)
        
        //MARK: GS Game Start - Data
        
        
        
        ifSendingIndexes(decodedData)
        
        serveToPlayerExceptHost(decodedData)
        
        if decodedData.targetPeer != -1{
            
            
            print(decodedData.targetPeer)
            ///Will update the health that the device has.
            if playerIndex == decodedData.targetPeer{
                playerHealth.text = String(Int(playerHealth!.text ?? "50")! - dictionaryOfCards[decodedData.cardIDs[0]]!.elixirCost! )
                
                //this will remove player from the game if his health get below 0
                if Int(playerHealth!.text!)! <= 0{
                    turnsStructure.popItem(data: playerIndex!)
                    
                    healthImageView.image = UIImage(named: "cross")
                    
                    playerHealth.isHidden = true
                }
                
                
                
            }else{
                
                ///Will update health labels for other players in current device.
                updateHealthForOtherPlayersInLocalUI(decodedData: decodedData,index: nil,idName: nil)
                
                
            }
            
            turnsStructure.updateTurn()
            checkIfPlayerTurn()
            
            ///Checks player stack in order to hand more if needed
            checkNumberOfCardsAndServe()
            
            checkIfLastAlive()
        }
        
        print("Data recieved")
        
    }
    func updateHealthForOtherPlayersInLocalUI(decodedData:dtJson?,index:Int?,idName:String?){
        if decodedData != nil{
            let view = comparesIndexWithDropZone(index: decodedData!.targetPeer)
            
            ///will update matching labels for the device that got atacked
            view.updateHealth(value: dictionaryOfCards[decodedData!.cardIDs[0]]!.elixirCost!, parent:self)
        }else{
            let view = comparesIndexWithDropZone(index: index!)
            
            ///will update matching labels for the device that got atacked
            view.updateHealth(value: dictionaryOfCards[idName!]!.elixirCost!, parent: self)
        }
        
    }
    ///If host sent cards then players will recieve their cards with their respective animation.
    func serveToPlayerExceptHost(_ decodedData: dtJson){
        if decodedData.sendingCards == true{
            if decodedData.index == playerIndex!{ //maybe
                createPlayers()
                
                for i in decodedData.cardIDs{
                    listOfPlayers[playerIndex!]
                        .playerStack
                        .listStack
                        .append(dictionaryOfCards[i]!)
                }
                setTargetPlayers()
                mapToAnimatedCardsAndServe()
                
                populateCircularLinkedList()
                
            }
        }
        
    }
    
    
    ///This is to manage all the ready states in the game in order to begin, once the game is runnning; this function will not keep executing
    func gameSetUp(_ peer: MCPeerID?, _ decodedData: dtJson) {
        
        //This will be runned before the game has started
        if !playersReady{
            //sets the peer and state in a dictionary
            playersAndReadyStatus[peer!] = decodedData.ready
            
            //if everyone is ready, game will start
            if checkIfEveryoneIsReady(){
                playersReady = true
                
                //Will set circle view to green and label to playing, if recieving data
                updateViewToStartGame()
                stopAdvertisingIfAdvertising()
                
                //Send cards id to all players except host
                sendCardsToPlayerExceptHost()
            }
            
        }
    }
    
    ///Function that will set the indexes for all players if needed
    func ifSendingIndexes(_ decodedData: dtJson) {
        
        if decodedData.sendingIndexes{
            for peerID in playersAndReadyStatus.keys{
                for idxName in decodedData.indexesAndNames{
                    if peerID.displayName == idxName.value{
                        playerIndexAndPeerID[idxName.key] = peerID
                        break
                    }
                }
            }
            ///sets the index of the player
            retrieveIndexValue()
            
            //debug
            for i in playerIndexAndPeerID{
                print("Key: \(i.key),Value:\(i.value)")
            }
        }
        //DEBUG
        //        readyUpButton.setAttributedTitle(NSAttributedString(string: peer!.displayName, attributes: fontAttributes), for: .normal)
        
        //Debug - no handler
        //        readyUpButton.setAttributedTitle(NSAttributedString(string: recievedString!, attributes: fontAttributes), for: .normal) - debug
    }
    
    //MARK: Turns
    
    ///uses player indexes to populate circular linked list
    func populateCircularLinkedList(){
        turnsStructure.addToEmptyList(data: 0)
        for i in 1 ..< listOfPlayers.count{
            turnsStructure.addToListEnd(data: i)
        }
    }
    
    ///it will be called in order to start the turn sequence, turn ends when card is dropped
    func firstTurn(){
        if playerIndex == 0{
            isTurnActive = true
        }
        
        setUpCircleView(Color.green,Color.green)
    }
    
    ///Will keep track of turns for all devices, lets user atack if it is his turn.
    func checkIfPlayerTurn(){
        if turnsStructure.retrieveTurn() == playerIndex{
            isTurnActive = true
            setUpCircleView(Color.green, Color.green)
        }
    }
    //For now it just refills 4 times, need a back up deck
    func checkNumberOfCardsAndServe(){
        if listOfPlayers[playerIndex!].playerStack.listStack.count % 5 == 0 && listOfPlayers[playerIndex!].playerStack.listStack.count != 25{
            
            mapToAnimatedCardsAndServe()
            
        }
    }
    
    //MARK:End Game
    
    ///If the player is the last alive, then a pop up will appear telling you that you won. And will give the option to either quit or play again
    func checkIfLastAlive(){
        if turnsStructure.traverse() == 1 {
            
            
            if listOfPlayers[turnsStructure.retrieveTurn()].peerID == appDelegate?.mpcHandler.mcSession.myPeerID{
//
                appDelegate?.mpcHandler.mcSession.disconnect()
                
                let popvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popUp_end") as! EndGameViewController

                
                //FIXME: SOME TWEAKS
                popvc.modalPresentationStyle = .overCurrentContext
                
                //change presentation
                popvc.modalTransitionStyle = .coverVertical
                
                popvc.popoverPresentationController?.delegate = self
                popvc.popoverPresentationController?.sourceView = self.view // button
                popvc.popoverPresentationController?.sourceRect = self.view.frame
                
                
               
                
                self.present(popvc, animated: true, completion: nil)
                
                
              
            }else{
//                FIXME:PLACE HOLDER and RESTART
                print("You Lose Place Holder")
                appDelegate?.mpcHandler.mcSession.disconnect()
                
                let popvc = UIStoryboard(name: "Main", bundle: nil)
                    .instantiateViewController(withIdentifier: "popUp_end2") as! EndLoseViewController
                
                
                //FIXME: SOME TWEAKS
                popvc.modalPresentationStyle = .overCurrentContext
                
                //change presentation
                popvc.modalTransitionStyle = .coverVertical
                
                popvc.popoverPresentationController?.delegate = self
                popvc.popoverPresentationController?.sourceView = self.view // button
                popvc.popoverPresentationController?.sourceRect = self.view.frame
                
                
                
                self.present(popvc, animated: true, completion: nil)
                
                 
                
            }
        }
    }
    
    ///This function will keep a W/L ratio, stored in the user defaults
    func willSaveResultUserDefaults(){
        
    }
    
    //MARK:GAME DYNAMICS
    
    
    
    //MARK: CHANGED STATE NOTIFICATION
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
            
            return false
        }
    }
    
    ///If device is advertising (if host) it will stop.
    func stopAdvertisingIfAdvertising(){
        if appDelegate!.mpcHandler.mcAdvertiserAssistant != nil{
            //assings only to host, indexes and players, in order to send them to other devices
            assignIndexToPlayers()
            sendIdxAndNames()
            retrieveIndexValue()
            
            //TEST
            serveCardsToPlayers()
            
            setTargetPlayers()
            
            DispatchQueue.main.async {
                self.mapToAnimatedCardsAndServe()
            }
            
            
            appDelegate?.mpcHandler.mcAdvertiserAssistant!.stop()
            print("\(appDelegate!.mpcHandler.mcSession.myPeerID.displayName) has stopped advertising the game")
        }
    }
    
    
    ///Function that will assign indexes to players , and ready message with names
    func assignIndexToPlayers(){
        
        playerIndexAndPeerID[0] = appDelegate?.mpcHandler.mcSession.myPeerID
        playerIndexAndNames[0] = playerIndexAndPeerID[0]?.displayName
        
        var idx = 1
        for i in playersConnected where i != appDelegate?.mpcHandler.mcSession.myPeerID{
            playerIndexAndPeerID[idx] = i
            playerIndexAndNames[idx] = i.displayName
            idx += 1
        }
    }
    
    func sendIdxAndNames(){
        
        let message = dataToJSON(name: appDelegate?.mpcHandler.mcSession.myPeerID.displayName ?? "No-Name", index: -1, ready: true, cardIDs: nil, targetPeer: nil,sendingIndexes: true, idxAndNames: playerIndexAndNames, sendingCards: false)
        
        let msgData = encodeToJSON(message)
        
        
        do{
            ///Encoded object will be sent to every player
            try appDelegate!.mpcHandler.mcSession.send(msgData, toPeers: appDelegate!.mpcHandler.mcSession.connectedPeers, with: .unreliable)
            
        }catch{
            print("Error in sendState \n \(error.localizedDescription)")
        }
    }
    
    //MARK:DEBUG
    
    ///Esta funcion es solo para debugging, muestra una alerta para unirse o hacer host,  usar con el toggle del boton.
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

extension GameViewController:UIPopoverPresentationControllerDelegate{
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        // Force popover style
        return UIModalPresentationStyle.none
    }
}
