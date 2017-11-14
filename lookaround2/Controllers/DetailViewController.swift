//
//  DetailViewController.swift
//  lookaround2
//
//  Created by Angela Yu on 11/12/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit

@objc protocol DetailViewControllerDelegate {
    @objc optional func getDelDirections(for place: Place)
    @objc optional func hasExpanded()
    @objc optional func hasCollapsed()
}

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Stored Properties
    
    internal var delegate: DetailViewControllerDelegate?
    internal var place: Place!
    internal var tips = [Tip]()
    internal var expanded: Bool = false

    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        print("load start")
        super.viewDidLoad()
        setupViews()
        fetchTips()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        let cellNib = UINib(nibName: "AddTipCell", bundle: Bundle.main)
        tableView.register(cellNib, forCellReuseIdentifier: "AddTipCell")
        print("load finish")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("will appear")
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("did appear")
        super.viewDidAppear(animated)
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
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapTable(sender:)))
        
        // Attach it to a view of your choice. If it's a UIImageView, remember to enable user interaction
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGestureRecognizer)
    }

    // MARK: - Tip Functions
    private func addTip(text: String) {
        Tip.CreateTip(for: place.id, text: text) {
            tip, error in
            if let tip = tip {
                DatabaseRequests.shared.addTip(tip: tip)
                self.tips.append(tip)
                let indexPath = IndexPath(row: self.tips.count - 1, section: 2)
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: [indexPath], with: .automatic)
                self.tableView.endUpdates()
            } else {
                _ = SweetAlert().showAlert("Error", subTitle: error!.localizedDescription, style: .error)
            }
        }
    }
    
    private func fetchTips() {
        DatabaseRequests.shared.fetchTips(for: place.id, success: { tipsArray in
            if let tips = tipsArray {
                self.tips = tips
                self.tableView.reloadData()
            }
            return
        }, failure: {
            error  in
            if let error = error {
                _ = SweetAlert().showAlert("Error", subTitle: error.localizedDescription, style: .error)
            }
        })
    }
    
    // MARK: - UITableView Setup
    
    @objc func didTapTable(sender: UITapGestureRecognizer) {
        expanded = !expanded
        if expanded {
            print("starting delegate")
            delegate?.hasExpanded?()
        } else {
            print("starting delegate")
            delegate?.hasCollapsed?()
        }
        print("expanded = \(expanded)")
        self.view.layoutIfNeeded()
        self.view.layoutSubviews()
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if expanded {
            print("5 sections")
            return 5
        } else {
            print("1 section")
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 1
        case 3:
            return tips.count
        case 4:
            return 1
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return nil
        case 1:
            return nil
        case 2:
            return nil
        case 3:
            if tips.count > 0 {
                return "Tips"
            } else {
                return nil
            }
        case 4:
            return nil
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let placeNameCell = tableView.dequeueReusableCell(withIdentifier: "PlaceNameCell", for: indexPath) as! PlaceNameCell
            placeNameCell.delegate = self
            placeNameCell.place = place
            placeNameCell.setupViews()
            return placeNameCell
        case 1:
            let placeExpandedCell = tableView.dequeueReusableCell(withIdentifier: "PlaceExpandedCell", for: indexPath) as! PlaceExpandedCell
            //let placeExpandedCell = PlaceExpandedCell(style: .default, reuseIdentifier: "PlaceExpandedCell")
            placeExpandedCell.place = place
            placeExpandedCell.setupViews()
            return placeExpandedCell
        case 2:
            let addTipCell = tableView.dequeueReusableCell(withIdentifier: "AddTipCell", for: indexPath) as! AddTipCell
            addTipCell.initCell(for: tips.count)
            return addTipCell
        case 3:
            let tipsCell = tableView.dequeueReusableCell(withIdentifier: "PlaceTipsCell", for: indexPath) as! PlaceTipsCell
            tipsCell.tip = tips[indexPath.row]
            return tipsCell
        case 4:
            let placeLinkCell = tableView.dequeueReusableCell(withIdentifier: "PlaceLinkCell", for: indexPath) as! PlaceLinkCell
            
            if let idNum = place.id {
                if let link = place.link {
                    placeLinkCell.link = link
                }
                placeLinkCell.idNum = idNum
            }
            placeLinkCell.setupViews()
            return placeLinkCell
        default:
            print("hit default switch")
            return UITableViewCell()
        }
    }
}

extension DetailViewController: PlaceNameCellDelegate {
    func getDirections(for place: Place) {
        delegate?.getDelDirections?(for: place)
    }
}

extension DetailViewController: AddTipCellDelegate {    
    func presentVC(viewController: UIAlertController) {
        present(viewController, animated: true, completion: nil)
    }
    
    func refreshTips() {
        tableView.reloadSections([3], with: UITableViewRowAnimation.automatic)
    }

}
