//
//  PlaceNameCell.swift
//  lookaround2
//
//  Created by Angela Yu on 11/12/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit

class PlaceNameCell: UITableViewCell {
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var categoryLabel: UILabel!
    @IBOutlet private var checkinsCountLabel: UILabel!
    @IBOutlet private var friendsCountLabel: UILabel!
    @IBOutlet private var checkInImageView: UIImageView!
    @IBOutlet private var likeImageView: UIImageView!
    @IBOutlet private var placeImageView: UIImageView!
    
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
    
    private func setupThemeColors() {
        categoryLabel.textColor = UIColor.LABrand.detail
        checkinsCountLabel.textColor = UIColor.LABrand.detail
        friendsCountLabel.textColor = UIColor.LABrand.standard
        checkInImageView.tintColor = UIColor.LABrand.detail
        likeImageView.tintColor = UIColor.LABrand.detail
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
