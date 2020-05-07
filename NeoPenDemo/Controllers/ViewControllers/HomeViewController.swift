//
//  HomeViewController.swift
//  NeoPenDemo
//
//  Created by Trevor Walker on 11/25/19.
//  Copyright © 2019 Trevor Walker. All rights reserved.
//

import UIKit
import FirebaseAuth
class HomeViewController: UIViewController, NJPenStatusDelegate, NJPenCommManagerNewPeripheral, NJPenCommParserStartDelegate, NJPenCommParserCommandHandler {
    
    // MARK: - Outlets
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var connectionStatusLabel: UILabel!
    
    // MARK: - Properties
    let penManager = NJPenCommManager.sharedInstance()!
    var connectionStatus: NJPenCommManPenConnectionStatus = .disconnected
    var discoveredPeripherals: NSMutableArray = []
    var macArray: NSMutableArray = []
    var serviceIDArray: NSMutableArray = []
    var timer: Timer?
    var activeNoteID: Int32? = nil
    var activePageNumber: Int32? = nil
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if Auth.auth().currentUser == nil {
            performSegue(withIdentifier: "showOnboarding", sender: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Delegates
        penManager.setPenStatusDelegate(self)
        penManager.setPenCommParserStartDelegate(self)
    }
    
    // MARK: - IBActions
    @IBAction func showDrawingTapped(_ sender: Any) {
        if connectionStatusLabel.text == "Connected to Scribe Pen"{
            performSegue(withIdentifier: "StartDrawing", sender: nil)
        }
    }
    
    @IBAction func zoneModeTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            performSegue(withIdentifier: "showOnboarding", sender: nil)
        } catch {
            print("Failed to logout")
        }
    }
    
    @IBAction func toggleConnectionTapped(_ sender: Any) {
        //toggles connecting to pen, connection label, and connection button based on connection status
        if connectionStatus == .connected{
            if penManager.isPenConnected {
                connectionStatusLabel.text = "Disconnecting from Neo Pen"
                connectionStatusLabel.textColor = .systemBlue
                connectionStatus = .disconnected
                penManager.disConnect()
            } else {
                connectionStatus = .disconnected
                connectionResult(false)
                return
            }
        } else if connectionStatus == .disconnected {
            connectionStatusLabel.text = "Connecting to Scribe Pen"
            connectionStatusLabel.textColor = .systemBlue
            connectToPen()
        }
        connectButton.isEnabled = false
        penManager.setPenState()
    }
    
    // MARK: - BTLE Connection Stuff
    //starts scanner to find devices
    func startScanTimer(duration: Double) {
        timer = Timer(timeInterval: duration, target: self, selector: #selector(self.discoveredPeripheralsAndconnect), userInfo: nil, repeats: false)
        RunLoop.main.add(timer!, forMode: RunLoop.Mode.default)
    }
    //Starts the sequence to connect to a scribe pen
    func connectToPen() {
        penManager.handleNewPeripheral = self
        penManager.btStartForPeripheralsList()
        //discoveredPeripheralsAndconnect()
        startScanTimer(duration: 3.0)
        connectionStatus = .connected
    }
    
    //Called when ever our connection to the Scribe Pen is changed
    @objc func connectionResult(_ success: Bool) {
        if navigationController?.topViewController != self {
            navigationController?.popViewController(animated: true)
            connectionFailedAlert()
            connectionResult(false)
        }
        //reenables our connect button
        connectButton.isEnabled = true
        //updates our connection label and button based on the pens status
        if (success){
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.connectionStatusLabel.text = "Connected to Scribe Pen"
                self.connectionStatusLabel.textColor = .systemGreen
                self.connectButton.setTitle("Disconnect from Scribe Pen", for: .normal)
                print("Pen connection seccess")
            }
        } else {
            if connectionStatus == .connected {
                penManager.disConnect()
                connectionStatusLabel.text = "Looking for Scribe Pen"
                connectionStatusLabel.textColor = .systemOrange
                connectToPen()
            } else {
                connectionStatusLabel.text = "Disconnected from Scribe Pen"
                connectionStatusLabel.textColor = .systemRed
                connectButton.setTitle("Connect to Scribe Pen", for: .normal)
                connectionStatus = .disconnected
                print("Pen has disconnected")
            }
        }
    }
    
    //Connects to Scribe Pen
    @objc func discoveredPeripheralsAndconnect() {
        //invalidates time so we stop searching
        timer?.invalidate()
        // if the count of devices is greater than 0 we check and see if the last one we connected to is available. If it is then we connect to it, if not we connect to the first one we found
        if penManager.discoveredPeripherals.count > 0 {
            connectionStatusLabel.text = "Connecting to Scribe Pen"
            connectionStatusLabel.textColor = .systemBlue
            var serviceUUID: String = ""
            if (penManager.serviceIdArray.count > 0) {
                serviceUUID = "\(penManager.serviceIdArray[0])"
            }
            if (serviceUUID == "19F0" || serviceUUID == "19F1") {
                penManager.isPenSDK2 = true
                print("Pen SDK2.0")
            } else {
                penManager.isPenSDK2 = false
                print("Pen SDK1.0")
            }
            let devices: [CBPeripheral] = penManager.discoveredPeripherals as! [CBPeripheral]
            if let device = UserDefaults.standard.string(forKey: "savedNeoPen"), let index: Int = devices.firstIndex(where: {$0.identifier.uuidString == device}) {
                penManager.connectPeripheral(at: index)
            } else {
                penManager.connectPeripheral(at: 0)
                UserDefaults.standard.set(devices[0].identifier.uuidString, forKey: "savedNeoPen")
            }
        } else {
            startScanTimer(duration: 3.0)
        }
    }
    
    // MARK: - Conforming to Delegates
    func setPenCommNoteIdList() {
        let notebookID: UInt = 625
        let sectionID: UInt = 3
        let ownerID: UInt = 27
        NPPaperManager.sharedInstance()?.reqAdd(usingNote: notebookID, section: sectionID, owner: ownerID)
        penManager.setAllNoteIdList()
    }
    func activeNoteId(forFirstStroke noteId: Int32, pageNum pageNumber: Int32, sectionId section: Int32, ownderId owner: Int32) {
        print()
    }
    func penStatusData(_ data: UnsafeMutablePointer<PenStateStruct>!) {
        print()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "StartDrawing" {
            penManager.setPenStatusDelegate(nil)
        }
    }
    func connectionFailedAlert() {
        let alert = UIAlertController(title: "Lost Connection", message: "Lost Connection to Scribe Pen", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel) { (_) in }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}
