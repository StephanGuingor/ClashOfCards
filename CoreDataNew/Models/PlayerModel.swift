//
//  PlayerModel.swift
//  CoreDataNew
//
//  Created by Stephan Guingor on 11/26/19.
//  Copyright © 2019 Stephan Guingor. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class Player{
    let playerStack : PlayerStack = PlayerStack()
    let peerID : MCPeerID
    let playerIdx:Int
    init(peerID:MCPeerID,index:Int) {
        self.peerID = peerID
        self.playerIdx = index
    }
   
}
