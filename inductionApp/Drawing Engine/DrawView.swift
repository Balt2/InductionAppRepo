//
//  DrawView.swift
//  InductionApp
//
//  Created by Ben Altschuler on 4/22/20.
//  Copyright © 2020 Josh Breite. All rights reserved.
//

import Foundation
import UIKit
import UIKit.UIGestureRecognizerSubclass
class DrawView: UIView, UIGestureRecognizerDelegate{
    
    var drawingLayer = UIBezierPath()
    let path = CGMutablePath()
    
    var context: CGContext?
    
    
    var fingerStrokeRecognizer: StrokeGestureRecognizer!
    var pencilStrokeRecognizer: StrokeGestureRecognizer!
    
    var currentStrokeIndex: Int = 0
    var page: TestPage!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        super.setNeedsDisplay()
        layer.drawsAsynchronously = true
        self.clipsToBounds = true
        self.isMultipleTouchEnabled = false
        
        self.fingerStrokeRecognizer = setupStrokeGestureRecognizer(isForPencil: false)
        self.pencilStrokeRecognizer = setupStrokeGestureRecognizer(isForPencil: true)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func setupStrokeGestureRecognizer(isForPencil: Bool) -> StrokeGestureRecognizer {
        let recognizer = StrokeGestureRecognizer(target: self, action: #selector(strokeUpdated(_:)))
        recognizer.delegate = self
        recognizer.cancelsTouchesInView = false
        self.addGestureRecognizer(recognizer)
        recognizer.coordinateSpaceView = self
        recognizer.isForPencil = isForPencil
        return recognizer
    }
    
    @objc
    func strokeUpdated(_ strokeGesture: StrokeGestureRecognizer?) {
        debugPrint("UPDATING STROKE For Test Page")
        //                if strokeGesture === pencilStrokeRecognizer {
        //                    tableViewController.lastSeenPencilInteraction = Date()
        //                }
        //
        
        var stroke: Stroke?
        if strokeGesture?.state != .cancelled {
            stroke = strokeGesture?.stroke
            if strokeGesture?.state == .began ||
                (strokeGesture?.state == .ended && page.drawHelper.strokeCollection?.activeStroke == nil) {
                page.drawHelper.strokeCollection?.activeStroke = stroke
            }
        } else {
            page.drawHelper.strokeCollection?.activeStroke = nil
        }
        
        if let stroke = stroke {
            if strokeGesture?.state == .ended {
                if strokeGesture === pencilStrokeRecognizer {
                    // Make sure we get the final stroke update if needed.
                    stroke.receivedAllNeededUpdatesBlock = { [weak self] in
                        self?.page.drawHelper.receivedAllUpdatesForStroke(stroke)
                    }
                }
                page.drawHelper.strokeCollection?.takeActiveStroke()
            }
        }
        page.drawHelper.strokeCollection = page.drawHelper.strokeCollection
        setNeedsDisplay()
        
    }
    
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("TOUCH ENDED TEST PAGE:")
        setNeedsDisplay()
        
        
    }
    
    
    override func draw(_ rect: CGRect) {
        debugPrint("DRAWING The Test Page")
        page?.drawHelper.beginDraw(rect: rect) //Draws all the strokes
        
    }
    
}
