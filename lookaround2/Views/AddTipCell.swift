//
//  AddTipCell.swift
//  lookaround2
//
//  Created by Angela Yu on 11/12/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit

class AddTipCell: UITableViewCell {
    
    internal func initCell(for numTips: Int) {
        if numTips == 0 {
        //empty state
        } else {
        // not empty state
        }
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
