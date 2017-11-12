//
//  FilterCell.swift
//  LookARound
//
//  Created by Siji Rachel Tom on 10/14/17.
//  Copyright © 2017 LookARound. All rights reserved.
//

import UIKit

class FilterCell: UITableViewCell {
    @IBOutlet weak var filterNameLabel: UILabel!
    @IBOutlet var authorName: UILabel!
    
    var listElement: List! {
        didSet {
            filterNameLabel.text = listElement.name
            if authorName.isHidden == false {
                authorName.text = listElement.createdByUserName
            }
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
