//
//  AnnotationView.swift
//  lookaround2
//
//  Created by Angela Yu on 11/9/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//
//  Forked from ARAnnotationView.swift
//  HDAugmentedRealityDemo
//
//  Created by Danijel Huis on 23/04/15.
//  Copyright (c) 2015 Danijel Huis. All rights reserved.
//


import UIKit
import HDAugmentedReality

protocol AnnotationViewDelegate {
    func didTouch(annotationView: AnnotationView)
}

class AnnotationView: ARAnnotationView {
    var titleLabel: UILabel?
    var subtitleLabel: UILabel?
    var delegate: AnnotationViewDelegate?
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        loadUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.didTouch(annotationView: self)
    }
    
    func loadUI() {
        titleLabel?.removeFromSuperview()
        subtitleLabel?.removeFromSuperview()
        
        titleLabel = UILabel(frame: CGRect(x: 10, y: 0, width: self.frame.size.width, height: 30))
        subtitleLabel = UILabel(frame: CGRect(x: 10, y: 30, width: self.frame.size.width, height: 30))
        
        if let annotation = annotation {
            titleLabel?.text = annotation.title
            subtitleLabel?.text = annotation.identifier
        }

        if let titleLabel = titleLabel {
            titleLabel.font = UIFont.systemFont(ofSize: 16)
            titleLabel.numberOfLines = 0
            titleLabel.textColor = UIColor.LABrand.primary
            updateLabelFrame(label: titleLabel)
            self.addSubview(titleLabel)
        }

        if let subtitleLabel = subtitleLabel {
            subtitleLabel.font = UIFont.systemFont(ofSize: 12)
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
