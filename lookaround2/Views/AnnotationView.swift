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
    var pinImage: UIImageView?
    var likeImage: UIImageView?
    var checkinImage: UIImageView?
    var delegate: AnnotationViewDelegate?
    
    let xpos1: CGFloat = 61
    
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
        
        titleLabel = UILabel(frame: CGRect(x: xpos1, y: 10, width: self.frame.size.width-20, height: 30))
        // titleLabel?.backgroundColor = UIColor.yellow
        
        subtitleLabel = UILabel(frame: CGRect(x: xpos1+30, y: 40, width: self.frame.size.width-20, height: 30))
        // subtitleLabel?.backgroundColor = UIColor.cyan
        
        let image: UIImage = UIImage(named: "pin" )!
        pinImage = UIImageView(image: image)
        pinImage!.frame = CGRect( x:10, y:12, width: 37, height: 60 )
        self.addSubview(pinImage!)
        
        let image2: UIImage = UIImage(named: "like" )!
        likeImage = UIImageView(image: image2)
        likeImage?.tintColor = UIColor.white
        likeImage!.frame = CGRect( x: xpos1, y: 42, width: 20, height: 20 )
        
        let image3: UIImage = UIImage(named: "checkin" )!
        checkinImage = UIImageView(image: image3)
        checkinImage?.tintColor = UIColor.white
        checkinImage!.frame = CGRect( x: xpos1, y: 42, width: 20, height: 20 )

        if let annotation = annotation {
            titleLabel?.text = annotation.title
            subtitleLabel?.text = annotation.identifier
            
            if (annotation.identifier?.containsIgnoreCase("like"))! {
                self.addSubview(likeImage!)
            } else {
                self.addSubview(checkinImage!)
            }
        }

        if let titleLabel = titleLabel {
            titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
            titleLabel.numberOfLines = 0
            titleLabel.textColor = UIColor.white
            updateTitleFrame(label: titleLabel)
            self.addSubview(titleLabel)
        }

        if let subtitleLabel = subtitleLabel {
            subtitleLabel.font = UIFont.systemFont(ofSize: 16)
            subtitleLabel.textColor = UIColor.white
            updateSubtitleFrame(label: subtitleLabel)
            self.addSubview(subtitleLabel)
        }
        
        //self.backgroundColor = UIColor(red:0.15, green:0.78, blue:0.85, alpha:0.6)
        self.backgroundColor = UIColor.darkGray
        self.alpha = 0.8
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
        updateViewFrame(view: self)
    }
    
    fileprivate func updateTitleFrame(label: UILabel) {
        let maxSize = CGSize(width: 400-50, height: 30)
        let size = label.sizeThatFits(maxSize)
        label.frame = CGRect(x: xpos1, y: label.frame.origin.y, width: size.width, height: label.frame.size.height)
    }
    
    fileprivate func updateSubtitleFrame(label: UILabel) {
        let maxSize = CGSize(width: 400-200, height: 30)
        let size = label.sizeThatFits(maxSize)
        label.frame = CGRect(x: xpos1+30, y: label.frame.origin.y, width: size.width+30, height: label.frame.size.height)
    }
    
    fileprivate func updateViewFrame(view: UIView) {
        var maxWidth = 0
        for v in view.subviews {
            let vw = v.frame.origin.x + v.frame.size.width + v.frame.origin.x
            maxWidth = max(maxWidth, Int(vw))
        }
        view.frame.size.width = CGFloat(maxWidth) - 50
    }
}

extension String {
    
    func contains(_ find: String) -> Bool{
        return self.range(of: find) != nil
    }
    
    func containsIgnoreCase(_ find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
}
