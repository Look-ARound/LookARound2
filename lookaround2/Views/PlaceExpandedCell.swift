//
//  PlaceExpandedCell.swift
//  lookaround2
//
//  Created by Angela Yu on 11/12/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit

class PlaceExpandedCell: UITableViewCell {
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    
    internal func initCell(with place: Place) {
        setupViews(with: place)
    }
    
    private func setupViews(with place: Place) {
        addressLabel.text = place.address
        aboutLabel.text = place.description
        setupThemeColors()
    }
    
    private func setupThemeColors() {
        addressLabel.textColor = UIColor.LABrand.detail
        aboutLabel.textColor = UIColor.LABrand.detail
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    

}
