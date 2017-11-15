//
//  DebugViewController.swift
//  lookaround2
//
//  Created by John Nguyen on 11/1/17.
//  Copyright © 2017 LookARound. All rights reserved.
//

import UIKit

class DebugViewController: UIViewController {

    @IBOutlet var autoGenLikesSwitch: UISwitch!
    @IBOutlet weak var moreSwitch: UISwitch!
    @IBOutlet var useFacebookLocationSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        autoGenLikesSwitch.isOn = PlaceSearch.autoGenLikes
        
        useFacebookLocationSwitch.isOn = AugmentedViewController.useFacebookLocation
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onAutoGenLikesSwitch(_ sender: Any) {
        PlaceSearch.autoGenLikes = autoGenLikesSwitch.isOn
    }
    
    @IBAction func onMorePlaces(_ sender: Any) {
        if moreSwitch.isOn {
            // do nothing
        } else {
            // do nothing
        }
    }
    
    @IBAction func onUseFacebookLocationSwitch(_ sender: Any) {
        AugmentedViewController.useFacebookLocation = useFacebookLocationSwitch.isOn
    }
    
    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onDone(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
