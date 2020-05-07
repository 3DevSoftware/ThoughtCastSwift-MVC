//
//  LoginViewController.swift
//  NeoPenDemo
//
//  Created by Trevor Walker on 1/26/20.
//  Copyright © 2020 Trevor Walker. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - Properties
    let reachability = Reachability()
    var sender: UIPageViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Setting delegates
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        usernameTextField.attributedPlaceholder = NSAttributedString(string: "Enter Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        usernameTextField.textColor = .darkText
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Enter Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        passwordTextField.textColor = .darkText
        //Adding tap gesture to dismiss keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func activateTapped(_ sender: Any) {
        fakelogin()
    }
    
    func fakelogin() {
        UserDefaults.standard.set(true, forKey: "neoPen")
        UserDefaults.standard.set(true, forKey: "isknSlate")
                            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    func login() {
        //Checks if user has internet
        if reachability.checkReachable() {
            //Safely unwraps textFields
            guard let username = usernameTextField.text, let password = passwordTextField.text else {return}
            print("password: " + password)
            //checks if either textField is empty
            if(username.isEmpty || password.isEmpty) {
                
                createAlert(title: "Error", message: "Please enter a Email and a password.")
                
                return
            }
            //Logs user In
            FirebaseFunctions.login(email: username, password: password) { (isValid) in
                //Makes sure they were logged in
                if isValid {
                    //if they were able to login it pulls the user data down
                    FirebaseFunctions.pullUserData(email: username) { (didPull, document) in
                        //checks if the pull passed
                        if didPull {
                            //safely unwraps activated and login ID
                            if let activated = document?.get("isActivated") as? Bool, let loginID = document?.get("loginID") as? String {
                                //makes sure the user's account is activated
                                if activated {
                                    //makes sure the login id's match
                                    if loginID == UserDefaults.standard.value(forKey: "deviceUUID") as? String || loginID == ""{
                                        //Load user devices
                                        let activeDevices = document?.get("activedevices") as! NSDictionary
                                        UserDefaults.standard.set(activeDevices["neoPen"], forKey: "neoPen")
                                        UserDefaults.standard.set(activeDevices["isknSlate"], forKey: "isknSlate")
                                    } else {
                                        self.createAlert(title: "Please logout of other devices", message: "You can only have one device active at a time")
                                    }
                                } else {
                                    self.createAlert(title: "Your Account is no longer Active", message: "Please contact ThoughtCast")
                                }
                            }
                        }
                    }
                    self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                } else {
                    self.createAlert(title: "Error", message: "Email or password were incorrect. Please try again")
                }
            }
        } else {
            createAlert(title: "Network Connection Error", message: "Please check your network connection then try again")
        }
    }
    
    //Creates and presents a generic alert
    func createAlert (title: String, message: String) {
        let dialogMessage = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: "OK", style: .default, handler: {(action) -> Void in })
        dialogMessage.addAction(ok)
        self.present(dialogMessage, animated: true, completion: nil)
        do{
            try Auth.auth().signOut()
        } catch {
            print("Error Logging out")
        }
    }
    
    //called when view tapped
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //Handles the first responder when return is tapped
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case usernameTextField:
            passwordTextField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
            login()
        }
        return true
    }
}
