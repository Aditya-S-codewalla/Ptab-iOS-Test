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
    
    var contactsList:[ContactStruct] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        contactsTableView.dataSource = self
        contactsTableView.delegate = self
    }
    
}

extension ContactsDisplayController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let contactToDisplay = contactsList[indexPath.row]
        cell.textLabel?.text = contactToDisplay.name
        cell.detailTextLabel?.text = contactToDisplay.phoneNumber
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SMSViewController.phoneNumber = contactsList[indexPath.row].phoneNumber
        navigationController?.popViewController(animated: true)
    }
}
