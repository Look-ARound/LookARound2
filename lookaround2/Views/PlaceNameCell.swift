//
//  PlaceNameCell.swift
//  lookaround2
//
//  Created by Angela Yu on 11/12/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit

@objc protocol DetailViewControllerDelegate {
    @objc optional func getDirections( destLat: Double, destLong: Double )
    @objc optional func getDirections(for place: Place)
}

class PlaceNameCell: UITableViewCell {
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var categoryLabel: UILabel!
    @IBOutlet private var checkinsCountLabel: UILabel!
    @IBOutlet private var friendsCountLabel: UILabel!
    @IBOutlet private var checkInImageView: UIImageView!
    @IBOutlet private var likeImageView: UIImageView!
    @IBOutlet private var placeImageView: UIImageView!
    @IBOutlet weak var addListButton: UIButton!
    @IBOutlet private var directionsButton: UIButton!
    
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
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    internal func initCell(with place: Place) {
        setupViews(with: place)
    }
    
    private func setupViews(with place: Place) {
        nameLabel.text = place.name
        checkinsCountLabel.text = "\(place.checkins ?? 0) checkins"
        categoryLabel.text = place.category
        setupThemeColors()
        setupFriendsCountLabel(contextCount: place.contextCount ?? 0)
    }
    
    private func setupThemeColors() {
        nameLabel.textColor = UIColor.LABrand.standard
        categoryLabel.textColor = UIColor.LABrand.detail
        checkinsCountLabel.textColor = UIColor.LABrand.detail
        friendsCountLabel.textColor = UIColor.LABrand.standard
        checkInImageView.tintColor = UIColor.LABrand.detail
        likeImageView.tintColor = UIColor.LABrand.detail
        addListButton.tintColor = UIColor.LABrand.primary
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
        delegate?.getDirections?(for: place)
        dismiss(animated: true, completion: nil)
    }
    
    // On "Add List" button
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addPlaceVC" {
            let addPlaceVC = segue.destination as! AddPlaceViewController
            addPlaceVC.place = self.place
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
