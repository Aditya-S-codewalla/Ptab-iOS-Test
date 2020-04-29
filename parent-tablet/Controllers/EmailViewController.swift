//
//  EmailViewController.swift
//  parent-tablet
//
//  Created by Aditya Sinha on 29/04/20.
//  Copyright © 2020 codewalla. All rights reserved.
//

import UIKit
import ContactsUI
import MessageUI

class EmailViewController: UIViewController {
    
    var mailRecipients:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func SelectContacts(_ sender: UIButton) {
        
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (accessGranted, error) in
            if let e = error {
                print(e.localizedDescription)
                return
            }
            if accessGranted {
                let cnPicker = CNContactPickerViewController()
                cnPicker.delegate = self
                cnPicker.predicateForEnablingContact = NSPredicate(format: "emailAddresses.@count > 0")
                self.present(cnPicker, animated: true, completion: nil)
            }
            else {
                print("Access Not Granted")
            }
        }
        
        
    }
    
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(mailRecipients)
            mail.setMessageBody("<p>P-Tab email test</p>", isHTML: true)
            mail.setSubject("P-Tab Test")
            present(mail, animated: true)
        } else {
            // show failure alert
            print("Unable to send messages")
        }
    }
    
    
}

extension EmailViewController: CNContactPickerDelegate {
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        for contact in contacts {
            mailRecipients.append(String(contact.emailAddresses.first?.value ?? ""))
        }
        print(mailRecipients.count)
        picker.dismiss(animated: true) {
            self.sendEmail()
        }
    }
    
}

extension EmailViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let e = error {
            print(e.localizedDescription)
        }
        else {
            print("Finished sending Email")
            controller.dismiss(animated: true) {
                print("Finished dissmissing mail controller")
            }
        }
    }
}
