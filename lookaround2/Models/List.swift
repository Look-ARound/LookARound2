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
var firebaseCreatedByUserNameKey = "createdByUserName"
var firebasePlaceIDArrayKey = "placeIDs"

class List {
    var id: String = ""
    var name: String = ""
    var createdByUserID: String
    var createdByUserName: String = ""
    var placeIDs = [String]()
    
    init() {
        id = ""
        name = ""
        createdByUserID = ""
        createdByUserName = ""
        placeIDs = []
    }
    
    init?(name: String, placeID: String) {
        guard let userID = AccessToken.current?.userId else {
            return nil
        }
        
        var currentUserName : String?
        ProfileRequest().fetchCurrentUserName(success: { (userName: String!) in
            currentUserName = userName
        }) { (error: Error) in
            currentUserName = nil
        }
        
        guard let userName = currentUserName else {
            return nil
        }
        
        self.id = UUID().uuidString
        self.name = name
        self.createdByUserID = userID
        self.createdByUserName = userName
        self.placeIDs = [placeID]
    }
    
    init(listID : String, dictionary: [String : AnyObject?]) {
        self.id = listID
        self.name = dictionary[firebaseListNameKey] as! String
        self.createdByUserID = dictionary[firebaseCreatedByUserIDKey] as! String
        
        if let userName = dictionary[firebaseCreatedByUserNameKey] as? String {
            self.createdByUserName = userName
        }
        
        if let placeIDStrings = dictionary[firebasePlaceIDArrayKey] as? [String] {
            self.placeIDs = placeIDStrings
        }
    }
    
    func firebaseRepresentation() -> NSDictionary {
        let dict = NSMutableDictionary()
        dict[firebaseListNameKey] = self.name
        dict[firebaseCreatedByUserIDKey] = self.createdByUserID
        dict[firebasePlaceIDArrayKey] = self.placeIDs
        dict[firebaseCreatedByUserNameKey] = self.createdByUserName
        
        return dict as NSDictionary
    }
    
    private init(_ copyingTo: List) {
        self.id = copyingTo.id
        self.name = copyingTo.name
        self.createdByUserID = copyingTo.createdByUserID
        self.createdByUserName = copyingTo.createdByUserName
        self.placeIDs = copyingTo.placeIDs
    }
    
    var copy: List {
        return List(self)
    }
    
}
