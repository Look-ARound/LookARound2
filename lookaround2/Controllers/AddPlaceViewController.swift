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
    private var listsThatHavePlace = [Int : Bool]()
    internal var place: Place!
    private var alertVC: UIAlertController!
    
    // MARK: - Lifecycles
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.backgroundColor = UIColor.LABrand.primary
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.backgroundColor = nil
    }
    
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
            
            // Checkmark configuration
            let shouldContainCheckMark = listsThatHavePlace[indexPath.row] ?? false
            cell.accessoryType = shouldContainCheckMark ? .checkmark : .none
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "newListCell", for: indexPath)
        }
        return cell
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            let shouldCheckMark = !(listsThatHavePlace[indexPath.row] ?? false)
            updateListOnDatabase(isAdding: shouldCheckMark, for: indexPath, list: lists[indexPath.row], creatingNewList: false)
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
                for (index, list) in lists.enumerated() {
                    self.listsThatHavePlace[index] = list.placeIDs.contains(self.place.id)
                }
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
                self.createAndSaveNewList(with: listName, creatingNewPlace: true)
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
        lists.remove(at: indexPath.row)
        listsThatHavePlace.removeValue(forKey: indexPath.row)
        deleteRow(at: indexPath)
        DatabaseRequests.shared.deleteList(list: listBeingDeleted, completionHandler: nil)
    }
    
    private func createAndSaveNewList(with name: String, creatingNewPlace: Bool) {
        let list = List(name: name, placeID: place.id)
        if let list = list {
            self.lists.append(list)
            let indexPath = IndexPath(row: self.lists.count - 1, section: 0)
            insertRow(at: indexPath)
            addPlaceToDatabase(from: indexPath, list: list, creatingNewList: creatingNewPlace)
        }
    }
    
    private func updateListOnDatabase(isAdding: Bool, for indexPath: IndexPath, list: List, creatingNewList: Bool) {
        if isAdding {
            list.placeIDs.append(place.id)
            addPlaceToDatabase(from: indexPath, list: list, creatingNewList: creatingNewList)
        } else {
            // kinda inefficient? Was sleepy while doing this...
            for (index, placeID) in list.placeIDs.enumerated() {
                if placeID == place.id {
                    list.placeIDs.remove(at: index)
                    removePlaceFromDatabase(indexPath: indexPath, list: list)
                    return
                }
            }
        }
    }
    
    private func removePlaceFromDatabase(indexPath: IndexPath, list: List) {
        DatabaseRequests.shared.createOrUpdateList(list: list)
        configCheckMark(shouldCheckMark: false, indexPath: indexPath)
    }
    
    private func addPlaceToDatabase(from indexPath: IndexPath, list: List, creatingNewList: Bool) {
        if creatingNewList {
            DatabaseRequests.shared.createOrUpdateList(list: list) { error in
                if let error = error {
                    _ = SweetAlert().showAlert("Error", subTitle: error.localizedDescription, style: .error)
                } else {
                    _ = SweetAlert().showAlert("Success!", subTitle: "Successfully added '\(list.name)' to your lists.", style: .success)
                }
            }
        } else {
            DatabaseRequests.shared.createOrUpdateList(list: list)
        }
        configCheckMark(shouldCheckMark: true, indexPath: indexPath)
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
    
    private func configCheckMark(shouldCheckMark: Bool, indexPath: IndexPath) {
        // Checkmark Configuration
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        cell.accessoryType = shouldCheckMark ? .checkmark : .none
        listsThatHavePlace[indexPath.row] = shouldCheckMark
    }
    
}
