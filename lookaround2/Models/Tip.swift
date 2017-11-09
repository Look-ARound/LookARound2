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

var firebaseTipAuthorKey = "tipAuthorID"
var firebaseTipTextKey = "tipText"


class Tip: NSObject {
    var placeID: String
    var tipAuthor: String
    var tipText: String
    var tipID: String?
    
    override init() {
        placeID = ""
        tipAuthor = ""
        tipText = ""
    }
    
    init?(for place: String, text: String) {
        guard let userID = AccessToken.current?.userId else {
            _ = SweetAlert().showAlert("Error", subTitle: "You must log in to add tips", style: .error)
            return nil
        }
        
        self.placeID = place
        self.tipAuthor = userID
        self.tipText = text
    }
    
    init(by tipID: String, for placeID: String, json: JSON) {
        self.tipID = tipID
        self.placeID = placeID
        self.tipAuthor = json[firebaseTipAuthorKey].stringValue
        self.tipText = json[firebaseTipTextKey].stringValue
        print(tipAuthor)
        print(tipText)
    }
    
    func firebaseRepresenation() -> NSDictionary {
        let dict = NSMutableDictionary()
        dict[firebaseTipAuthorKey] = self.tipAuthor
        dict[firebaseTipTextKey] = self.tipText
        
        return dict as NSDictionary
    }
    
}
