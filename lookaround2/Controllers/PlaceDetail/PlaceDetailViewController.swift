//
//  PlaceDetailViewController.swift
//  lookaround2
//
//  Created by Ali Mir on 11/6/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit
import AFNetworking
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import Mapbox


fileprivate enum OperationType {
    case add
    case remove
}

internal class PlaceDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Outlets
    
    @IBOutlet private var modalView: UIView!
    @IBOutlet private var bookMarkButton: UIButton!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet weak var addTipButton: UIButton!
    @IBOutlet weak var addListButton: UIButton!
    
    // MARK: - Stored Properties
    
    internal var place: Place!
    internal var tips = [Tip]()
    
    // MARK: - Computed Properties
    
    private var isBookMarked: Bool = false {
        didSet {
            bookMarkButton.isSelected = isBookMarked
        }
    }
    
    // MARK: - Lifecycles

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchTips()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        fetchTips()
        tableView.reloadData()
        updateBookMarkSetup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - Setup Views
    
    private func setupViews() {
        modalView.layer.cornerRadius = 10
        modalView.layer.masksToBounds = true
        addTipButton.backgroundColor = UIColor.LABrand.primary
        addListButton.tintColor = UIColor.LABrand.primary
        setupBookMarkButton()
    }
    
    private func setupBookMarkButton() {
        bookMarkButton.setImage(#imageLiteral(resourceName: "bookmark"), for: .normal)
        bookMarkButton.setImage(#imageLiteral(resourceName: "bookmarked"), for: .selected)
        bookMarkButton.tintColor = UIColor.LABrand.primary
    }
    
    private func updateBookMarkSetup() {
        DatabaseRequests.shared.fetchCurrentUserLists(success: {
            lists in
            self.bookMarkButton.isSelected = false
            guard let lists = lists else { return }
            for list in lists {
                if list.name == "Bookmarks" {
                    if list.placeIDs.contains(self.place.id) {
                        self.isBookMarked = true
                    }
                }
            }
        }, failure: nil)
    }
    
    // MARK: - Helpers
    
    private func addTip(text: String) {
        Tip.CreateTip(for: place.id, text: text) {
            tip, error in
            if let tip = tip {
                DatabaseRequests.shared.addTip(tip: tip)
                self.tips.append(tip)
                let indexPath = IndexPath(row: self.tips.count - 1, section: 2)
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: [indexPath], with: .automatic)
                self.tableView.endUpdates()
            } else {
                _ = SweetAlert().showAlert("Error", subTitle: error!.localizedDescription, style: .error)
            }
        }
    }
    
    private func fetchTips() {
        DatabaseRequests.shared.fetchTips(for: place.id, success: { tipsArray in
            if let tips = tipsArray {
                self.tips = tips
                self.tableView.reloadData()
            }
            return
        }, failure: {
            error  in
            if let error = error {
                _ = SweetAlert().showAlert("Error", subTitle: error.localizedDescription, style: .error)
            }
        })
    }
    
    private func updateBookmark(operation: OperationType) {
        switch operation {
        case .add:
            addToBookmarks()
        case .remove:
            removeFromBookmarks()
        }
    }
    
    private func addToBookmarks() {
        DatabaseRequests.shared.fetchCurrentUserLists(success: {
            lists in
            guard let lists = lists else { return }
            for list in lists {
                if list.name == "Bookmarks" {
                    list.placeIDs.append(self.place.id)
                    self.createOrUpdateList(for: list)
                    return
                }
            }
            self.createOrUpdateList(for: List(name: "Bookmarks", placeID: self.place.id))
        }, failure: nil)
    }
    
    private func removeFromBookmarks() {
        DatabaseRequests.shared.fetchCurrentUserLists(success: {
            lists in
            guard let lists = lists else { return }
            for list in lists {
                if list.name == "Bookmarks" {
                    for (index, placeID) in list.placeIDs.enumerated() {
                        if placeID == self.place.id {
                            list.placeIDs.remove(at: index)
                            self.createOrUpdateList(for: list)
                            return
                        }
                    }
                }
            }
        }, failure: nil)
    }
    
    private func createOrUpdateList(for list: List?) {
        guard let list = list else {
            _ = SweetAlert().showAlert("Error", subTitle: "Could not save bookmark!", style: .error)
            return
        }
        DatabaseRequests.shared.createOrUpdateList(list: list) {
            error in
            if let error = error {
                _ = SweetAlert().showAlert("Error", subTitle: error.localizedDescription, style: .error)
            }
        }
    }
    
    // MARK: - Target/Actions
    
    @IBAction private func onBGTap(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func onBookmarkToggle(_ sender: Any) {
        isBookMarked = !isBookMarked
        updateBookmark(operation: isBookMarked ? .add : .remove)
    }
    
    @IBAction private func onAddTip(_ sender: Any) {
        let alertVC = UIAlertController(title: "Add a tip", message: nil, preferredStyle: .alert)
        alertVC.addTextField {
            textField in
            textField.placeholder = "Type your tip here"
        }
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            _ in
            if let text =  alertVC.textFields?[0].text {
                self.addTip(text: text)
            }
        }
        alertVC.addAction(saveAction)
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addPlaceVC" {
            let addPlaceVC = segue.destination as! AddPlaceViewController
            addPlaceVC.place = self.place
        }
    }
    
    // MARK: - UITableView Setup
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        default:
            return tips.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let placeImageCell = tableView.dequeueReusableCell(withIdentifier: "placeImageCell", for: indexPath) as! PlaceImageTableViewCell
            placeImageCell.imageURLString = place.picture
            return placeImageCell
        case 1:
            let placeDetailCell = tableView.dequeueReusableCell(withIdentifier: "placeDetailCell", for: indexPath) as! PlaceDetailCell
            placeDetailCell.initCell(with: place)
            return placeDetailCell
        default:
            let tipsCell = tableView.dequeueReusableCell(withIdentifier: "placeTipsCell", for: indexPath) as! PlaceTipsCell
            tipsCell.tip = tips[indexPath.row]
            return tipsCell
        }
    }
    
}
