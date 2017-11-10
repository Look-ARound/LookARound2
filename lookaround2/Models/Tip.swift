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
var firebaseAuthorNameKey = "authorName"


class Tip {
    var placeID: String
    var tipAuthor: String
    var authorName: String
    var tipText: String
    var tipID: String?
    
    init(placeID: String, tipAuthor: String, authorName: String, text: String, id: String? = nil) {
        self.placeID = placeID
        self.tipAuthor = tipAuthor
        self.authorName = authorName
        self.tipText = text
        self.tipID = nil
    }
    
    init(by tipID: String, for placeID: String, json: JSON) {
        self.tipID = tipID
        self.placeID = placeID
        self.tipAuthor = json[firebaseTipAuthorKey].stringValue
        self.tipText = json[firebaseTipTextKey].stringValue
        self.authorName = json[firebaseAuthorNameKey].stringValue
        print(tipAuthor)
        print(tipText)
    }
    
    class func CreateTip(for placeID: String, text: String, completion: @escaping (_ tip: Tip?, _ error: Error?)->Void) {
        ProfileRequest().fetchCurrentUser(success: { (user) in
            let tip = Tip(placeID: placeID, tipAuthor: user.id, authorName: user.name, text: text)
            completion(tip, nil)
        }) { (error) in
            completion(nil, error)
        }
    }
    
    func firebaseRepresenation() -> NSDictionary {
        let dict = NSMutableDictionary()
        dict[firebaseTipAuthorKey] = self.tipAuthor
        dict[firebaseTipTextKey] = self.tipText
        dict[firebaseAuthorNameKey] = self.authorName
        return dict as NSDictionary
    }
    
}
