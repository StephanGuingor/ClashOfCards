//
//  NotificationHandler.swift
//  CoreDataNew
//
//  Created by Stephan Guingor on 11/20/19.
//  Copyright © 2019 Stephan Guingor. All rights reserved.
//

import Foundation
import UIKit
import MultipeerConnectivity


class MPCHandler: NSObject{
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCAdvertiserAssistant?
    
    
    
    
    
    func initialSetUp(){
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
    }
    
   
    func hostSession(){
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "game", discoveryInfo: nil, session: mcSession)
        mcAdvertiserAssistant!.start()
    }
    
    func joinSession(delegate: MCBrowserViewControllerDelegate, from: UIViewController){
        let browser = MCBrowserViewController(serviceType: "game", session: mcSession)
               browser.delegate = delegate
            from.present(browser, animated: true) {
                   print("browser presented")
               }
    }
    func advertiseSelf(advertise: Bool){
        if advertise{
            mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "game", discoveryInfo: nil, session: mcSession)
            mcAdvertiserAssistant!.start()
        }else{
            mcAdvertiserAssistant!.stop()
            mcAdvertiserAssistant = nil
        }
        
    }
}

extension MPCHandler:MCSessionDelegate{
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            DispatchQueue.main.async {
                 let userInfo = ["peerID":peerID,"state":state.rawValue] as [String : Any]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MPC_DidChangeStateNotification"), object: nil, userInfo: userInfo)
            }
        default:
            break
        }
        
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            let userInfo = ["peerID":peerID,"data":data] as [String : Any]
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
