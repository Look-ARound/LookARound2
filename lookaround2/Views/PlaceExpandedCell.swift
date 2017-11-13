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
    
    internal var place: Place? {
        didSet {
            print("expanded place set")
            setupViews()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("expanded awake")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    private func setupViews() {
        guard let place = place else {
            print("nil place ExpandedCell")
            return
        }
        addressLabel.text = place.address
        aboutLabel.text = place.about
        setupThemeColors()
    }
    
    private func setupThemeColors() {
        addressLabel.textColor = UIColor.LABrand.detail
        aboutLabel.textColor = UIColor.LABrand.detail
    }
    

}
