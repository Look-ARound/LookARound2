//
//  List.swift
//  LookARound
//
//  Created by Siji Rachel Tom on 10/21/17.
//  Copyright © 2017 LookARound. All rights reserved.
//

import Foundation
import FacebookCore

var firebaseListIDKey = "listID"
var firebaseListNameKey = "listName"
var firebaseCreatedByUserIDKey = "createdByUserID"
var firebasePlaceIDArrayKey = "placeIDs"

class List {
    var id: String
    var name: String
    var createdByUserID: String
    var placeIDs = [String]()
    
    init() {
        id = ""
        name = ""
        createdByUserID = ""
        placeIDs = []
    }
    
    init?(name: String, placeID: String) {
        guard let userID = AccessToken.current?.userId else {
            return nil
        }
        
        self.id = UUID().uuidString
        self.name = name
        self.createdByUserID = userID
        self.placeIDs = [placeID]
    }
    
    init(listID : String, dictionary: [String : AnyObject?]) {
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
        dict[firebaseCreatedByUserIDKey] = self.createdByUserID
        dict[firebasePlaceIDArrayKey] = self.placeIDs
        
        return dict as NSDictionary
    }
    
    private init(_ copyingTo: List) {
        self.id = copyingTo.id
        self.name = copyingTo.name
        self.createdByUserID = copyingTo.createdByUserID
        self.placeIDs = copyingTo.placeIDs
    }
    
    var copy: List {
        return List(self)
    }
}
