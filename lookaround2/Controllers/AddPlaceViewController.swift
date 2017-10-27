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
        fetchUserLists()
        navigationItem.title = "My Lists"
        self.tableView.allowsMultipleSelectionDuringEditing = false
    }
    
    // MARK: - TableView Delegate/DataSource
    
    internal func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    internal func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.section == 0 {
            removeList(at: indexPath)
        }
    }
    
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
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            updateListOnDatabase(list: lists[indexPath.row])
        } else {
            addNewList()
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
            print(error?.localizedDescription ?? "")
        })
    }
    
    private func addNewList() {
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
    
    private func removeList(at indexPath: IndexPath) {
        let listBeingDeleted = lists[indexPath.row].copy
        self.lists.remove(at: indexPath.row)
        self.deleteRow(at: indexPath)
        DatabaseRequests.shared.deleteList(list: listBeingDeleted, completionHandler: nil)
    }
    
    private func createAndSaveNewList(with name: String) {
        let list = List(name: name, placeID: place.id)
        if let list = list {
            self.lists.append(list)
            insertRow(at: IndexPath(row: self.lists.count - 1, section: 0))
            DatabaseRequests.shared.createOrUpdateList(list: list)
        }
    }
    
    private func updateListOnDatabase(list: List) {
        list.placeIDs.append(place.id)
        DatabaseRequests.shared.createOrUpdateList(list: list)
    }
    
    private func deleteRow(at indexPath: IndexPath) {
        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
        self.tableView.endUpdates()
    }
    
    private func insertRow(at indexPath: IndexPath) {
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: [indexPath], with: .automatic)
        self.tableView.endUpdates()
    }
    
    
}
