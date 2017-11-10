//
//  PlaceDetailCell.swift
//  lookaround2
//
//  Created by Ali Mir on 11/10/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit

class PlaceDetailCell: UITableViewCell {
    
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var categoryLabel: UILabel!
    @IBOutlet private var checkinsCountLabel: UILabel!
    @IBOutlet private var friendsCountLabel: UILabel!
    @IBOutlet private var facebookLikeButtonView: UIView!
    @IBOutlet private var aboutLabel: UILabel!
    @IBOutlet private var checkInImageView: UIImageView!
    @IBOutlet private var likeImageView: UIImageView!
    
    internal func initCell(with place: Place) {
        setupViews(with: place)
    }
    
    private func setupViews(with place: Place) {
        nameLabel.text = place.name
        checkinsCountLabel.text = "\(place.checkins ?? 0) checkins"
        categoryLabel.text = place.category
        aboutLabel.text = place.about
        setupThemeColors()
        addLikeControl(objectID: place.id)
        setupFriendsCountLabel(contextCount: place.contextCount ?? 0)
    }
    
    private func setupFriendsCountLabel(contextCount: Int) {
        // FIXME: - Correct this
        friendsCountLabel.text = "\(contextCount) friends like this"
    }
    
    private func addLikeControl(objectID: String) {
        let likeControl = FBSDKLikeControl()
        likeControl.likeControlStyle = FBSDKLikeControlStyle.standard
        likeControl.objectType = .openGraph
        likeControl.frame = facebookLikeButtonView.bounds
        likeControl.likeControlHorizontalAlignment = .left
        likeControl.objectID = objectID
        facebookLikeButtonView.addSubview(likeControl)
    }
    
    private func setupThemeColors() {
        categoryLabel.textColor = UIColor.LABrand.detail
        checkinsCountLabel.textColor = UIColor.LABrand.detail
        friendsCountLabel.textColor = UIColor.LABrand.detail
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
