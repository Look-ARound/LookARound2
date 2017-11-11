//
//  AugmentedCalloutView.swift
//  lookaround2
//
//  Created by Angela Yu on 11/10/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit

class AugmentedCalloutView: UIView {
    var annotation: Annotation? {
        didSet {
            loadUI()
        }
    }
    var titleLabel: UILabel?
    var subtitleLabel: UILabel?
    
    public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func loadUI() {
        titleLabel?.removeFromSuperview()
        subtitleLabel?.removeFromSuperview()
        
        titleLabel = UILabel(frame: CGRect(x: 10, y: 0, width: self.frame.size.width, height: 30))
        subtitleLabel = UILabel(frame: CGRect(x: 10, y: 30, width: self.frame.size.width, height: 30))
        
        if let annotation = annotation {
            titleLabel?.text = annotation.title
            subtitleLabel?.text = annotation.subtitle
        }
        
        if let titleLabel = titleLabel {
            titleLabel.font = UIFont.systemFont(ofSize: 16)
            titleLabel.numberOfLines = 0
            titleLabel.textColor = UIColor.LABrand.primary
            updateLabelFrame(label: titleLabel)
            self.addSubview(titleLabel)
        }
        
        if let subtitleLabel = subtitleLabel {
            subtitleLabel.font = UIFont.systemFont(ofSize: 16)
            subtitleLabel.textColor = UIColor.black
            updateLabelFrame(label: subtitleLabel)
            self.addSubview(subtitleLabel)
        }
        
        self.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
        updateViewFrame(view: self)
    }
    
    fileprivate func updateLabelFrame(label: UILabel) {
        let maxSize = CGSize(width: 400, height: 30)
        let size = label.sizeThatFits(maxSize)
        label.frame = CGRect(x: 10, y: label.frame.origin.y, width: size.width, height: label.frame.size.height)
    }
    
    fileprivate func updateViewFrame(view: UIView) {
        var maxWidth = 0
        for v in view.subviews {
            let vw = v.frame.origin.x + v.frame.size.width + v.frame.origin.x
            maxWidth = max(maxWidth, Int(vw))
        }
        view.frame.size.width = CGFloat(maxWidth)
    }
}
