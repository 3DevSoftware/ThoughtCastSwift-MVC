//
//  SavedDrawingsViewController.swift
//  NeoPenDemo
//
//  Created by Trevor Walker on 12/27/19.
//  Copyright © 2019 Trevor Walker. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

class SavedDrawingsViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    // MARK: - Outlets
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var trashButton: UIButton!
    @IBOutlet weak var savedDrawingCollectionView: UICollectionView!
    @IBOutlet weak var selectButton: UIButton!
    
    // MARK: - Properties
    var isSelecting: Bool = false {
        didSet {
            updateTrashButton()
        }
    }
    var selectedItems: [IndexPath: (isSelected: Bool, drawing: Drawing)] = [:] {
        didSet {
            shareButton.isEnabled = self.selectedItems.count != 0
            shareButton.alpha = self.selectedItems.count != 0 ? 1.0:0.5
            updateTrashButton()
        }
    }
    var lastSelectedIndex: Int!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        savedDrawingCollectionView.delegate = self
        savedDrawingCollectionView.dataSource = self
        
        //Makes sure that there are three drawing in a row
//        if let flowLayout = savedDrawingCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
//            flowLayout.minimumInteritemSpacing = 5
//            let width = (savedDrawingCollectionView.frame.width / 3) - 15
//            flowLayout.itemSize = CGSize(width: width, height: width * 1.62)
//            savedDrawingCollectionView.collectionViewLayout = flowLayout
//        }
        selectedItems = [:]
        updateSelectButton()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        savedDrawingCollectionView.reloadData()
    }
    
    func updateSelectButton() {
        selectButton.isEnabled = DrawingController.shared.drawings.count != 0
        selectButton.alpha = DrawingController.shared.drawings.count != 0 ? 1.0:0.5
        if DrawingController.shared.drawings.count == 0 { isSelecting = false }
        selectButton.setTitle(isSelecting ? "Deselect":"Select", for: .normal)
    }
    func updateTrashButton() {
        if self.isSelecting {
            trashButton.isEnabled = self.selectedItems.count != 0
            trashButton.alpha = self.selectedItems.count != 0 ? 1.0:0.5
        } else {
            trashButton.isEnabled = true
            trashButton.alpha = 1.0
        }
    }
    // MARK: - IBActions
    @IBAction func selectTapped(_ sender: Any) {
        isSelecting = !isSelecting
        savedDrawingCollectionView.allowsMultipleSelection = isSelecting
        savedDrawingCollectionView.reloadData()
        selectButton.setTitle(isSelecting ? "Deselect":"Select", for: .normal)
    }
    
    @IBAction func tappedDelete(_ sender: Any) {
        if isSelecting {
            deleteSelectedAlert()
        } else {
            deleteAllAlert()
        }
    }
    
    @IBAction func tappedShare(_ sender: Any) {
        displayShareSheet(shareContent: self.selectedItems.values.map({$0.drawing.image!}))
    }
    
    @IBAction func homeTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Collection View Stuff
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        DrawingController.shared.drawings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "drawingCell", for: indexPath) as? DrawingCollectionViewCell else {return UICollectionViewCell()}
        cell.setData(drawing: DrawingController.shared.drawings[indexPath.row])
        cell.isSelectedImage.isHidden = !isSelecting
        cell.drawingIsSelected = selectedItems[indexPath]?.drawing != nil
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isSelecting {
            selectedItems[indexPath] = (isSelected: true, drawing: DrawingController.shared.drawings[indexPath.row])
        } else {
            lastSelectedIndex = indexPath.row
            collectionView.deselectItem(at: indexPath, animated: false)
            performSegue(withIdentifier: "showDrawing", sender: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        selectedItems.removeValue(forKey: indexPath)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.bounds.width/3.0) - 10
        let cellHeight = cellWidth * 1.62

        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDrawing" {
            guard let destination = segue.destination as? ShowImageViewController else {return}
            destination.currentIndex = lastSelectedIndex
        }
    }
}

// MARK: - Alert Controller
extension SavedDrawingsViewController {
    func deleteAllAlert() {
        let alert = UIAlertController(title: "Delete All", message: "Are you sure you want to delete all saved drawings?", preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        let delete = UIAlertAction(title: "Delete", style: .destructive) { (_) in
            DrawingController.shared.deleteDrawing(drawings: DrawingController.shared.drawings)
            self.selectedItems.removeAll()
            self.isSelecting = false
            self.savedDrawingCollectionView.allowsMultipleSelection = self.isSelecting
            self.savedDrawingCollectionView.reloadData()
            self.savedDrawingCollectionView.deleteItems(at: self.savedDrawingCollectionView.indexPathsForVisibleItems)
            self.updateSelectButton()
        }
        alert.addAction(cancel)
        alert.addAction(delete)
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteSelectedAlert() {
        let alert = UIAlertController(title: "Delete Selected", message: "Are you sure you want to delete all selected drawings?", preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        let delete = UIAlertAction(title: "Delete", style: .destructive) { (_) in
            var deleteNeededIndexPaths: [IndexPath] = []
            for (key, value) in self.selectedItems {
                if value.isSelected {
                    print(value)
                    deleteNeededIndexPaths.append(key)
                }
            }
            DrawingController.shared.deleteDrawing(drawings: self.selectedItems.values.map({$0.drawing}))
            self.savedDrawingCollectionView.deleteItems(at: deleteNeededIndexPaths)
            self.selectedItems.removeAll()
            self.updateSelectButton()
        }
        alert.addAction(cancel)
        alert.addAction(delete)
        self.present(alert, animated: true, completion: nil)
    }
    
    func displayShareSheet(shareContent: [Data]) {
        let images: [UIImage] = self.selectedItems.values.map({UIImage(data: $0.drawing.image!)!})
        let activityController = UIActivityViewController(activityItems: images, applicationActivities: nil)
        
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
}
