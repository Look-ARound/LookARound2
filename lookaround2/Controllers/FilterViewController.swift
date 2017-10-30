//
//  FilterViewController.swift
//  LookARound
//
//  Created by Siji Rachel Tom on 10/14/17.
//  Updated by John Nguyen on 10/24/17 for My Lists / Public Lists
//  Copyright © 2017 LookARound. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import CoreLocation

protocol FilterViewControllerDelegate : NSObjectProtocol {
    func filterViewController(_filterViewController: FilterViewController, didSelectCategories categories: [FilterCategory])
    func filterViewController(_filterViewController: FilterViewController, didSelectList list:List)
    func filterViewController(_filterViewController: FilterViewController, noSelection categories: [FilterCategory])
}

enum SectionType : Int {
    case filters = 0
    case login
    case discoverLists
    case searchResults
}

class FilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var filterTableView: UITableView!
    
    @IBOutlet var currentUserNameLabel: UILabel!
    @IBOutlet var currentUserImageView: UIImageView!
    @IBOutlet var loginButtonView: UIView!
    weak var delegate : FilterViewControllerDelegate?
    var places: [Place]!
    var coordinates: CLLocationCoordinate2D!
    var myListItem: ListItem!
    var publicListItem: ListItem!
    var searchResultsItem: SearchResultsItem!
    
    var sectionItems: [SectionItem] = []
  
    override func viewDidLoad() {
        super.viewDidLoad()

        myListItem = ListItem(title: "My Lists")
        publicListItem = ListItem(title: "Public Lists")
        searchResultsItem = SearchResultsItem(title: "Search Results" )
        searchResultsItem.places = self.places
        
        sectionItems.append( CategoryItem(title: "Categories"))
        sectionItems.append( myListItem )
        sectionItems.append( publicListItem )
        sectionItems.append( searchResultsItem )
        //sectionItems.append( LoginItem(title: "Login"))
        
        // Do any additional setup after loading the view.
        filterTableView.delegate = self
        filterTableView.dataSource = self        
        
        filterTableView.estimatedRowHeight = 100
        filterTableView.rowHeight = UITableViewAutomaticDimension
        
        filterTableView.tableFooterView = UIView()
        
        // Initialize facebook login button
        let loginButton = LoginButton(frame: nil, readPermissions: [ .publicProfile, .userFriends ])
        loginButton.delegate = self
        loginButtonView.addSubview(loginButton)
        updateLoginInfo()
        
        fetchPlacesLists()
        
        
        // TODO: Can we directly go to search results VC from here without going through the login page? I (Angela)
        // tried instantiating a SearchResultsViewController directly but it's not that easy.
//        let resultsButton = UIBarButtonItem(title: "List Results", style: .plain, target: self, action: #selector(onResultsButton))
//        navigationItem.rightBarButtonItem = resultsButton


    }

    func fetchPlacesLists() {
        DatabaseRequests.shared.fetchPublicLists(success: { lists in
            guard let lists = lists else {
                return
            }
            self.publicListItem.lists = lists
            self.filterTableView.reloadData()
        }) { error in
            print(error)
        }
        
        DatabaseRequests.shared.fetchCurrentUserLists(success: { lists in
            guard let lists = lists else {
                return
            }
            self.myListItem.lists = lists
            self.filterTableView.reloadData()
        }) { error in
            print(error)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionItems.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionItems[section].rowCount
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  header = tableView.dequeueReusableCell(withIdentifier: "HeaderCell") as! HeaderCell
        
        header.titleLabel.text = sectionItems[section].title
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell
        let sectionType = sectionItems[indexPath.section].type
        
        switch sectionType {
        case .filters:
            cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)
            (cell as! FilterCell).filterNameLabel.text = FilterCategoryDisplayString(category: FilterCategory(rawValue: indexPath.row)!)
        case .login:
            cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
            (cell as! DefaultCell).titleLabel.text = "Login to Facebook"
        case .discoverLists:
            let listItem = sectionItems[indexPath.section] as! ListItem
            cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)
            (cell as! FilterCell).filterNameLabel.text  = listItem.lists[indexPath.row].name
            cell.accessoryType = .none

        case .searchResults:
            cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultsCell", for: indexPath)
            (cell as! SearchResultsCell).place = places[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let sectionType = sectionItems[ indexPath.section ].type
        switch sectionType {
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
            let listItem = sectionItems[indexPath.section] as! ListItem
            let selectedList = listItem.lists[indexPath.row]
            self.delegate?.filterViewController(_filterViewController: self,
                                                didSelectList: selectedList)
            dismiss(animated: true, completion: nil)
        case .searchResults:
            print( "search results selected" )
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
        self.delegate?.filterViewController(_filterViewController: self, noSelection: [])
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

extension FilterViewController : LoginButtonDelegate {
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        updateLoginInfo()
        fetchPlacesLists()
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        updateLoginInfo()
    }
    
    func updateLoginInfo() {
        if AccessToken.current != nil {
            ProfileRequest().fetchCurrentUser(success: { (user : User) in
                self.currentUserNameLabel.text = user.name
                self.currentUserNameLabel.sizeToFit()
                if let url = URL(string: user.profileImageURL!) {
                    self.currentUserImageView.setImageWith(url)
                }
            }) { (error: Error) in
                print("Custom Graph Request Failed: \(error)")
            }
            currentUserImageView.isHidden = false
            currentUserNameLabel.isHidden = false
        }
        else {
            currentUserImageView.isHidden = true
            currentUserNameLabel.isHidden = true
        }
    }
}

class SectionItem {
    var title: String!
    var type: SectionType {
        return SectionType.discoverLists
    }
    var rowCount: Int { return 0 }
    
    init( title: String ) {
        self.title = title
    }
}

class CategoryItem: SectionItem {
    override var type: SectionType {
        return SectionType.filters
    }
    override var rowCount: Int {
        return FilterCategory.Categories_Total_Count.rawValue
    }
}

class LoginItem: SectionItem {
    override var type: SectionType {
        return SectionType.login
    }
    override var rowCount: Int {
        return 1
    }
}

class ListItem: SectionItem {
    var lists: [List]!
    
    override var type: SectionType {
        return SectionType.discoverLists
    }
    
    override var rowCount: Int {
        guard let lists = lists else {
            return 0
        }
        return lists.count
    }
}

class SearchResultsItem: SectionItem {
    var places: [Place]!
    
    override var type: SectionType {
        return SectionType.searchResults
    }
    
    override var rowCount: Int {
        return places.count
    }
}

