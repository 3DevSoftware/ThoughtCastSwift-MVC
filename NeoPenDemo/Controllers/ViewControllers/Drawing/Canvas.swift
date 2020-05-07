//
//  Canvas.swift
//  NeoPenDemo
//
//  Created by Trevor Walker on 12/7/19.
//  Copyright © 2019 Trevor Walker. All rights reserved.
//

import UIKit

class Canvas: UIView {
    // MARK: - Properties
    var lines = [[CGPoint]]()
    var inputScale: CGFloat = 0
    var minX: CGFloat?
    var maxX: CGFloat = 0
    var minY: CGFloat?
    var maxY: CGFloat = 0
    var strokeColor: CGColor = UIColor.white.cgColor
    var firstPoint = true
    let penManager = NJPenCommManager.sharedInstance()!
    var drawnOn: Bool = false
    let batteryLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(batteryLabel)
        batteryLabel.translatesAutoresizingMaskIntoConstraints = false
        //batteryy Label
        batteryLabel.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        batteryLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        batteryLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        batteryLabel.font = batteryLabel.font.withSize(20)
        batteryLabel.textColor = .white
        penManager.getPenBattLevelAndMemoryUsedSize { (battery, memory) in
            self.batteryLabel.text = "Battery Left: \(battery)"
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Draws View
    override func draw(_ rect: CGRect) {
        // Drawing code
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else {return}
        
        //Lines
        context.setStrokeColor(strokeColor)
        context.setLineWidth(0.9)
        context.setLineCap(.butt)
        
        lines.forEach { (line) in
            for (i, p) in line.enumerated() {
                if i == 0 {
                    context.move(to: CGPoint(x: (p.x - (minX ?? 0)) * inputScale, y: (p.y - (minY ?? 0)) * inputScale))
                } else {
                    context.addLine(to: CGPoint(x: (p.x - (minX ?? 0)) * inputScale, y: (p.y - (minY ?? 0)) * inputScale))
                }
                print(CGPoint(x: p.x * inputScale, y: p.y * inputScale))
            }
        }
        print("Input scale: \(inputScale)")
        context.strokePath()
    }
    
    // MARK: - Handles Touches
    func touchBegan() {
        lines.append([CGPoint]())
    }
    
    func touchMoved(point: CGPoint) {
        if (minX ?? point.x + 1) > point.x || maxX < point.x || (minY ?? point.y + 1) > point.y || maxY < point.y {
            findScale(point: point)
        }
        guard var lastLine = lines.popLast() else {return}
        lastLine.append(point)
        lines.append(lastLine)
        setNeedsDisplay()
    }
    
    // MARK: - Scale Caculator
    func findScale(point: CGPoint) {
        minX = minX ?? point.x < point.x ? minX:point.x
        maxX = maxX > point.x ? maxX:point.x
        minY = minY ?? point.y < point.y ? minY:point.y
        maxY = maxY > point.y ? maxY:point.y
        
        let drawingView: CGSize = CGSize(width: maxX - (minX ?? 0), height: maxY - (minY ?? 0))
        let widthRatio = self.bounds.width / drawingView.width
        let heightRatio = (self.bounds.height) / (drawingView.height)
        inputScale = min(widthRatio, heightRatio)
    }
    
    func clear() {
        lines = [[]]
        minX = nil
        minY = nil
        maxX = 0
        maxY = 0
        inputScale = 0
        drawnOn = false
        setNeedsDisplay()
    }
}

extension Canvas: NJPenCommParserStrokeHandler {
    
    func processStroke(_ stroke: [AnyHashable : Any]!) {
        var startNode = false
        let type: String = stroke["type"] as! String
        
        if type == "stroke" {
            if firstPoint {
                startNode = true
                firstPoint = false
            }
            
            let node: NJNode = stroke["node"] as! NJNode
            let x: CGFloat = CGFloat(node.x)
            let y: CGFloat = CGFloat(node.y)
            
            if startNode == false {
                self.touchMoved(point: CGPoint(x: x, y: y))
                drawnOn = true
            } else {
                self.touchBegan()
                startNode = false
            }
        }
        else if type == "updown" {
            let status: String = stroke["status"] as! String
            
            if status == "down" {
                startNode = true
            } else {
                firstPoint = true
            }
        }
    }
    
    func activeNoteId(_ noteId: Int32, pageNum pageNumber: Int32, sectionId section: Int32, ownderId owner: Int32) {
        return
    }
    
    func notifyPageChanging() {
        if drawnOn {
            saveImage()
        }
    }
    func setPenColor() -> UInt32 {
        return UInt32(7)
    }
    
    func saveImage() {
        //Creates image in black and white
        let drawing = self
        drawing.batteryLabel.isHidden = true
        if UserDefaults.standard.bool(forKey: userDefaultKeys.invertColors) {
            drawing.backgroundColor = .white
            drawing.strokeColor = UIColor.black.cgColor
            drawing.setNeedsDisplay()
        }
        //saves drawing to core data
        DrawingController.shared.createDrawing(date: Date(), image: drawing.asImage())
        //redraws canvas
        clear()
        backgroundColor = .black
        strokeColor = UIColor.white.cgColor
        setNeedsDisplay()
        batteryLabel.isHidden = false
        drawnOn = false
    }
}

extension Canvas: NJPenStatusDelegate {
    func penStatusData(_ data: UnsafeMutablePointer<PenStateStruct>!) {
        penManager.setPenState()
    }
}
