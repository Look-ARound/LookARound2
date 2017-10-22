//
//  AddPlaceViewController.swift
//  lookaround2
//
//  Created by Ali Mir on 10/22/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit

internal class AddPlaceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Outlets
    
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Stored Properties
    
    private var lists = [List]()
    internal var place: Place!
    
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserLists()
    }
    
    // MARK: - TableView Delegate/DataSource
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listNameCell", for: indexPath)
        let list = lists[indexPath.row]
        cell.textLabel?.text = list.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        updateListOnDatabase(list: lists[indexPath.row])
    }
    
    // MARK: - Helpers
    
    private func fetchUserLists() {
        DatabaseRequests.shared.fetchCurrentUserLists(success: {
            lists in
            if let lists = lists {
                self.lists = lists
                self.tableView.reloadData()
            }
        }, failure: {
            error in
            // FIXME: - Needs better error handling!
            print(error.localizedDescription)
        })
    }
    
    private func updateListOnDatabase(list: List) {
        list.placeIDs.append(place.id)
        DatabaseRequests.shared.createOrUpdateList(list: list)
    }
    
}
