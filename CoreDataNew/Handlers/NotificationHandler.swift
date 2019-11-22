//
//  NotificationHandler.swift
//  CoreDataNew
//
//  Created by Stephan Guingor on 11/20/19.
//  Copyright © 2019 Stephan Guingor. All rights reserved.
//

import Foundation

import MultipeerConnectivity

class MPCHandler: NSObject{
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCAdvertiserAssistant? = nil
    var browser: MCBrowserViewController!
    var delegate:MCSessionDelegate?
    
    func setUpPeerDisplayName(displayName:String){
        peerID = MCPeerID(displayName: displayName)
    }
    
    func setUpSession(){
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = delegate
        
    }
    func setUpBrowser(){
        browser = MCBrowserViewController(serviceType: "Game", session: mcSession)
    }
    
    func advertiseSelf(advertise: Bool){
        if advertise{
            mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "Game", discoveryInfo: nil, session: mcSession)
            mcAdvertiserAssistant!.start()
        }else{
            mcAdvertiserAssistant!.stop()
            mcAdvertiserAssistant = nil
        }
        
    }
}

extension MPCHandler:MCSessionDelegate{
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        let userInfo = ["peerID":peerID,"state":state.rawValue] as [String : Any]
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MPC_DidChangeStateNotification"), object: nil, userInfo: userInfo)
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let userInfo = ["peerID":peerID,"data":data] as [String : Any]
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MPC_DidRecieveDataNotification"), object: nil, userInfo: userInfo)
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    
}
