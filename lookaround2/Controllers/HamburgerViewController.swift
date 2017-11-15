//
//  HamburgerViewController.swift
//  lookaround2
//
//  Created by Angela Yu on 10/31/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit

class HamburgerViewController: UIViewController {
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentLeadingConstraint: NSLayoutConstraint!
    
    var filterViewController: UIViewController! {
        didSet {
            view.layoutIfNeeded()
            filterView.addSubview(filterViewController.view)
        }
    }
    
    var contentViewController: UIViewController! {
        didSet {
            view.layoutIfNeeded()
            contentView.addSubview(contentViewController.view)
        }
    }
    
    var detailNavController: UIViewController!
    var detailViewController: PlaceDetailViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func revealFilters() {
        UIView.animate(withDuration: 0.3, animations: {
            self.contentLeadingConstraint.constant = self.view.frame.size.width - 50
            self.view.layoutIfNeeded()
        })
    }
    
    func hideFilters() {
        print("hiding")
        UIView.animate(withDuration: 0.3, animations: {
            self.contentLeadingConstraint.constant = 0
            self.view.layoutIfNeeded()
        })
    }

}

extension HamburgerViewController: AugmentedViewControllerDelegate {
    func revealFilters(_augmentedViewController: AugmentedViewController) {
        revealFilters()
    }
    
    func hideFilters(_augmentedViewController: AugmentedViewController) {
        hideFilters()
    }
    
    /* func showDetail(place: Place) {
        detailViewController.place = place
        present(detailNavController, animated: true, completion: nil)
    } */ 
}
