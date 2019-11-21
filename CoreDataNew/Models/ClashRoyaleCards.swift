//
//  ClashRoyaleCards.swift
//  CoreDataNew
//
//  Created by Stephan Guingor on 11/11/19.
//  Copyright © 2019 Stephan Guingor. All rights reserved.
//

import Foundation
import UIKit


class Cards: Codable{
    var rarity : String?
    var idName : String?
    var name: String?
    var type: String?
    var elixirCost : Int?
    var imageUrl : String
    
    init (){
        rarity = "Default"
        idName = "Default"
        name = "Default"
        type = "Default"
        elixirCost = 10
        imageUrl = "Default"
    }
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? "Undefined"
        self.type = try container.decodeIfPresent(String.self, forKey: .type) ?? "Undefined"
        self.elixirCost = try container.decodeIfPresent(Int.self, forKey: .elixirCost) ?? 0
        self.idName = try container.decodeIfPresent(String.self, forKey: .idName) ?? "Undefined"
        
        self.imageUrl =  "http://www.clashapi.xyz/images/cards/\(self.idName!).png"
        
        self.rarity = try container.decodeIfPresent(String.self, forKey: .rarity) ?? "Undefined"
        
    }
}
