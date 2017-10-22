//
//  AddPlaceViewController.swift
//  lookaround2
//
//  Created by Ali Mir on 10/22/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit

internal class AddPlaceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet private var tableView: UITableView!
    private var lists = [List]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserLists()
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listNameCell", for: indexPath)
        let list = lists[indexPath.row]
        cell.textLabel?.text = list.name
        return cell
    }
    
    // MARK: - Helpers
    
    private func fetchUserLists() {
        DatabaseRequests.shared.fetchCurrentUserLists(success: {
            lists in
            self.lists = lists
            tableView.reloadData()
        }, failure: {
            error in
            // FIXME: - Needs better error handling!
            print(error.localizedDescription)
        })
    }
    
}
