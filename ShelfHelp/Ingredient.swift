//
//  Ingredient.swift
//  ShelfHelp
//
//  Created by Harris, David on 2/18/16.
//  Copyright © 2016 Humza Siddiqui. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

class Ingredient: Object, Mappable, Hashable {
    dynamic var uuid = NSUUID().UUIDString
    dynamic var text = ""
    dynamic var quantity = 0.0
    dynamic var unit = ""
    dynamic var name = ""
    dynamic var checked = false
    
    required convenience init?(_ map: Map){
        self.init()
    }
    
    override static func primaryKey() -> String? {
        return "uuid"
    }
    
    func mapping(map: Map){
        text <- map["text"]
        quantity <- map["quantity"]
        unit <- map["measure.label"]
        name <- map["food.label"]
    }

}

func ==(lhs: Ingredient, rhs: Ingredient) -> Bool {
    return lhs.text == rhs.text
}