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

internal class PlaceDetailViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private var modalView: UIView!
    @IBOutlet private var placeImageView: UIImageView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var categoryLabel: UILabel!
    @IBOutlet private var checkinsCountLabel: UILabel!
    @IBOutlet private var friendsCountLabel: UILabel!
    @IBOutlet private var facebookLikeButtonView: UIView!
    @IBOutlet private var addressLabel: UILabel!
    @IBOutlet private var aboutLabel: UILabel!
    @IBOutlet private var directionsButton: UIButton!
    @IBOutlet private var checkInImageView: UIImageView!
    @IBOutlet private var likeImageView: UIImageView!
    @IBOutlet private var bookMarkButton: UIButton!
    @IBOutlet private var mapView: MGLMapView!
    
    // MARK: - Stored Properties
    
    internal var place: Place!
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
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
        self.placeImageView.image = #imageLiteral(resourceName: "placeholder")
        if let imageURLString = place.picture {
            if let imageURL = URL(string: imageURLString) {
                self.placeImageView.setImageWith(imageURL, placeholderImage: #imageLiteral(resourceName: "placeholder"))
            }
        }
        nameLabel.text = place.name
        checkinsCountLabel.text = "\(place.checkins ?? 0) checkins"
        addressLabel.text = place.address
        categoryLabel.text = place.category
        aboutLabel.text = place.about
        directionsButton.layer.cornerRadius = directionsButton.frame.size.height * 0.5
        directionsButton.clipsToBounds = true
        setupThemeColors()
        setupMapView()
        addLikeControl()
        setupBookMarkButton()
        setupFriendsCountLabel()
        //        bookmarkSetup()
    }
    
    private func setupFriendsCountLabel() {
        // FIXME: - Correct this
        friendsCountLabel.text = "\(place.contextCount ?? 0) friends like this"
    }
    
    private func addLikeControl() {
        let likeControl = FBSDKLikeControl()
        likeControl.objectID = "MyPage"
        likeControl.likeControlStyle = FBSDKLikeControlStyle.standard
        likeControl.objectType = .openGraph
        likeControl.frame = facebookLikeButtonView.bounds
        likeControl.likeControlHorizontalAlignment = .left
        likeControl.objectID = place.id
        facebookLikeButtonView.addSubview(likeControl)
    }
    
    private func setupThemeColors() {
        categoryLabel.textColor = UIColor.LABrand.detail
        checkinsCountLabel.textColor = UIColor.LABrand.detail
        friendsCountLabel.textColor = UIColor.LABrand.detail
        addressLabel.textColor = UIColor.LABrand.detail
        checkInImageView.tintColor = UIColor.LABrand.detail
        likeImageView.tintColor = UIColor.LABrand.detail
        directionsButton.tintColor = UIColor.white
        directionsButton.backgroundColor = UIColor.LABrand.primary
    }
    
    private func setupMapView() {
        let annotation = MGLPointAnnotation()
        annotation.coordinate = place.coordinate
        mapView.addAnnotation(annotation)
        mapView.zoomLevel = 14
        mapView.setCenter(place.coordinate, animated: true)
        mapView.styleURL = MGLStyle.streetsStyleURL()
    }
    
    private func setupBookMarkButton() {
        bookMarkButton.setImage(#imageLiteral(resourceName: "bookmark"), for: .normal)
        bookMarkButton.setImage(#imageLiteral(resourceName: "bookmarked"), for: .selected)
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
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addPlaceVC" {
            let addPlaceVC = segue.destination as! AddPlaceViewController
            addPlaceVC.place = self.place
        }
    }
    
}
