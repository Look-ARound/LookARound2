//
//  Tip.swift
//  lookaround2
//
//  Created by Angela Yu on 11/7/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit
import FacebookCore
import SwiftyJSON

var firebasePlaceIDKey = "placeID"
var firebaseTipAuthorKey = "tipAuthorID"
var firebaseTipTextKey = "tipText"


class Tip: NSObject {
    var placeID: String
    var tipAuthor: String
    var tipText: String
    
    override init() {
        placeID = ""
        tipAuthor = ""
        tipText = ""
    }
    
    init?(for place: String, text: String) {
        guard let userID = AccessToken.current?.userId else {
            return nil
        }
        
        self.placeID = place
        self.tipAuthor = userID
        self.tipText = text
    }
    
    init?(placeID: String, json: JSON) {
        self.placeID = json[firebasePlaceIDKey].stringValue
        self.tipAuthor = json[firebaseTipAuthorKey].stringValue
        self.tipText = json[firebaseTipTextKey].stringValue
    }
    
    func firebaseRepresenation() -> NSDictionary {
        let dict = NSMutableDictionary()
        dict[firebasePlaceIDKey] = self.placeID
        dict[firebaseTipAuthorKey] = self.tipAuthor
        dict[firebaseTipTextKey] = self.tipText
        
        return dict as NSDictionary
    }
    
}
