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
        titleLabel?.frame = CGRect(x: 10, y: 0, width: self.frame.size.width, height: 30)
        subtitleLabel?.frame = CGRect(x: 10, y: 30, width: self.frame.size.width, height: 20)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.didTouch(annotationView: self)
    }
    
    func loadUI() {
        titleLabel?.removeFromSuperview()
        subtitleLabel?.removeFromSuperview()
        
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: self.frame.size.width, height: 30))
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.backgroundColor = UIColor(white: 0.3, alpha: 0.7)
        label.textColor = UIColor.white
        self.addSubview(label)
        self.titleLabel = label
        
        subtitleLabel = UILabel(frame: CGRect(x: 10, y: 30, width: self.frame.size.width, height: 20))
        subtitleLabel?.backgroundColor = UIColor(white: 0.3, alpha: 0.7)
        subtitleLabel?.textColor = UIColor.green
        subtitleLabel?.font = UIFont.systemFont(ofSize: 12)
        self.addSubview(subtitleLabel!)
        
        if let annotation = annotation {
            titleLabel?.text = annotation.title
            subtitleLabel?.text = annotation.identifier
        }
    }
}
