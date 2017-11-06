//
//  PlaceDetailTableViewController.swift
//  LookARound
//
//  Created by Ali Mir on 10/15/17.
//  Copyright © 2017 LookARound. All rights reserved.
//

import UIKit
import AFNetworking
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import Mapbox

@objc protocol PlaceDetailTableViewControllerDelegate {
    @objc optional func getDirections( destLat: Double, destLong: Double )
    @objc optional func getDirections(for place: Place)
}

internal class PlaceDetailTableViewController: UITableViewController {
    
    // MARK: - Outlets
    
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
    @IBOutlet private var doneBarButtonItem: UIBarButtonItem!
    @IBOutlet private var addBarButtonItem: UIBarButtonItem!
    @IBOutlet private var bookmarkBarButtonItem: UIBarButtonItem!
    @IBOutlet private var friendsConstraint: NSLayoutConstraint!
    @IBOutlet private var mapView: MGLMapView!
    
    // MARK: - Stored Properties
    
    internal var place: Place!
    internal var delegate: PlaceDetailTableViewControllerDelegate?
    private var hasBookmarks: Bool = false
    private var isBookmarked: Bool = false
    private var bookmarksList: List?
    private var bookmarkIndex: Int?
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        self.tableView.contentInset = UIEdgeInsetsMake(-64, 0, 0, 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    // MARK: - Setup Views
//    setupDummyPlace()
    private func setupViews() {
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
        addLikeButton()
        findBookmarks()
    }
    
    // FOR DEBUG
    private func setupDummyPlace() {
        place = Place(id: "ldksl32f", name: "Some Place", latitude: 37.3382, longitude: -121.8863)
         place.picture = "https://media-cdn.tripadvisor.com/media/photo-s/03/c4/95/72/carne-y-vino-restaurant.jpg"
         place.about = "This is an authentic restaurant with lots of stuff in it and I'm just typing for the sake of testing and nothing else really I'm just doing this for a test thing and stuff yeah so it's authentic and stuff dude!"
         place.category = "Indian Restaurant"
         place.checkins = 233
         place.address = "261 University Ave"
         place.id = "460770554016783"
    }
    
    private func addLikeButton() {
        let likeButton = FBSDKLikeButton()
        likeButton.objectID = place.id
        likeButton.objectType = .openGraph
        likeButton.frame = facebookLikeButtonView.bounds
        facebookLikeButtonView.addSubview(likeButton)
        
        guard let friends = place.contextCount else {
            friendsCountLabel.isHidden = true
            friendsConstraint.isActive = false
            return
        }
        switch friends {
        case _ where friends > 1:
            friendsCountLabel.text = "\(friends) friends like this"
            friendsCountLabel.isHidden = false
            friendsConstraint.isActive = true
        case _ where friends == 1:
            friendsCountLabel.text = "1 friend likes this"
            friendsCountLabel.isHidden = false
            friendsConstraint.isActive = true
        default:
            friendsCountLabel.isHidden = true
            friendsConstraint.isActive = false
        }

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
        navigationController?.navigationBar.barStyle = .black
        doneBarButtonItem.tintColor = UIColor.LABrand.buttons
        addBarButtonItem.tintColor = UIColor.LABrand.buttons
        bookmarkBarButtonItem.tintColor = UIColor.LABrand.buttons
        categoryLabel.textColor = UIColor.LABrand.detail
        checkinsCountLabel.textColor = UIColor.LABrand.detail
        checkInImageView.tintColor = UIColor.LABrand.detail
        directionsButton.tintColor = UIColor.white
        directionsButton.backgroundColor = UIColor.LABrand.primary
        aboutLabel.textColor = UIColor.LABrand.detail
    }
    
    
    // DEPRECATED Adding address view below
    /*private func addBottomAddressView() {
        addressLabelView = UIView(frame: CGRect(x: 0, y: self.view.frame.height - 50, width: self.view.frame.width, height: 50))
        addressLabelView.backgroundColor = .white
        addressLabel = UILabel(frame: CGRect(x: 8, y: 8, width: addressLabelView.frame.width - 8, height: addressLabelView.frame.height - 8))
        addressLabel.numberOfLines = 0
        addressLabel.textAlignment = .left
        addressLabelView.addSubview(addressLabel)
        self.view.addSubview(addressLabelView)
    }*/
    
    private func setupMapView() {
        let annotation = MGLPointAnnotation()
        annotation.coordinate = place.coordinate
        mapView.addAnnotation(annotation)
        mapView.zoomLevel = 14
        mapView.setCenter(place.coordinate, animated: true)
        mapView.styleURL = MGLStyle.streetsStyleURL()
    }
    
    @IBAction func onDirectionsButton(_ sender: Any) {
        delegate?.getDirections?(for: place)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onBookmarkButton(_ sender: Any) {
        if !isBookmarked {
            print("adding")
            addBookmark()
        } else {
            print("removing")
            removeBookmark()
        }

    }
    
    @IBAction func onCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Helpers
    private func findBookmarks()  {
        DatabaseRequests.shared.fetchCurrentUserLists(success: {
            lists in
            if let lists = lists {
                for (index, list) in lists.enumerated() {
                    if list.name == "Bookmarks" {
                        print("found bookmarks list")
                        self.bookmarksList = list
                        self.hasBookmarks = true
                        for (index, placeID) in list.placeIDs.enumerated() {
                            if placeID == self.place.id {
                                print("bookmark exists, changing button")
                                //let button = UIButton.init(type: UIButtonType.custom)
                                //button.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
                                //button.setImage(UIImage(named: "bookmarked-2x.png"), for: .normal)
                                //button.addTarget(self, action: #selector(self.onBookmarkButton(_:)), for: UIControlEvents.touchUpInside)
                                //self.bookmarkBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "bookmarked"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.onBookmarkButton(_:)))
                                self.navigationItem.rightBarButtonItems![0] = UIBarButtonItem(image: #imageLiteral(resourceName: "bookmarked"),
                                                                                              style: UIBarButtonItemStyle.plain,
                                                                                              target: self,
                                                                                              action: #selector(self.onBookmarkButton(_:)))
                                self.navigationItem.rightBarButtonItems![0].tintColor = UIColor.white
                                //self.navigationItem.rightBarButtonItems![0] = UIBarButtonItem(customView: button)
                                //self.bookmarkBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.bookmarks, target: self, action: #selector(self.onBookmarkButton(_:)))
                                self.isBookmarked = true
                                self.bookmarkIndex = index
                            }
                        }
                    }
                }
            }
        }, failure: {
            error in
            // FIXME: - Needs better error handling!
            print(error?.localizedDescription ?? "")
        })
    }
    
    private func addBookmark() {
        if !hasBookmarks {
            print("hasB is false")
            guard let bList = List(name: "Bookmarks", placeID: place.id) else {
                print("couldn't create list")
                return
            }
            DatabaseRequests.shared.createOrUpdateList(list: bList) { error in
                if let error = error {
                    _ = SweetAlert().showAlert("Error", subTitle: error.localizedDescription, style: .error)
                } else {
                    _ = SweetAlert().showAlert("Success!", subTitle: "Created Bookmarks list and added \(self.place.name) to your Bookmarks.", style: .success)
                }
            }
            self.navigationItem.rightBarButtonItems![0] = UIBarButtonItem(image: #imageLiteral(resourceName: "bookmarked"),
                                                                          style: UIBarButtonItemStyle.plain,
                                                                          target: self,
                                                                          action: #selector(self.onBookmarkButton(_:)))
            self.navigationItem.rightBarButtonItems![0].tintColor = UIColor.white
            isBookmarked = true
            bookmarkIndex = 0
            bookmarksList = bList
        } else {
            print("hasB is true")
            guard let bList = bookmarksList else {
                print("couldn't set bookmarksList")
                return
            }
            bList.placeIDs.append(place.id)
            DatabaseRequests.shared.createOrUpdateList(list: bList, completionHandler: { error in
                if let error = error {
                    _ = SweetAlert().showAlert("Error", subTitle: error.localizedDescription, style: .error)
                } else {
                    _ = SweetAlert().showAlert("Success!", subTitle: "Added \(self.place.name) to your Bookmarks.", style: .success)
                }
            })
            self.navigationItem.rightBarButtonItems![0] = UIBarButtonItem(image: #imageLiteral(resourceName: "bookmarked"),
                                                                          style: UIBarButtonItemStyle.plain,
                                                                          target: self,
                                                                          action: #selector(self.onBookmarkButton(_:)))
            self.navigationItem.rightBarButtonItems![0].tintColor = UIColor.white
            isBookmarked = true
            bookmarkIndex = bList.placeIDs.count - 1
            bookmarksList = bList
            hasBookmarks = true
        }
    }
    
    private func removeBookmark() {
        if let index = bookmarkIndex {
            if let list = bookmarksList {
                list.placeIDs.remove(at: index)
                DatabaseRequests.shared.createOrUpdateList(list: list)
            }
            isBookmarked = false
            bookmarkIndex = nil
            self.navigationItem.rightBarButtonItems![0] = UIBarButtonItem(image: #imageLiteral(resourceName: "bookmark"),
                                                                          style: UIBarButtonItemStyle.plain,
                                                                          target: self,
                                                                          action: #selector(self.onBookmarkButton(_:)))
            self.navigationItem.rightBarButtonItems![0].tintColor = UIColor.white
        }
    }
    
    // MARK: - TableView Delegate/DataSource
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    // DEPRECATED Bring address view to front
    /*override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var frame: CGRect = addressLabelView.frame
        frame.origin.y = scrollView.contentOffset.y + tableView.frame.size.height - addressLabelView.frame.size.height
        addressLabelView.frame = frame
        view.bringSubview(toFront: addressLabelView)
    }*/
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addPlaceVC" {
            let addPlaceVC = segue.destination as! AddPlaceViewController
            addPlaceVC.place = self.place
        }
    }
}
