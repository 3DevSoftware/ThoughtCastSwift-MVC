//
//  ColorPicker.swift
//  ZoneMode
//
//  Created by Fady Yecob on 08/01/2020.
//  Copyright © 2020 ThoughtCast. All rights reserved.
//

import UIKit

class ColorPicker: UIView {

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }()
    
    var items = [ColorPicker.Item]() {
        didSet {
            updateStackView()
        }
    }
    
    var itemSelected: ((ColorPicker.Item) -> Void)?
    var selectedIndex = 0
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    private func updateStackView() {
        stackView.removeAllArrangedSubviews()
        
        for (index, item) in items.enumerated() {
            let button = ColorPickerButton()
            button.backgroundColor = item.color
            button.setTitle((item.title), for: .normal)
            button.isSelected = index == selectedIndex ? true : false
            
            stackView.addArrangedSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(colorSelected(sender:)), for: .touchUpInside)
            button.addConstraint(
                NSLayoutConstraint(
                    item: button,
                    attribute: .height,
                    relatedBy: .equal,
                    toItem: button,
                    attribute: .width,
                    multiplier: 1,
                    constant: 0
                )
            )
        }
    }
    
    @objc private func colorSelected(sender: ColorPickerButton) {
        guard let index = stackView.arrangedSubviews.firstIndex(of: sender) else {
            return
        }
        (stackView.arrangedSubviews[selectedIndex] as? UIButton)?.isSelected = false
        sender.isSelected = true
        selectedIndex = stackView.arrangedSubviews.firstIndex(of: sender) ?? 0
        
        let item = items[index]
        itemSelected?(item)
    }
}
