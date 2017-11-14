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
    
    internal var idNum: String? {
        didSet {
            setupViews()
        }
    }
    internal var link: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    private func setupViews() {
        if let categoryLabel = visitButton.titleLabel, var buttonText = categoryLabel.text, let idNum = idNum {
            buttonText = buttonText + " \(idNum)"
        }
    }
    
    private func setupThemeColors() {
        detailButton.tintColor = UIColor.LABrand.primary
        visitButton.tintColor = UIColor.LABrand.primary
    }
    
    @IBAction func onVisitPageButton(_ sender: Any) {
        guard let idNum = idNum else {
            print("invalid ID")
            return
        }
        let fbURLString = "fb://page/\(idNum)"
        var pageURLString = ""
        if link != nil {
            pageURLString = link!
        } else {
            pageURLString = "http://facebook.com/page/\(idNum)"
        }
        
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
