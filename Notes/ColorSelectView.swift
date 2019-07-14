//
//  ColorSelectView.swift
//  Notes
//
//  Created by Sergey on 15/07/2019.
//  Copyright © 2019 Sergey Akentev. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

@IBDesignable
class UIColorSelectView: UIView {
    
    var hitHandler: (() -> Void)?
    
    @IBInspectable var colorSelectType: Int = 1 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var color: UIColor = UIColor.white {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var customColorSelected: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var checked: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        if colorSelectType == 1 || customColorSelected {
            context.setFillColor(self.color.cgColor)
            context.fill(self.bounds)
        } else if colorSelectType == 2 {
            let pickedImage = foregroundImage(Int(self.bounds.maxX - self.bounds.minX), Int(self.bounds.maxY - self.bounds.minY))
            pickedImage.draw(at: CGPoint(x: self.bounds.minX, y: self.bounds.minY))
        }
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(CGFloat(1))
        context.stroke(self.bounds)
        if checked {
            let rect = CGRect(
                x: self.bounds.minX + (self.bounds.maxX - self.bounds.minX) / 2 + 4,
                y: self.bounds.minY + 4,
                width: (self.bounds.maxX - self.bounds.minX) / 2 - 8,
                height: (self.bounds.maxY - self.bounds.minY) / 2 - 8
            )
            context.addEllipse(in: rect)
            context.move(to: CGPoint(x: rect.minX + (rect.maxX - rect.minX) / 4, y: rect.minY + (rect.maxY - rect.minY) / 2))
            context.addLine(to: CGPoint(x: rect.minX + (rect.maxX - rect.minX) / 2, y: rect.minY + (rect.maxY - rect.minY) * 3 / 4))
            context.addLine(to: CGPoint(x: rect.minX + (rect.maxX - rect.minX) * 3 / 4, y: rect.minY + (rect.maxY - rect.minY) / 4))
        }
        context.strokePath()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        hitHandler?()
    }
    
}

