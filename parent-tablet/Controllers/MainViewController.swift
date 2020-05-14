//
//  MainViewController.swift
//  parent-tablet
//
//  Created by Aditya Sinha on 21/04/20.
//  Copyright © 2020 codewalla. All rights reserved.
//

import UIKit
import Firebase

class MainViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    var userName:String?
    var userEmail:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.hidesBackButton = true
        DisplayUserDetails()
    }
    
    @IBAction func LogoutButtonPressed(_ sender: UIBarButtonItem) {
        
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
    }
    
    @IBAction func inviteFamilyMemberPressed(_ sender: UIButton) {
        createDynamicLink()
    }
    
    func DisplayUserDetails() {
        nameLabel.text = userName
        emailLabel.text = userEmail
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
        
        shareLink.iOSParameters?.appStoreID = "962194608" //using google photos as temporary id
        shareLink.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
        shareLink.socialMetaTagParameters?.title = "Parent-Tablet"
        shareLink.socialMetaTagParameters?.imageURL = URL(string: "https://i.picsum.photos/id/866/200/300.jpg")
        shareLink.socialMetaTagParameters?.descriptionText = "Connect with your family"
        
        guard let longURL = shareLink.url else { return }
        print(longURL.absoluteString)
        
        shareLink.shorten { (url, warnings, error) in
            if let e = error {
                print(e.localizedDescription)
                return
            }
            if let warnings = warnings {
                for warning in warnings {
                    print("Firebase dynamic link warning:\(warning)")
                }
            }
            guard let url = url else { return }
            self.showShareSheet(url: url)
        }
        //self.showShareSheet(url: longURL)
        
    }
    
    func showShareSheet(url: URL) {
        let promoText = "Invite Elder to Parent tablet"
        let activityVC = UIActivityViewController(activityItems: [promoText,url], applicationActivities: nil)
        present(activityVC, animated: true) {
            print("Dynamic link sharing success")
        }
    }
    
}
