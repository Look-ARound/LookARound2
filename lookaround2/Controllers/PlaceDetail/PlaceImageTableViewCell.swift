//
//  PlaceImageTableViewCell.swift
//  lookaround2
//
//  Created by Ali Mir on 11/10/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit

class PlaceImageTableViewCell: UITableViewCell {
    
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
