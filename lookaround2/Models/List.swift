//
//  List.swift
//  LookARound
//
//  Created by Siji Rachel Tom on 10/21/17.
//  Copyright © 2017 LookARound. All rights reserved.
//

import Foundation

var firebaseListIDKey = "listID"
var firebaseListNameKey = "listName"
var firebaseCreatedByUserIDKey = "createdByUserID"
var firebasePlaceIDArrayKey = "placeIDs"


class List: NSObject {
    var id: String!
    var name: String!
    var createdByUserID: String!
    var placeIDs = [String]()
    
    init(name: String, placeID: String) {
        // TODO: fill this in
    }
    
    init(listID : String!, dictionary: [String : AnyObject?]!) {
        self.id = listID
        self.name = dictionary[firebaseListNameKey] as! String
        self.createdByUserID = dictionary[firebaseCreatedByUserIDKey] as! String
        
        if let placeIDStrings = dictionary[firebasePlaceIDArrayKey] as? [String] {
            self.placeIDs = placeIDStrings
        }
    }
    
    func firebaseRepresentation() -> NSDictionary {
        let dict = NSMutableDictionary()
        dict[firebaseListNameKey] = self.name
        dict[firebaseCreatedByUserIDKey] = self.id                
        dict[firebasePlaceIDArrayKey] = self.placeIDs
        
        return dict as NSDictionary
    }
}
