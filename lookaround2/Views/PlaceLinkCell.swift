//
//  PlaceLinkCell.swift
//  lookaround2
//
//  Created by Angela Yu on 11/12/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit
import FBSDKCoreKit

class PlaceLinkCell: UITableViewCell {
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var visitButton: UIButton!
    
    internal var place: Place!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    private func setupThemeColors() {
        detailButton.tintColor = UIColor.LABrand.primary
        visitButton.tintColor = UIColor.LABrand.primary
    }
    
    @IBAction func onVisitPageButton(_ sender: Any) {
        let idNum = place.id
        
        let fbURLString = "fb://page/\(idNum)"
        let pageURLString = "http://facebook.com/page/\(idNum)"
        
        guard let fbURL = URL(string: fbURLString), let pageURL = URL(string: pageURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(fbURL) {
            UIApplication.shared.open(fbURL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.open(pageURL, options: [:], completionHandler: nil)
        }
    }

}
