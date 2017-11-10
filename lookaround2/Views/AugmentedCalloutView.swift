//
//  AugmentedCalloutView.swift
//  lookaround2
//
//  Created by Angela Yu on 11/10/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit

class AugmentedCalloutView: UIView {
    var annotation: Annotation?
    var titleLabel: UILabel?
    var subtitleLabel: UILabel?
    
    //===== Public
    /**
     Normally, center of annotationView points to real location of POI, but this property can be used to alter that.
     E.g. if bottom-left edge of annotationView should point to real location, centerOffset should be (0, 1)
     */
    open var centerOffset = CGPoint(x: 0.5, y: 0.5)
    
    fileprivate var initialized: Bool = false
    
    public init()
    {
        super.init(frame: CGRect.zero)
        self.initializeInternal()
    }
    
    public init(for annotation: Annotation)
    {
        self.annotation = annotation
        super.init()
        self.initializeInternal()
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.initializeInternal()
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.initializeInternal()
    }
    
    fileprivate func initializeInternal()
    {
        if self.initialized
        {
            return
        }
        self.initialized = true;
        self.initialize()
    }
    
    open override func awakeFromNib()
    {
        self.bindUi()
    }
    
    /// Will always be called once, no need to call super
    open func initialize()
    {
        
    }
    
    /// Called when distance/azimuth changes, intended to be used in subclasses
    open func bindUi()
    {
        
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        loadUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
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
        
        self.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
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
