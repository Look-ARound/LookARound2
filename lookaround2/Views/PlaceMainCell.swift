//
//  PlaceMainCell.swift
//  lookaround2
//
//  Created by Angela Yu on 11/15/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit

@objc protocol PlaceMainCellDelegate {
    @objc optional func getDirections(for place: Place)
    func addPlace(on viewController: AddPlaceViewController)
}

class PlaceMainCell: UITableViewCell {
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var categoryLabel: UILabel!
    @IBOutlet private var checkinsCountLabel: UILabel!
    @IBOutlet private var friendsCountLabel: UILabel!
    @IBOutlet private var checkInImageView: UIImageView!
    @IBOutlet private var likeImageView: UIImageView!
    @IBOutlet private var placeImageView: UIImageView!
    @IBOutlet weak var addListButton: UIButton!
    @IBOutlet private var directionsButton: UIButton!
    
    internal var delegate: PlaceMainCellDelegate?
    internal var place: Place?
    
    internal var imageURLString: String? {
        didSet {
            self.placeImageView.image = #imageLiteral(resourceName: "placeholder")
            if let imageURLString = imageURLString {
                if let imageURL = URL(string: imageURLString) {
                    self.placeImageView.setImageWith(imageURL, placeholderImage: #imageLiteral(resourceName: "placeholder"))
                }
            }
        }
    }
    
    internal func setupViews() {
        guard let place = place else {
            print("nil place")
            return
        }
        nameLabel.text = place.name
        checkinsCountLabel.text = "\(place.checkins ?? 0) checkins"
        categoryLabel.text = place.category
        imageURLString = place.picture
        setupThemeColors()
        setupFriendsCountLabel(contextCount: place.contextCount ?? 0)
        //self.contentView.layoutIfNeeded()
        //self.layoutIfNeeded()
        //self.layoutSubviews()
        //self.contentView.layoutSubviews()
    }
    
    private func setupThemeColors() {
        nameLabel.textColor = UIColor.LABrand.standard
        categoryLabel.textColor = UIColor.LABrand.detail
        checkinsCountLabel.textColor = UIColor.LABrand.detail
        friendsCountLabel.textColor = UIColor.LABrand.accent
        checkInImageView.tintColor = UIColor.LABrand.detail
        likeImageView.tintColor = UIColor.LABrand.detail
        addListButton.tintColor = UIColor.LABrand.primary
        let tintedImage = #imageLiteral(resourceName: "walking").withRenderingMode(.alwaysTemplate)
        directionsButton.setImage(tintedImage, for: .normal)
        directionsButton.tintColor = UIColor.LABrand.primary
    }
    
    private func setupFriendsCountLabel(contextCount: Int) {
        switch contextCount {
        case 1:
            friendsCountLabel.text = "\(contextCount) friend likes this"
            friendsCountLabel.isHidden = false
            likeImageView.isHidden = false
        case _ where contextCount > 1:
            friendsCountLabel.text = "\(contextCount) friends like this"
            friendsCountLabel.isHidden = false
            likeImageView.isHidden = false
        case 0:
            friendsCountLabel.isHidden = true
            likeImageView.isHidden = true
        default:
            friendsCountLabel.isHidden = true
            likeImageView.isHidden = true
        }
    }
    
    @IBAction func onDirectionsButton(_ sender: Any) {
        guard let place = place else {
            print("nil place")
            return
        }
        delegate?.getDirections?(for: place)
    }
    
    // On "Add List" button
    
    @IBAction func onAddLIst(_ sender: Any) {
        let dStoryboard = UIStoryboard(name: "Detail", bundle: nil)
        let addPlaceVC = dStoryboard.instantiateViewController(withIdentifier: "AddPlaceViewController") as! AddPlaceViewController
        guard let place = place else {
            print ("nil place")
            return
        }
        addPlaceVC.place = place
        delegate?.addPlace(on: addPlaceVC)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

