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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseOptions.defaultOptions()?.deepLinkURLScheme = "com.codewalla.parent-tablet"
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
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("Received url through custom url scheme \(url.absoluteString)")
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            print("dynamic link in custom url scheme:\(dynamicLink.url?.absoluteString ?? "nil")")
            return true
        }
        else {
            return GIDSignIn.sharedInstance().handle(url)
            //return false // comment this when the line above is uncommented
        }
        
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
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

