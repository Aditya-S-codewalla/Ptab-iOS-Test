//
//  SMSViewController.swift
//  parent-tablet
//
//  Created by Aditya Sinha on 28/04/20.
//  Copyright © 2020 codewalla. All rights reserved.
//

import UIKit
import MessageUI
import Contacts

class SMSViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    
    @IBOutlet weak var phoneTextField: UITextField!
    
    var contacts:[ContactStruct] = []
    static var phoneNumber = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        contacts = []
        phoneTextField.text = SMSViewController.phoneNumber
    }
    
    @IBAction func ContactsSelected(_ sender: UIButton) {
        FetchContacts()
        
    }
    
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true) {
            print("Done sending SMS")
        }
    }
    
    @IBAction func SendSMSPressed(_ sender: UIButton) {
        
        if !MFMessageComposeViewController.canSendText() {
            print("SMS services are not available")
        }
        else if MFMessageComposeViewController.canSendText() {
            let controller = MFMessageComposeViewController()
            controller.body = "P-Tab test"
            controller.recipients = [phoneTextField.text!]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    
    func FetchContacts() {
        print("Attempting to fetch contacts...")
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (accessGranted, error) in
            if let e = error {
                print(e.localizedDescription)
                return
            }
            if accessGranted {
                print("Access Granted")
                
                let keys = [CNContactGivenNameKey,CNContactPhoneNumbersKey] as [CNKeyDescriptor]
                let request = CNContactFetchRequest(keysToFetch: keys)
                
                do {
                    try store.enumerateContacts(with: request) { (contact, stoppingPoint) in
                        let name = contact.givenName
                        let phoneNumber = contact.phoneNumbers.first?.value.stringValue ?? ""
                        let contact = ContactStruct(name: name, phoneNumber: phoneNumber)
                        self.contacts.append(contact)
                    }
                }
                catch let error {
                    print(error.localizedDescription)
                }
                //print(self.contacts.count)
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: K.ContactsSegue, sender: self)
                }
                
                
            }
            else {
                print("Access Denied")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.ContactsSegue {
            let destinationVC = segue.destination as! ContactsDisplayController
            destinationVC.contactsList = contacts
        }
    }
    

}
