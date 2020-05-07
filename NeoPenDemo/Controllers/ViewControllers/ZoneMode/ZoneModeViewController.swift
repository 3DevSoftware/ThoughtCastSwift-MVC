//
//  ZoneModeViewController.swift
//  NeoPenDemo
//
//  Created by Trevor Walker on 1/21/20.
//  Copyright © 2020 Trevor Walker. All rights reserved.
//

import UIKit

class ZoneModeViewController: UIViewController {
    

    // MARK: - Outlets
    let colorPicker = ColorPicker()
    let canvas = ZoneModeCanvas()
    
    private let colors: [ColorPicker.Item] = [
            .init(color: .gray, title: "X"),
            .init(color: .red, title: "1"),
            .init(color: .orange, title: "2"),
            .init(color: .yellow, title: "3"),
            .init(color: .green, title: "4"),
            .init(color: .cyan, title: "5"),
            .init(color: .blue, title: "6"),
            .init(color: .magenta, title: "7"),
            .init(color: .purple, title: "8")
        ]
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            setupColorPicker()
            setupToolBar()
        }
        
        // MARK: - Setup
        
        private func setupToolBar() {
            navigationController?.setToolbarHidden(false, animated: true)
            navigationController?.setNavigationBarHidden(true, animated: false)
            navigationController?.toolbar.barStyle = .black
            
            let barButtonItems: [UIBarButtonItem] = [
                .init(
                    title: NSLocalizedString("Save", comment: "Save"),
                    style: .plain,
                    target: self,
                    action: #selector(save)
                ),
                .init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                .init(
                    title: NSLocalizedString("Load", comment: "Load"),
                    style: .plain,
                    target: self,
                    action: #selector(load)
                ),
                .init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                .init(
                    title: NSLocalizedString("Clear", comment: "Clear"),
                    style: .plain,
                    target: canvas,
                    action: #selector(ZoneModeCanvas.clear)
                ),
                .init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                .init(
                    title: NSLocalizedString("Detection Mode", comment: "Detection Mode"),
                    style: .plain,
                    target: self,
                    action: #selector(toggleDrawingEnabled(_:))
                )
            ]
            
            setToolbarItems(barButtonItems, animated: true)
        }
        
        private func setupColorPicker() {
        
            colorPicker.items = colors
            colorPicker.itemSelected = colorSelected(item:)
        }
        
        // MARK: - Actions
        
        @objc private func toggleDrawingEnabled(_ sender: UIBarButtonItem) {
            if canvas.drawingEnabled {
                let color = UIImage.imageWithColor(color: UIColor.blue.withAlphaComponent(0.5))
                sender.setBackgroundImage(color, for: .normal, barMetrics: .default)
            } else {
                let color = UIImage.imageWithColor(color: .clear)
                sender.setBackgroundImage(color, for: .normal, barMetrics: .default)
            }
            
            canvas.drawingEnabled.toggle()
        }
        
        @objc private func save() {
            let alert = UIAlertController(title: "Not yet implemented", message: nil, preferredStyle: .alert)
            alert.addAction(.init(title: "Ok", style: .default))
            present(alert, animated: true)
        }
        
        @objc private func load() {
            let alert = UIAlertController(title: "Not yet implemented", message: nil, preferredStyle: .alert)
            alert.addAction(.init(title: "Ok", style: .default))
            present(alert, animated: true)
        }
        
        private func colorSelected(item: ColorPicker.Item) {
            canvas.selectedStrokeColor = item.color
        }
    }
