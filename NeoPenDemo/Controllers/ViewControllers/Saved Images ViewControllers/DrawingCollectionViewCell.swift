//
//  DrawingCollectionViewCell.swift
//  NeoPenDemo
//
//  Created by Trevor Walker on 12/27/19.
//  Copyright © 2019 Trevor Walker. All rights reserved.
//

import UIKit

class DrawingCollectionViewCell: UICollectionViewCell {
    // MARK: - Outlets
    @IBOutlet weak var drawingImage: UIImageView!
    @IBOutlet weak var isSelectedImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    // MARK: - Properties
    var drawingIsSelected: Bool = false
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        isSelectedImage.isHidden = true
        isSelectedImage.image =  #imageLiteral(resourceName: "not_selected")
    }
    override func prepareForReuse() {
        isSelectedImage.image =  #imageLiteral(resourceName: "not_selected")
        super.isSelected = false
    }
    override var isSelected: Bool {
        didSet {
            isSelectedImage.image =  self.isSelected ? #imageLiteral(resourceName: "selected"):#imageLiteral(resourceName: "not_selected")
        }
    }
    // MARK: - Data Populator
    func setData(drawing: Drawing) {
        
        guard let imageData = drawing.image else {return}
        var image: UIImage = UIImage(data: imageData)!
        
        if(image.size.width > image.size.height)
        {
            image = image.rotate(radians: .pi/2)!
        }
        self.drawingImage.image = image
        
        if drawing.date == nil
        {
            drawing.date = Date()
        }
        self.dateLabel.text = drawing.date!.dateText()
        self.timeLabel.text = drawing.date!.timeText()
    }
}
