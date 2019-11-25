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
    var cardID:String {get set}
    var targetPeer:Int{get set}
    var sendingIndexes:Bool {get set}
    var indexesAndNames:[Int:String] {get set}
}
struct dtJson: Codable,ResponseType{
   var name:String
   var index:Int
   var ready: Bool
   var cardID:String
   var targetPeer:Int
   var sendingIndexes:Bool
   var indexesAndNames:[Int:String]
}

//for encode purposes
class dataToJSON: Codable,ResponseType {
    
    var name:String
    var index:Int
    var ready: Bool
    var cardID:String
    var targetPeer:Int
    var sendingIndexes:Bool
    var indexesAndNames:[Int:String]
   
    init(name: String, index: Int, ready: Bool, cardID: String?, targetPeer: Int?, sendingIndexes: Bool?, idxAndNames:[Int:String]?){
        
        self.name = name
        self.index = index
        self.ready = ready
        self.cardID = cardID ?? ""
        self.targetPeer = targetPeer ?? -1
        self.sendingIndexes = sendingIndexes ?? false
        self.indexesAndNames = idxAndNames ?? [-1:""]
        
    }
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.index = try container.decodeIfPresent(Int.self, forKey: .index) ?? -1
        self.ready = try container.decodeIfPresent(Bool.self, forKey: .ready) ?? true
        self.cardID = try container.decodeIfPresent(String.self, forKey: .cardID) ?? ""
        
        self.targetPeer = try container.decodeIfPresent(Int.self, forKey: .targetPeer) ?? -1
        
    
        self.sendingIndexes = try container.decodeIfPresent(Bool.self, forKey: .sendingIndexes) ?? false
        self.indexesAndNames = try container.decodeIfPresent([Int:String].self, forKey: .sendingIndexes) ?? [-1:""]
    }
}



