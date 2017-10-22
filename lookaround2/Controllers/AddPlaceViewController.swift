//
//  AddPlaceViewController.swift
//  lookaround2
//
//  Created by Ali Mir on 10/22/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit

internal class AddPlaceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Stored Properties
    
    private var lists = [List]()
    internal var place: Place!
    private var alertVC: UIAlertController!
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserLists()
    }
    
    // MARK: - TableView Delegate/DataSource
    
    internal func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? lists.count : 1
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "listNameCell", for: indexPath)
            let list = lists[indexPath.row]
            cell.textLabel?.text = list.name
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "newListCell", for: indexPath)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            updateListOnDatabase(list: lists[indexPath.row])
        } else {
            alertVC = UIAlertController(title: "Name", message: nil, preferredStyle: .alert)
            alertVC.addTextField {
                textField in
                textField.placeholder = "Name of the new list"
            }
            let saveAction = UIAlertAction(title: "Save", style: .default) {
                _ in
                if let listName =  self.alertVC.textFields?[0].text, !listName.isEmpty {
                    self.createAndSaveNewList(with: listName)
                } else {
                    print("NO NAME")
                }
            }
            alertVC.addAction(saveAction)
            alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alertVC, animated: true, completion: nil)
        }
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
            print(error?.localizedDescription)
        })
    }
    
    private func createAndSaveNewList(with name: String) {
        let list = List(name: name, placeID: place.id)
        if let list = list {
            DatabaseRequests.shared.createOrUpdateList(list: list)
        }
    }
    
    private func updateListOnDatabase(list: List) {
        list.placeIDs.append(place.id)
        DatabaseRequests.shared.createOrUpdateList(list: list)
    }
    
    
}
