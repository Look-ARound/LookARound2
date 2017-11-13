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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupThemeColors()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setupThemeColors() {
        addressLabel.textColor = UIColor.LABrand.detail
        aboutLabel.textColor = UIColor.LABrand.detail
    }

}
