//
//  ZoneModeCanvas.swift
//  NeoPenDemo
//
//  Created by Trevor Walker on 1/21/20.
//  Copyright © 2020 Trevor Walker. All rights reserved.
//

import Foundation

class ZoneModeCanvas: UIView {
    private var lines = [Line]()
    
    var drawingEnabled = true
    var selectedStrokeColor = UIColor.gray
    var selectedLineWidth: CGFloat = 30
    
    weak var delegate: ZoneModeCanvasDelegate?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    
        for line in lines {
            line.color.setStroke()
            line.path.stroke()
        }
    }
    
    /// Removes all graphics from the canvas.
    @objc func clear() {
        lines = []
        setNeedsDisplay()
    }
    
    private func contains(_ point: CGPoint) -> UIColor? {
        let line = lines.last {
            #warning("TODO: use points cgpoints if needed or remove")
//            let points = $0.path.cgPath.points()
            
            let bezierPath = $0.path
            
            let cgPath = bezierPath.cgPath.copy(
                strokingWithWidth: bezierPath.lineWidth,
                lineCap: bezierPath.lineCapStyle,
                lineJoin: .round,
                miterLimit: 0
            )
            
            return cgPath.contains(point)
        }
        
        return line?.color
    }
    
    // MARK: - UIResponder
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let point = touches.first?.location(in: self) else {
            return
        }
        
        if !drawingEnabled {
            let detectedColor = contains(point)
            delegate?.detectedArea(color: detectedColor)
            return
        }
        
        let path = UIBezierPath()
        path.lineCapStyle = .butt
        path.lineWidth = selectedLineWidth
        path.move(to: point)
        
        let line = Line(path: path, color: selectedStrokeColor)
        lines.append(line)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard
            drawingEnabled,
            let point = touches.first?.location(in: self),
            let lastLine = lines.popLast() else {
                return
        }
        
        lastLine.path.addLine(to: point)
        lines.append(lastLine)
        
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
    }
}

protocol ZoneModeCanvasDelegate: AnyObject {
    func detectedArea(color: UIColor?)
}
