//
//  SettingsTableViewController.swift
//  NeoPenDemo
//
//  Created by Trevor Walker on 1/31/20.
//  Copyright © 2020 Trevor Walker. All rights reserved.
//

import UIKit
import FirebaseAuth
import MessageUI

class SettingsTableViewController: UITableViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var InvertColorsSwitch: UISwitch!
    @IBOutlet weak var autoSaveHomeSwitch: UISwitch!
    @IBOutlet weak var hideOverlaySwitch: UISwitch!
    @IBOutlet weak var loggedInAsLabel: UIButton!
    @IBOutlet weak var camoImageImageView: UIImageView!
    @IBOutlet weak var imagePickerCell: UIView!
    
    // MARK: - Properties
    let userDefaults = UserDefaults.standard
    let imagePicker = UIImagePickerController()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserPresets()
        tableView.rowHeight = 44.0
        guard let currentUser = Auth.auth().currentUser, let email = currentUser.email else {return}
        loggedInAsLabel.setTitle("Logged in As: \(email)", for: .normal)
        //Setting up gestures
        imagePickerCell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickCamoImage)))
    }
    
    func loadUserPresets() {
        self.navigationController?.navigationBar.isHidden = false
        InvertColorsSwitch.isOn = userDefaults.bool(forKey: userDefaultKeys.invertColors)
        autoSaveHomeSwitch.isOn = userDefaults.bool(forKey: userDefaultKeys.autoSaveHome)
        hideOverlaySwitch.isOn = userDefaults.bool(forKey: userDefaultKeys.hideOverlay)
        guard let data = userDefaults.data(forKey: userDefaultKeys.camoImage), let image = UIImage(data: data) else {return}
        camoImageImageView.image = image
    }
    
    // MARK: - Actions
    @IBAction func invertColorsToggled(_ sender: UISwitch) {
        userDefaults.set(sender.isOn, forKey: userDefaultKeys.invertColors)
    }
    @IBAction func autoSaveHomeToggled(_ sender: UISwitch) {
        userDefaults.set(sender.isOn, forKey: userDefaultKeys.autoSaveHome)
    }
    @IBAction func hideOverlayTapped(_ sender: UISwitch) {
        userDefaults.set(sender.isOn, forKey: userDefaultKeys.hideOverlay)
    }
    @IBAction func LoggedInTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Logout", message: "Would you like to Logout? This will deactivate your current Device.", preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: "Logout", style: .destructive, handler: {(action) -> Void in
            do {
                try Auth.auth().signOut()
                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                self.view.window?.rootViewController?.viewDidLoad()
                
            } catch {
                let alert = UIAlertController(title: "Something went wrong!", message: "Please check your connection and try again later", preferredStyle: .alert)
                
                // Create OK button with action handler
                let ok = UIAlertAction(title: "Ok", style: .destructive, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
        })
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func doneTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Image Picker
extension SettingsTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func pickCamoImage() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            print("Button capture")
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true) {
            guard let image = info[.originalImage] as? UIImage else {return}
            self.camoImageImageView.image = image
            self.userDefaults.set(image.pngData(), forKey: userDefaultKeys.camoImage)
        }
    }
}

// MARK: - Mail Composer Extention
extension SettingsTableViewController: MFMailComposeViewControllerDelegate {
    
    @IBAction func contactSupportTapped(_ sender: Any) {
        let mail = MFMailComposeViewController()
        mail.delegate = self
        if MFMailComposeViewController.canSendMail() {
            mail.mailComposeDelegate = self
            mail.setToRecipients(["support@thoughtcastapp.com"])
            
            present(mail, animated: true)
        } else {
            // show failure alert
            let alert = UIAlertController(title: "Failed to Contact Support", message: "Please be sure to have the mail app downloaded and set up on your device", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(okButton)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

// MARK: - Alerts
extension SettingsTableViewController {
    func alert(title: String, details: String) {
        
    }
}
