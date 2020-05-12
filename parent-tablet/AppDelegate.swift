//
//  AppDelegate.swift
//  parent-tablet
//
//  Created by Aditya Sinha on 21/04/20.
//  Copyright © 2020 codewalla. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

protocol GIDSignInSuccessDelegate {
    func NavigateAfterGSignIn() -> Void
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    var delegate:GIDSignInSuccessDelegate?
    var window:UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        let db = Firestore.firestore()
        print(db)
        return true
    }
    
    //MARK: - GIDSignInDelegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let e = error {
            print(e.localizedDescription)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        // ...
        Auth.auth().signIn(with: credential) { (authDataResult, error) in
            if let e = error {
                print(e.localizedDescription)
            }
            else {
                print("Sign in google success")
                self.delegate?.NavigateAfterGSignIn()
            }
        }
    }
    
    //MARK: - Dynamic Links with Universal links and Custom URL schemes
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let incomingURL = userActivity.webpageURL, userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            print("Incoming url is \(incomingURL)")
            let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { (dynamicLink, error) in
                guard error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                if let dynamicLink = dynamicLink {
                    self.handleIncomingDynamicLink(dynamicLink)
                }
            }
            return linkHandled
        }
        return false
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("Received url through custom url scheme \(url.absoluteString)")
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            self.handleIncomingDynamicLink(dynamicLink)
            return true
        }
        else {
            return GIDSignIn.sharedInstance().handle(url)
        }
        
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
      if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
        // Handle the deep link. For example, show the deep-linked content or
        // apply a promotional offer to the user's account.
        // ...
        print("Old way of processing deep link")
        self.handleIncomingDynamicLink(dynamicLink)
        return true
      }
      return false
    }
    
    func handleIncomingDynamicLink(_ dynamicLink: DynamicLink) {
        guard let url = dynamicLink.url else {
            print("Dynamic link object has no URL")
            return
        }
        print("Incoming link parameter is\(url.absoluteString)")
        guard (dynamicLink.matchType == .unique || dynamicLink.matchType == .default) else {
            print("Not a strong enough match type to continue")
            return
        }
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false), let queryItems = components.queryItems else {
            return
        }
        if components.path == "/uinvalue" {
            if let uinQueryItem = queryItems.first(where: {$0.name == "uin"}) {
                guard let uinValue = uinQueryItem.value else { return }
                let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                guard let newDetailVC = storyboard.instantiateViewController(identifier: "WelcomeViewController2") as? WelcomeViewController else {
                    return
                }
                newDetailVC.uinLabel.text = uinValue
                
                (self.window?.rootViewController as? UINavigationController)?.pushViewController(newDetailVC, animated: true)
            }
        }
    }
    
    // MARK: - UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}

