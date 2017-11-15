//
//  DetailViewController.swift
//  lookaround2
//
//  Created by Angela Yu on 11/12/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit

@objc protocol DetailViewControllerDelegate {
    func closeDetails()
    @objc optional func getDelDirections(for place: Place)
    @objc optional func hasExpanded()
    @objc optional func hasCollapsed()
    @objc optional func addTip(show: UIAlertController)
    @objc optional func addPlaceList(show: AddPlaceViewController)
}

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var closeButton: UIButton!
    
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
        tableView.separatorStyle = .none
        
        let mainNib = UINib(nibName: "PlaceMainCell", bundle: Bundle.main)
        tableView.register(mainNib, forCellReuseIdentifier: "PlaceMainCell")
        let cellNib = UINib(nibName: "AddTipCell", bundle: Bundle.main)
        tableView.register(cellNib, forCellReuseIdentifier: "AddTipCell")
        
        print("load finish")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("will appear")
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        //tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("did appear")
        super.viewDidAppear(animated)
        let iPath = IndexPath(row: 0, section: 0)
        tableView.reloadRows(at: [iPath], with: .automatic)
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
        closeButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi/4)
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
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if expanded {
            print("4 sections")
            return 4
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
            return tips.count + 1
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
            return "Tips"
        case 3:
            return nil
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let placeMainCell = tableView.dequeueReusableCell(withIdentifier: "PlaceMainCell", for: indexPath) as! PlaceMainCell
            placeMainCell.place = place
            placeMainCell.delegate = self
            placeMainCell.setupViews()
            return placeMainCell
        case 1:
            let placeExpandedCell = tableView.dequeueReusableCell(withIdentifier: "PlaceExpandedCell", for: indexPath) as! PlaceExpandedCell
            placeExpandedCell.place = place
            placeExpandedCell.setupViews()
            return placeExpandedCell
        case 2:
            switch indexPath.row {
            case 0:
                let addTipCell = tableView.dequeueReusableCell(withIdentifier: "AddTipCell", for: indexPath) as! AddTipCell
                addTipCell.place = place
                addTipCell.delegate = self
                addTipCell.initCell(for: tips.count)
                return addTipCell
            case _ where indexPath.row > 0:
                let realRow = indexPath.row - 1
                let tipsCell = tableView.dequeueReusableCell(withIdentifier: "PlaceTipsCell", for: indexPath) as! PlaceTipsCell
                tipsCell.tip = tips[realRow]
                return tipsCell
            default:
                return UITableViewCell()
            }
            
//            let placeNameCell = tableView.dequeueReusableCell(withIdentifier: "PlaceNameCell", for: indexPath) as! PlaceNameCell
//            placeNameCell.delegate = self
//            placeNameCell.place = place
//            placeNameCell.setupViews()
//            //placeNameCell.layoutSubviews()
//            let nameFrame = placeNameCell.frame
//            let tableFrame = tableView.frame
//            let viewFrame = view.frame
//            print("namecell frame x: \(nameFrame.minX), y: \(nameFrame.minY), width: \(nameFrame.width), height: \(nameFrame.height)")
//            print("tableview frame x: \(tableFrame.minX), y: \(tableFrame.minY), width: \(tableFrame.width), height: \(tableFrame.height)")
//            print("VCview frame x: \(viewFrame.minX), y: \(viewFrame.minY), width: \(viewFrame.width), height: \(viewFrame.height)")
//            return placeNameCell
        case 3:
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
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 400
        default:
            return 100
        }
    }
    
    // MARK: - Actions
    @IBAction func onCloseButton(_ sender: Any) {
        delegate?.closeDetails()
    }
}

//extension DetailViewController: PlaceNameCellDelegate {
//    func getDirections(for place: Place) {
//        delegate?.getDelDirections?(for: place)
//    }
//}

extension DetailViewController: PlaceMainCellDelegate {
    func addPlace(on viewController: AddPlaceViewController) {
        delegate?.addPlaceList?(show: viewController)
    }
    
    func getDirections(for place: Place) {
        delegate?.getDelDirections?(for: place)
    }
    
    
}

extension DetailViewController: AddTipCellDelegate {    
    func presentVC(viewController: UIAlertController) {
        delegate?.addTip?(show: viewController)
    }
    
    func refreshTips() {
        fetchTips()
    }

}
