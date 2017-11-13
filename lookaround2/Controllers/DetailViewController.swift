//
//  DetailViewController.swift
//  lookaround2
//
//  Created by Angela Yu on 11/12/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    // MARK: - Stored Properties
    
    internal var place: Place!
    internal var tips = [Tip]()

    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        print("load start")
        super.viewDidLoad()
        setupViews()
        fetchTips()
        print("load finish")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("will appear")
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Setup Views
    
    private func setupViews() {
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
    }

}
