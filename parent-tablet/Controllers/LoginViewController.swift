//
//  LoginViewController.swift
//  parent-tablet
//
//  Created by Aditya Sinha on 21/04/20.
//  Copyright © 2020 codewalla. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import AuthenticationServices
import CryptoKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var appleLoginProviderStackView: UIStackView!
    
    var fullName:String?
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    fileprivate var currentNonce: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        appDelegate.delegate = self
        
        setupProviderLoginView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //performExistingAccountSetupFlows()
        startSigninWithAppleFlow()
    }
    
    @IBAction func GIDSignInButtonPressed(_ sender: GIDSignInButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func LoginButtonPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
                if let e = error {
                    print(e.localizedDescription)
                }
                else {
                    self.performSegue(withIdentifier: K.loginSegue, sender: self)
                }
            }
        }
    }
    
    /// - Tag: add_appleid_button
    func setupProviderLoginView() {
        let authorizationButton = ASAuthorizationAppleIDButton()
        authorizationButton.addTarget(self, action: #selector(startSigninWithAppleFlow), for: .touchUpInside)
        self.appleLoginProviderStackView.addArrangedSubview(authorizationButton)
    }
    
    // - Tag: perform_appleid_password_request
    /// Prompts the user if an existing iCloud Keychain credential or Apple ID credential is found.
    /*func performExistingAccountSetupFlows() {
        // Prepare requests for both Apple ID and password providers.
        let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                        ASAuthorizationPasswordProvider().createRequest()]
        
        // Create an authorization controller with the given requests.
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }*/
    
    /// - Tag: perform_appleid_request
    @objc
    func startSigninWithAppleFlow() {
        
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
}

extension LoginViewController: GIDSignInSuccessDelegate {
    
    func NavigateAfterGSignIn() {
        self.performSegue(withIdentifier: K.loginSegue, sender: self)
    }
    
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
          guard let nonce = currentNonce else {
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
          }
          guard let appleIDToken = appleIDCredential.identityToken else {
            print("Unable to fetch identity token")
            return
          }
          guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
            return
          }
          // Initialize a Firebase credential.
          let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                    idToken: idTokenString,
                                                    rawNonce: nonce)
          // Sign in with Firebase.
          Auth.auth().signIn(with: credential) { (authResult, error) in
            if let e = error {
              // Error. If error.code == .MissingOrInvalidNonce, make sure
              // you're sending the SHA256-hashed nonce as a hex string with
              // your request to Apple.
              print(e.localizedDescription)
              return
            }
            // User is signed in to Firebase with Apple.
            print("Apple Sign in success")
            self.fullName = PersonNameComponentsFormatter.localizedString(from: appleIDCredential.fullName!, style: .default, options: .init())
            self.performSegue(withIdentifier: K.loginSegue, sender: self)
          }
        }
        
    }
    
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
}

extension LoginViewController {
    
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: Array<Character> =
          Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }
    
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
      }.joined()

      return hashString
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.loginSegue {
            let destinationVC = segue.destination as! MainViewController
            let currentUser = Auth.auth().currentUser
            //destinationVC.userName = currentUser?.displayName
            destinationVC.userName = fullName
            destinationVC.userEmail = currentUser?.email
            destinationVC.userPhone = currentUser?.phoneNumber
        }
    }
    
}
