//
//  PlaceDetailTableViewController.swift
//  LookARound
//
//  Created by Ali Mir on 10/15/17.
//  Copyright © 2017 LookARound. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
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
    @IBOutlet private var facebookLikeButtonView: UIView!
    @IBOutlet private var addressLabel: UILabel!
    @IBOutlet private var aboutLabel: UILabel!
    @IBOutlet private var directionsButton: UIButton!
    @IBOutlet private var checkInImageView: UIImageView!
    @IBOutlet private var doneBarButtonItem: UIBarButtonItem!
    @IBOutlet private var addBarButtonItem: UIBarButtonItem!
    @IBOutlet private var bookmarkBarButtonItem: UIBarButtonItem!
    @IBOutlet private var mapView: UIView!
    
    // MARK: - Stored Properties
    
    internal var place: Place!
    internal var delegate: PlaceDetailTableViewControllerDelegate?
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        self.tableView.contentInset = UIEdgeInsetsMake(-64, 0, 0, 0)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Setup Views
//    setupDummyPlace()
    private func setupViews() {
        if let imageURLString = place.picture {
            if let imageURL = URL(string: imageURLString) {
                self.placeImageView.setImageWith(imageURL)
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
    
    
    // DEPRICATED Adding address view below
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
        guard let mapView = mapView as? MGLMapView else { return }
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
    
    @IBAction func onCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - TableView Delegate/DataSource
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    // DEPRICATED Bring address view to front
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
