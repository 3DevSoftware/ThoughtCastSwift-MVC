//
//  ColorPickerButton.swift
//  ZoneMode
//
//  Created by Fady Yecob on 08/01/2020.
//  Copyright © 2020 ThoughtCast. All rights reserved.
//

import UIKit

class ColorPickerButton: UIButton {

    override var isSelected: Bool {
        didSet {
            layer.borderColor = isSelected ? UIColor.white.cgColor : UIColor.clear.cgColor
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        layer.borderWidth = 2
        titleLabel?.textAlignment = .center
        titleLabel?.font = .systemFont(ofSize: 15)
        tintColor = .white
    }

}
