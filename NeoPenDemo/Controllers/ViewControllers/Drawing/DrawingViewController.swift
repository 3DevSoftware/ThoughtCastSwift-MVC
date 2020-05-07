//
//  ViewController.swift
//  NeoPenDemo
//
//  Created by Trevor Walker on 11/29/19.
//  Copyright © 2019 Trevor Walker. All rights reserved.
//

import UIKit
import CoreData
import Photos

class DrawingViewController: UIViewController{
    // MARK: - Outlets
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var homeButton: UIButton!
    
    // MARK: - Properties
    let penManager = NJPenCommManager.sharedInstance()!
    let canvas = Canvas(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 0, height: 0)))
    let hideView = UIImageView()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Delegates
        penManager.setPenCommParserStartDelegate(nil)
        penManager.setPenCommParserStrokeHandler(canvas)
        penManager.requestNewPageNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if canvas.drawnOn {
            canvas.saveImage()
        }
        canvas.removeFromSuperview()
    }
    deinit {
        print("View deinit")
    }
    //Sets up or canvas on the view programatically
    private func setUpViews() {
        //Adding views to main view
        view.addSubview(canvas)
        view.addSubview(hideView)
        //enables auto layout
        canvas.translatesAutoresizingMaskIntoConstraints = false
        hideView.translatesAutoresizingMaskIntoConstraints = false
        //canvas View
        canvas.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        canvas.topAnchor.constraint(equalTo: homeButton.bottomAnchor, constant: 5).isActive = true
        canvas.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -10).isActive = true
        canvas.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -5).isActive = true
        canvas.backgroundColor = .black
        
        //hide View
        hideView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        hideView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        hideView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        hideView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        hideView.backgroundColor = .black
        hideView.isUserInteractionEnabled = false
        hideView.isHidden = !UserDefaults.standard.bool(forKey: userDefaultKeys.hideOverlay)
        
        //Hide View Image
        guard let data = UserDefaults.standard.data(forKey: userDefaultKeys.camoImage), let image = UIImage(data: data) else {return}
        hideView.image = image
        hideView.contentMode = .scaleAspectFit
    }
    
    // MARK: - IBActions
    @IBAction func homeButtonPressed(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: userDefaultKeys.autoSaveHome) {
            canvas.saveImage()
        }
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        canvas.saveImage()
    }
    
    @IBAction func clearButtonPressed(_ sender: Any) {
        canvas.clear()
        canvas.setNeedsDisplay()
    }
    
    // MARK: - Handle Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
            self.hideView.alpha = 0.3
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.hideView.alpha = 1.0
    }
}

