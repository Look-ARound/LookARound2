//
//  DatabaseRequests.swift
//  LookARound
//
//  Created by Siji Rachel Tom on 10/21/17.
//  Copyright © 2017 LookARound. All rights reserved.
//

import Foundation
import Firebase
import FacebookCore
import SwiftyJSON

class DatabaseRequests {
    var ref: DatabaseReference = Database.database().reference()
    var allListsByListID = [String: List]()
    var listsPath = "lists"
    var placesPath = "places"
    
    static let shared = DatabaseRequests()
    
    private init () {} // avoid creating object for this class
    
    // Use this method to create/edit a list
    func createOrUpdateList(list: List, completionHandler: ((_ error: Error?) -> Void)? = nil) -> Void {
        self.ref.child(listsPath).updateChildValues([list.id : list.firebaseRepresentation()]) {
            (error, _) in
            completionHandler?(error)
        }
    }
    
    func deleteList(list: List, completionHandler: ((_ error: Error?) -> Void)? = nil) -> Void {
        self.ref.child(listsPath).child(list.id).removeValue()
        self.ref.child(listsPath).child(list.id).removeValue {
            (error, _) in
            completionHandler?(error)
        }
        self.allListsByListID.removeValue(forKey: list.id)
    }
    
    // TODO: Change to query for currentUserID on server side
    func fetchCurrentUserLists(success: (([List]?)->())?, failure: ((Error?)->())?) -> Void {
        if let currentUserID = AccessToken.current?.userId {
            // Get all lists
            // Filter by those created by userID
            self.fetchAllLists(completion: { (lists: [List]) in
                var currentUserLists = [List]()
                for list in lists {
                    if list.createdByUserID == currentUserID {
                        currentUserLists.append(list)
                    }
                }
                success?(currentUserLists)
            })
        }
        // User not logged in
        else {
            // TODO: better error handling
            print("User not logged in!")
            failure?(nil)
        }
    }
    
    // TODO: Change to filter out currentUserID on server side
    func fetchPublicLists(success: @escaping ([List]?)->(), failure: @escaping (Error?)->()) -> Void {
        if let currentUserID = AccessToken.current?.userId {
            // Get all lists
            // Filter by those created by userID
            self.fetchAllLists(completion: { (lists: [List]) in
                var publicLists = [List]()
                for list in lists {
                    if list.createdByUserID != currentUserID {
                        publicLists.append(list)
                    }
                }
                success(publicLists)
            })
        }
            // User not logged in
        else {
            // TODO: better error handling
            print("User not logged in!")
            failure(nil)
        }
    }
    
    func fetchAllLists(completion: (([List])->())!) -> Void {
        ref.child(listsPath).observeSingleEvent(of: .value) {
            dataSnapshot in
            if let listDicts = dataSnapshot.value as? [String : AnyObject?] {
                for (listIDStr, listDict) in listDicts {
                    // Update existing list, only add new elements if it isn't already in it
                    let newList = List(listID: listIDStr, dictionary: listDict as! [String : AnyObject?])
                    self.allListsByListID[listIDStr] = newList
                }
            }
            completion(Array(self.allListsByListID.values))
        }
    }
    
    func addTip(tip: Tip, completionHandler: ((_ error: Error?) -> Void)? = nil) -> Void {
        let tipID = ref.child(placesPath).child(tip.placeID).childByAutoId().key
        let tipDict = tip.firebaseRepresenation()
        let childUpdates = ["\(placesPath)/\(tipID)": tipDict]
        self.ref.child(placesPath).updateChildValues(childUpdates) {
            (error, _) in
            completionHandler?(error)
        }
    }
    
    func getTips(for placeID: String) -> [Tip] {
        let placeTipsQuery = self.ref.child(placesPath).queryEqual(toValue: placeID)
        let json = JSON(placeTipsQuery)
        print(json)
        // TODO: Unwrap json once we can take a look at an example response to this query
        let tipsArray: [Tip] = []
        return tipsArray
    }
}

