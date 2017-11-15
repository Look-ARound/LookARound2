//
//  PlaceTipsCell.swift
//  lookaround2
//
//  Created by Ali Mir on 11/10/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit

class PlaceTipsCell: UITableViewCell {
    
    @IBOutlet private var authorLabel: UILabel!
    @IBOutlet private var tipTextLabel: UILabel!
    
    internal var tip: Tip? {
        didSet {
            authorLabel.text = tip?.authorName ?? ""
            tipTextLabel.text = tip?.tipText ?? ""
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
