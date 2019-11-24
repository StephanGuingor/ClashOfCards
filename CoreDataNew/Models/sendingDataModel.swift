//
//  sendingDataModel.swift
//  CoreDataNew
//
//  Created by Stephan Guingor on 11/22/19.
//  Copyright © 2019 Stephan Guingor. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class dataToJSON: Codable {
    
    var name:String
    var index:Int
    var ready: Bool
    var cardID:String
    var targetPeer:Int
   
    init(name: String, index: Int, ready: Bool, cardID: String?, targetPeer: Int?){
        
        self.name = name
        self.index = index
        self.ready = ready
        self.cardID = cardID ?? ""
        self.targetPeer = targetPeer ?? -1
        
    }
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.index = try container.decodeIfPresent(Int.self, forKey: .index) ?? -1
        self.ready = try container.decodeIfPresent(Bool.self, forKey: .ready) ?? true
        self.cardID = try container.decodeIfPresent(String.self, forKey: .cardID) ?? ""
        
        self.targetPeer = try container.decodeIfPresent(Int.self, forKey: .targetPeer) ?? -1
        
    
        
    }
}
