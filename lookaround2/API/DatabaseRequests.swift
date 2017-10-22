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

class DatabaseRequests {
    var ref: DatabaseReference = Database.database().reference()
    var fetchedOnce : Bool = false
    var allLists = [List]()
    var listsPath = "lists"
    
    static let shared = DatabaseRequests()
    
    private init () {} // avoid creating object for this class
    
    // Use this method to create/edit a list
    func createOrUpdateList(list: List) -> Void {
        self.ref.child(listsPath).setValue([list.id : list.firebaseRepresentation()])
    }
    
    func deleteList(list: List) -> Void {
        self.ref.child(listsPath).child(list.id).removeValue()
    }
    
    func fetchCurrentUserLists(success: @escaping ([List]?)->(), failure: @escaping (Error?)->()) -> Void {
        var currentUserLists = [List]()
        
        if let currentUserID = AccessToken.current?.userId {
            // Get all lists
            // Filter by those created by userID
            self.fetchAllLists(completion: { (lists: [List]) in
                for list in lists {
                    if list.createdByUserID == currentUserID {
                        currentUserLists.append(list)
                    }
                }
                success(currentUserLists)
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
        if fetchedOnce {
            completion(self.allLists)
            return
        }
        
        ref.child(listsPath).observe(DataEventType.value) { (dataSnapshot: DataSnapshot) in
            if let listDicts = dataSnapshot.value as? [String : AnyObject?] {
                for (listIDStr, listDict) in listDicts {
                    let newList = List(listID: listIDStr, dictionary: listDict as! [String : AnyObject?])
                    self.allLists.append(newList)
                }
            }
            
            completion(self.allLists)
        }
    }
}

