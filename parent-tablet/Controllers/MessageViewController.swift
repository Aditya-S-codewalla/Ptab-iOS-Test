//
//  MessageViewController.swift
//  parent-tablet
//
//  Created by Aditya Sinha on 05/05/20.
//  Copyright © 2020 codewalla. All rights reserved.
//

import UIKit
import ContactsUI
import MessageUI
import Firebase

class MessageViewController: UIViewController {
    
    var messageRecipients:[String] = []
    var dynamicLinkURLString:String = "placeholder for dynamic link"

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func sendMessageButtono(_ sender: UIButton) {
        selectContacts()
    }
    
    
    func selectContacts() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (accessGranted, error) in
            if let e = error {
                print(e.localizedDescription)
                return
            }
            if accessGranted {
                
                DispatchQueue.main.async {
                    let cnPicker = CNContactPickerViewController()
                    cnPicker.delegate = self
                    cnPicker.predicateForEnablingContact = NSPredicate(format: "phoneNumbers.@count > 0")
                    self.present(cnPicker, animated: true, completion: nil)
                }
                
            }
            else {
                print("Access Not Granted")
            }
        }
    }
    
    func sendMessage() {
        if MFMessageComposeViewController.canSendText() {
            let messsageController = MFMessageComposeViewController()
            messsageController.messageComposeDelegate = self
            createDynamicLink()
            messsageController.body = dynamicLinkURLString
            messsageController.recipients = messageRecipients
            self.present(messsageController, animated: true, completion: nil)
        }
        else {
            print("Unable to send messages from this device")
        }
    }
    
    func createDynamicLink() {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.example.com"
        components.path = "/uinvalue"
        
        let uinQueryItem = URLQueryItem(name: "uin", value: "232123")
        components.queryItems = [uinQueryItem]
        
        guard let linkParameter = components.url else { return }
        
        guard let shareLink = DynamicLinkComponents.init(link: linkParameter, domainURIPrefix: "https://ptabtesting.page.link") else {
            print("Could not create FDL component")
            return
        }
        
        if let myBundleId = Bundle.main.bundleIdentifier {
            shareLink.iOSParameters = DynamicLinkIOSParameters(bundleID: myBundleId)
        }
        shareLink.iOSParameters?.appStoreID = "962194608"
        
        guard let longURL = shareLink.url else { return }
        
        dynamicLinkURLString = longURL.absoluteString
    }
    
}

extension MessageViewController: CNContactPickerDelegate {
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        for contact in contacts {
            messageRecipients.append(contact.phoneNumbers.first?.value.stringValue ?? "")
        }
        picker.dismiss(animated: true) {
            self.sendMessage()
        }
    }
}

extension MessageViewController: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true) {
            print("Finished sending SMS")
        }
    }
    
}
