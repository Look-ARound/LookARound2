//
//  DirectionsButton.swift
//  lookaround2
//
//  Created by Angela Yu on 10/26/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit

class DirectionsButton: UIButton {
    
    var params: Dictionary<String, Any>
    
    override init(frame: CGRect) {
        self.params = [:]
        super.init(frame: frame)
        self.setImage(#imageLiteral(resourceName: "walking"), for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.params = [:]
        super.init(coder: aDecoder)
        self.setImage(#imageLiteral(resourceName: "walking"), for: .normal)
    }
}
