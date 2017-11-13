//
//  AddTipCell.swift
//  lookaround2
//
//  Created by Angela Yu on 11/12/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit
import AZEmptyState

@objc protocol AddTipCellDelegate {
    func presentVC(viewController: UIAlertController)
    func refreshTips()
}

class AddTipCell: UITableViewCell {
    @IBOutlet weak var addButton: UIButton!
    
    internal var place: Place!
    internal var delegate: AddTipCellDelegate?
    
    internal func initCell(for numTips: Int) {
        if numTips == 0 {
            setupEmptyState()
        } else {
            setupView()
        }
        
    }
    
    private func setupEmptyState() {
        //init var
        guard let superV = self.superview else {
            print ("no superview")
            return
        }
        let emptyFrame = CGRect(x: 0, y: 0, width: superV.frame.size.width, height: 300)
        let emptyStateView = AZEmptyStateView(frame: emptyFrame)
        
        //customize
        emptyStateView.image = #imageLiteral(resourceName: "arrived")
        emptyStateView.message = "Nobody has left a tip about this place yet"
        emptyStateView.buttonText = "Add an Insider Tip"
        emptyStateView.addTarget(self, action: #selector(onAddTip(_:)), for: .touchUpInside)
        
        //add subview
        addButton.removeFromSuperview()
        self.contentView.addSubview(emptyStateView)
        
        //add autolayout
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        emptyStateView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        emptyStateView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.6).isActive = true
        emptyStateView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.55).isActive = true
    }
    
    private func setupView() {
        addButton.backgroundColor = UIColor.LABrand.accent
        addButton.layer.cornerRadius = 5
        addButton.clipsToBounds = true
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        print("add awake")
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
        delegate?.presentVC(viewController: alertVC)
    }
    
    private func addTip(text: String) {
        Tip.CreateTip(for: place.id, text: text) {
            tip, error in
            if let tip = tip {
                DatabaseRequests.shared.addTip(tip: tip)
                self.delegate?.refreshTips()
            } else {
                _ = SweetAlert().showAlert("Error", subTitle: error!.localizedDescription, style: .error)
            }
        }
    }
}
