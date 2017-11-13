//
//  AddTipCell.swift
//  lookaround2
//
//  Created by Angela Yu on 11/12/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit
import AZEmptyState

class AddTipCell: UITableViewCell {
    @IBOutlet weak var addButton: UIButton!
    
    internal func initCell(for numTips: Int) {
        if numTips == 0 {
            setupEmptyState()
        } else {
            setupView()
        }
        
    }
    
    private func setupEmptyState() {
        //init var
        emptyStateView = AZEmptyStateView()
        
        //customize
        emptyStateView.image = #imageLiteral(resourceName: "arrived")
        emptyStateView.message = "Nobody has left a tip about this place yet"
        emptyStateView.buttonText = "Add an Insider Tip"
        emptyStateView.addTarget(self, action: #selector(onAddTip(_:)), for: .touchUpInside)
        
        //add subview
        addButton.removeFromSuperview()
        view.addSubview(emptyStateView)
        
        //add autolayout
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        emptyStateView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6).isActive = true
        emptyStateView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.55).isActive = true
    }
    
    private func setupView() {
        addButton.backgroundColor = UIColor.LABrand.primary
        addButton.titleLabel?.textColor = UIColor.white
        addButton.layer.cornerRadius = 5
        addButton.clipsToBounds = true
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction private func onAddTip(_ sender: Any) {
        let alertVC = UIAlertController(title: "Add a tip", message: nil, preferredStyle: .alert)
        alertVC.addTextField {
            textField in
            textField.placeholder = "Type your tip here"
        }
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            _ in
            if let text =  alertVC.textFields?[0].text {
                self.addTip(text: text)
            }
        }
        alertVC.addAction(saveAction)
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
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
}
