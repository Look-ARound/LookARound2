//
//  FilterViewController.swift
//  LookARound
//
//  Created by Siji Rachel Tom on 10/14/17.
//  Copyright © 2017 LookARound. All rights reserved.
//

import UIKit
import FacebookCore
import CoreLocation

protocol FilterViewControllerDelegate : NSObjectProtocol {
    func filterViewController(_filterViewController: FilterViewController, didSelectCategories categories: [FilterCategory])
    func filterViewController(_filterViewController: FilterViewController, didSelectList list:List)
}

class FilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    enum SectionType : Int {
        case filters = 0
        case login
        case discoverLists
    }
    
    @IBOutlet weak var filterTableView: UITableView!
    weak var delegate : FilterViewControllerDelegate?
    var coordinates: CLLocationCoordinate2D!
    var lists = [List]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        filterTableView.delegate = self
        filterTableView.dataSource = self        
        
        filterTableView.estimatedRowHeight = 100
        filterTableView.rowHeight = UITableViewAutomaticDimension
        
        filterTableView.tableFooterView = UIView()
        
        DatabaseRequests.shared.fetchAllLists { (lists : [List]) in
            self.lists = lists
            self.filterTableView.reloadData()
        }
        
        // TODO: Can we directly go to search results VC from here without going through the login page? I (Angela)
        // tried instantiating a SearchResultsViewController directly but it's not that easy.
//        let resultsButton = UIBarButtonItem(title: "List Results", style: .plain, target: self, action: #selector(onResultsButton))
//        navigationItem.rightBarButtonItem = resultsButton

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // 1st section: filters
        // 2nd section: log in rows, if the user isn't already logged in
        
        /* Final behavior: Use this to hide login button if user is already logged in
        // var numSections = 1
        
        if AccessToken.current == nil {
            // User is not logged in
            numSections = 2
        }
         */
        
        // Forcing to always show 2 for debugging since we want to be able to access the login screen and logout button
        let numSections = 3
        
        return numSections
    }
    
    func numRows(forSection section: SectionType) -> Int {
        switch section {
        case .filters:
            return FilterCategory.Categories_Total_Count.rawValue
        case .login:
            return 1
        case .discoverLists:
            return lists.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numRows(forSection: SectionType(rawValue: section)!)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell
        let section = SectionType(rawValue: indexPath.section)!
        
        switch section {
        case .filters:
            cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)
            (cell as! FilterCell).filterNameLabel.text = FilterCategoryDisplayString(category: FilterCategory(rawValue: indexPath.row)!)
        case .login:
            cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
            (cell as! DefaultCell).titleLabel.text = "Login to Facebook"
        case .discoverLists:
            cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
            (cell as! DefaultCell).titleLabel.text  = lists[indexPath.row].name
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = SectionType(rawValue: indexPath.section)!
        switch section {
        case .filters:
            let category = FilterCategory(rawValue: indexPath.row)!
            self.delegate?.filterViewController(_filterViewController: self,
                                                didSelectCategories: [category])
            dismiss(animated: true, completion: nil)
        case .login:
            // Push login screen
            showLoginScreen()
        case .discoverLists:
            // Selected list
            let selectedList = lists[indexPath.row]
            self.delegate?.filterViewController(_filterViewController: self,
                                                didSelectList: selectedList)
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    func showLoginScreen() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        loginViewController.coordinates = coordinates
        self.navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    @objc func onResultsButton() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let resultsViewController = storyboard.instantiateViewController(withIdentifier: "SearchResultsViewController") as! SearchResultsViewController
        self.navigationController?.pushViewController(resultsViewController, animated: true)
    }
    
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
