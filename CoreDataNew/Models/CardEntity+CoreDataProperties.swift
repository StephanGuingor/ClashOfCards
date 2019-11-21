
//
//  CardEntity+CoreDataProperties.swift
//  CoreDataNew
//
//  Created by Stephan Guingor on 11/12/19.
//  Copyright © 2019 Stephan Guingor. All rights reserved.
//
//

import Foundation
import CoreData


extension CardEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CardEntity> {
        return NSFetchRequest<CardEntity>(entityName: "CardEntity")
    }

    @NSManaged public var name: String?
    @NSManaged public var rarity: String?
    @NSManaged public var type: String?
    @NSManaged public var elixirCost: Int32
    @NSManaged public var idName: String?
    @NSManaged public var imageUrl: Data?

}
