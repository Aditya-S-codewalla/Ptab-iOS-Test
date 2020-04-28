//
//  ContactsDisplayController.swift
//  parent-tablet
//
//  Created by Aditya Sinha on 28/04/20.
//  Copyright © 2020 codewalla. All rights reserved.
//

import UIKit

class ContactsDisplayController: UIViewController {
    
    @IBOutlet weak var contactsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var contactsList:[ContactStruct] = []
    var filteredContacts:[ContactStruct] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        contactsTableView.dataSource = self
        contactsTableView.delegate = self
        
        searchBar.delegate = self
        filteredContacts = contactsList
    }
    
}

extension ContactsDisplayController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let contactToDisplay = filteredContacts[indexPath.row]
        cell.textLabel?.text = contactToDisplay.name
        cell.detailTextLabel?.text = contactToDisplay.phoneNumber
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SMSViewController.phoneNumber = filteredContacts[indexPath.row].phoneNumber
        navigationController?.popViewController(animated: true)
    }
}

extension ContactsDisplayController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            filteredContacts = contactsList
            contactsTableView.reloadData()
            return
        }
        filteredContacts = contactsList.filter({ (contact) -> Bool in
            contact.name.lowercased().contains(searchText.lowercased())
        })
        contactsTableView.reloadData()
    }
}
