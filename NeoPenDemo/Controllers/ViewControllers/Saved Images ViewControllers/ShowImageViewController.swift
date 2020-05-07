//
//  ShowImageViewController.swift
//  NeoPenDemo
//
//  Created by Trevor Walker on 12/27/19.
//  Copyright © 2019 Trevor Walker. All rights reserved.
//

import UIKit
import MessageUI

class ShowImageViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    // MARK: - Properties
    var currentIndex: Int!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        update()
        //Sets up swipe gestures
        imageView.isUserInteractionEnabled = true
        
        let swipeLeftGesture=UISwipeGestureRecognizer(target: self, action: #selector(SwipeDetected(gestureRecognizer:)))
        imageView.isUserInteractionEnabled=true
        swipeLeftGesture.direction = UISwipeGestureRecognizer.Direction.left
        imageView.addGestureRecognizer(swipeLeftGesture)
        
        let swipeRightGesture=UISwipeGestureRecognizer(target: self, action: #selector(SwipeDetected(gestureRecognizer:)))
        swipeRightGesture.direction = UISwipeGestureRecognizer.Direction.right
        imageView.addGestureRecognizer(swipeRightGesture)
        
        let swipeDownGesture=UISwipeGestureRecognizer(target: self, action: #selector(SwipeDetected(gestureRecognizer:)))
        swipeRightGesture.direction = UISwipeGestureRecognizer.Direction.down
        imageView.addGestureRecognizer(swipeDownGesture)
    }
    
    @objc func SwipeDetected(gestureRecognizer: UISwipeGestureRecognizer) {
        if gestureRecognizer.direction == .right {
            if currentIndex >= 1{
                currentIndex -= 1
            }
        } else if gestureRecognizer.direction == .left {
            if currentIndex<DrawingController.shared.drawings.count-1{
                currentIndex+=1
            }
        } else if gestureRecognizer.direction == .down {
            self.dismiss(animated: true, completion: nil)
        }
        update()
    }
    // MARK: - Update View
    func update() {
        self.dateLabel.text = DrawingController.shared.drawings[currentIndex].date?.timeText()
        self.timeLabel.text = DrawingController.shared.drawings[currentIndex].date?.dateText()
        imageView.image = UIImage(data: DrawingController.shared.drawings[currentIndex].image!)
    }
    
    // MARK: - IBActions
    @IBAction func buttontapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        let activityController = UIActivityViewController(activityItems: [imageView.image!], applicationActivities: nil)
        
        activityController.completionWithItemsHandler = { (nil, completed, _, error) in
            if completed {
                print("completed")
            } else {
                print("cancled")
            }
        }
        present(activityController, animated: true) {
            print("presented")
        }
    }
    
    @IBAction func deleteTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this Drawing?", preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        let delete = UIAlertAction(title: "Delete", style: .destructive) { (_) in
            DrawingController.shared.deleteDrawing(drawings: [DrawingController.shared.drawings[self.currentIndex!]])
            if self.currentIndex >= 1{
                self.currentIndex -= 1
            }
            if self.currentIndex<DrawingController.shared.drawings.count-1{
                self.currentIndex+=1
            }
            self.update()
        }
        alert.addAction(cancel)
        alert.addAction(delete)
        self.present(alert, animated: true, completion: nil)
    }
}
