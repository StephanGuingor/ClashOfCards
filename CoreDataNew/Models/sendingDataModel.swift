//
//  sendingDataModel.swift
//  CoreDataNew
//
//  Created by Stephan Guingor on 11/22/19.
//  Copyright © 2019 Stephan Guingor. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol ResponseType {
    var name:String {get set}
    var index:Int {get set}
    var ready: Bool {get set}
    var cardIDs:[String] {get set}
    var targetPeer:Int{get set}
    var sendingIndexes:Bool {get set}
    var indexesAndNames:[Int:String] {get set}
    var sendingCards:Bool {get set}
}

struct dtJson: Codable,ResponseType{
    
   var name:String
   var index:Int
   var ready: Bool
   var cardIDs:[String]
   var targetPeer:Int
   var sendingIndexes:Bool
   var indexesAndNames:[Int:String]
   var sendingCards: Bool
}

//for encode purposes
class dataToJSON: Codable,ResponseType {

    var name:String
    var index:Int
    var ready: Bool
    var cardIDs:[String]
    var targetPeer:Int
    var sendingIndexes:Bool
    var indexesAndNames:[Int:String]
    var sendingCards: Bool
   
    init(name: String, index: Int, ready: Bool, cardIDs: [String]?, targetPeer: Int?, sendingIndexes: Bool?, idxAndNames:[Int:String]?, sendingCards: Bool?){
        
        self.name = name
        self.index = index
        self.ready = ready
        self.cardIDs = cardIDs ?? [""]
        self.targetPeer = targetPeer ?? -1
        self.sendingIndexes = sendingIndexes ?? false
        self.indexesAndNames = idxAndNames ?? [-1:""]
        self.sendingCards = sendingCards ?? false
        
    }
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.index = try container.decodeIfPresent(Int.self, forKey: .index) ?? -1
        self.ready = try container.decodeIfPresent(Bool.self, forKey: .ready) ?? true
        self.cardIDs = try container.decodeIfPresent([String].self, forKey: .cardIDs) ?? [""]
        
        self.targetPeer = try container.decodeIfPresent(Int.self, forKey: .targetPeer) ?? -1
        
    
        self.sendingIndexes = try container.decodeIfPresent(Bool.self, forKey: .sendingIndexes) ?? false
        self.indexesAndNames = try container.decodeIfPresent([Int:String].self, forKey: .sendingIndexes) ?? [-1:""]
        self.sendingCards = try container.decodeIfPresent(Bool.self, forKey: .sendingCards) ?? false
    }
}



