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
    private var newListName = ""
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        if indexPath.section == 0 {
            updateListOnDatabase(list: lists[indexPath.row])
        } else {
            let alert = UIAlertController(title: "New List", message: nil, preferredStyle: .alert)
            alert.addTextField {
                textField in
                textField.placeholder = "Name of the list"
                textField.addTarget(self, action: #selector(self.saveListName), for: .valueChanged)
                textField.delegate = self
            }
            let saveAction = UIAlertAction(title: "Save", style: .default) {
                _ in
                self.createAndSaveNewList()
            }
            alert.addAction(saveAction)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
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
            print(error.localizedDescription)
        })
    }
    
    private func createAndSaveNewList() {
        if let list = List(name: newListName, placeID: place.id) {
            DatabaseRequests.shared.createOrUpdateList(list: list)
        }
    }
    
    private func updateListOnDatabase(list: List) {
        list.placeIDs.append(place.id)
        DatabaseRequests.shared.createOrUpdateList(list: list)
    }
    
    // MARK: - TextField
    
    @objc func saveListName(_ sender: UITextField) {
        newListName = sender.text ?? ""
    }
    
    
}
