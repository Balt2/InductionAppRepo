//
//  DrawOnView.swift
//  InductionApp
//
//  Created by Ben Altschuler on 4/22/20.
//  Copyright © 2020 Josh Breite. All rights reserved.
//

import Foundation
import UIKit
import UIKit.UIGestureRecognizerSubclass

class DrawOnView {
    
    init(view: UIView) {
        self.view = view
        let dirtyRectView = { () -> UIView in
            let newView = UIView(frame: CGRect(x: -10, y: -10, width: 0, height: 0))
            newView.layer.borderColor = UIColor.red.cgColor
            newView.layer.borderWidth = 0.5
            newView.isUserInteractionEnabled = false
            newView.isHidden = true
            view.addSubview(newView)
            return newView
        }
        dirtyRectViews = [dirtyRectView(), dirtyRectView()]
    }
    
    init(){ //context: CGContext
        let dirtyRectView = { () -> UIView in
            let newView = UIView(frame: CGRect(x: -10, y: -10, width: 0, height: 0))
            newView.layer.borderColor = UIColor.red.cgColor
            newView.layer.borderWidth = 0.5
            newView.isUserInteractionEnabled = false
            newView.isHidden = true
            //view.addSubview(newView)
            return newView
        }
        dirtyRectViews = [dirtyRectView(), dirtyRectView()]
        //self.cgContext = context
    }
    var cgContext: CGContext?
    var currentStrokeIndex: Int = 0
    var view: UIView?
    //var strokeCollection: StrokeCollection = StrokeCollection()
    

    var displayOptions = StrokeViewDisplayOptions.ink { //Part of Class
        didSet {
            if strokeCollection != nil {
                view?.setNeedsDisplay()
            }
        }
    }
    
    var strokeCollection: StrokeCollection? {
        didSet {
            if oldValue !== strokeCollection {
                view?.setNeedsDisplay()
            }
            if let lastStroke = strokeCollection?.strokes.last {
                

                setNeedsDisplay(for: lastStroke)
            }
            strokeToDraw = strokeCollection?.activeStroke
        }
    }
    
    var strokeToDraw: Stroke? {
        didSet {
            if oldValue !== strokeToDraw && oldValue != nil {
                view?.setNeedsDisplay()
                
            } else {
                if let stroke = strokeToDraw {
                    setNeedsDisplay(for: stroke)
                    
                }
            }
        }
    }
    
    let strokeColor = UIColor.black
    
    private var heldFromSample: StrokeSample?
    private var heldFromSampleUnitVector: CGVector?
    
    private var lockedAzimuthUnitVector: CGVector?
    private let azimuthLockAltitudeThreshold = CGFloat.pi / 2.0 * 0.80 // locking azimuth at 80% altitude
    
    // MARK: - Dirty rect calculation and handling.
    var dirtyRectViews: [UIView]!
    var lastEstimatedSample: (Int, StrokeSample)?
    
    
    func updateView(view: UIView){
        self.currentStrokeIndex = 0
        self.view = view
    }
    func dirtyRects(for stroke: Stroke) -> [CGRect] {
        var result = [CGRect]()
        for range in stroke.updatedRanges() {
            var lowerBound = range.lowerBound
            if lowerBound > 0 { lowerBound -= 1 }
            
            if let (index, _) = lastEstimatedSample {
                if index < lowerBound {
                    lowerBound = index
                }
            }
            
            let samples = stroke.samples
            var upperBound = range.upperBound
            if upperBound < samples.count { upperBound += 1 }
            let dirtyRect = dirtyRectForSampleStride(stroke.samples[lowerBound..<upperBound])
            result.append(dirtyRect)
        }
        if stroke.predictedSamples.isEmpty == false {
            let dirtyRect = dirtyRectForSampleStride(stroke.predictedSamples[0..<stroke.predictedSamples.count])
            result.append(dirtyRect)
        }
        if let previousPredictedSamples = stroke.previousPredictedSamples {
            let dirtyRect = dirtyRectForSampleStride(previousPredictedSamples[0..<previousPredictedSamples.count])
            result.append(dirtyRect)
        }
        return result
    }
    
    func dirtyRectForSampleStride(_ sampleStride: ArraySlice<StrokeSample>) -> CGRect {
        var first = true
        var frame = CGRect.zero
        for sample in sampleStride {
            let sampleFrame = CGRect(origin: sample.location, size: .zero)
            if first {
                first = false
                frame = sampleFrame
            } else {
                frame = frame.union(sampleFrame)
            }
        }
        let maxStrokeWidth = CGFloat(20.0)
        return frame.insetBy(dx: -1 * maxStrokeWidth, dy: -1 * maxStrokeWidth)
    }
    
    //Goes through each rect
    func updateDirtyRects(for stroke: Stroke) {
        let updateRanges = stroke.updatedRanges()
        for (index, dirtyRectView) in dirtyRectViews.enumerated() {
            if index < updateRanges.count {
                dirtyRectView.alpha = 1.0
                dirtyRectView.frame = dirtyRectForSampleStride(stroke.samples[updateRanges[index]])
            } else {
                dirtyRectView.alpha = 0.0
            }
        }
    }
    
    func setNeedsDisplay(for stroke: Stroke) {
        for dirtyRect in dirtyRects(for: stroke) {
            view?.setNeedsDisplay(dirtyRect)
        }
    }
    
    func receivedAllUpdatesForStroke(_ stroke: Stroke) {
        
        setNeedsDisplay(for: stroke)
        stroke.clearUpdateInfo()
    }
    
    
    func strokeUpdated(strokeGesture: StrokeGestureRecognizer, isPencil: Bool ){
        var stroke: Stroke?
        if strokeGesture.state != .cancelled {
            stroke = strokeGesture.stroke
            if strokeGesture.state == .began ||
                (strokeGesture.state == .ended && strokeCollection?.activeStroke == nil) {
                strokeCollection?.activeStroke = stroke
            }
        } else {
            strokeCollection?.activeStroke = nil
        }
        
        if let stroke = stroke {
            if strokeGesture.state == .ended {
                if isPencil == true {
                    // Make sure we get the final stroke update if needed.
                    stroke.receivedAllNeededUpdatesBlock = { [weak self] in
                        self?.receivedAllUpdatesForStroke(stroke)
                    }
                }
                strokeCollection?.takeActiveStroke()
            }
        }
        //answerCell.strokeCollection = strokeCollection
        //self.cGStrokeCollection = answerCell.strokeCollection
    }
    
    func beginDraw(rect: CGRect){
        if let strokeCollection = strokeCollection {
            print("FIRRST BEGIN DRAW")
            for stroke in strokeCollection.strokes {
                draw(stroke: stroke) //, in: rect
            }
        }
        
        if let stroke = strokeToDraw {
             print("SECOND BEGIN DRAW")
            draw(stroke: stroke) //, in: rect
        }
    }
    
    func beginDrawContext(){
        print("BEGIN DRAW CONTEXT")
        if let strokeCollection = strokeCollection {
            for stroke in strokeCollection.strokes {
                draw(stroke: stroke)
            }
        }
        
        if let stroke = strokeToDraw {
            draw(stroke: stroke)
        }
    }
    
    func draw(stroke: Stroke) { //, in rect: CGRect
        
        stroke.clearUpdateInfo()
        
        guard stroke.samples.isEmpty == false,
            let context = UIGraphicsGetCurrentContext()
            else { return }
        
        prepareToDraw()
        lineSettings(in: context)
        
        if stroke.samples.count == 1 {
            // Construct a fake segment to draw for a stroke that is only one point.
            let sample = stroke.samples.first!
            let tempSampleFrom = StrokeSample(
                timestamp: sample.timestamp,
                location: sample.location + CGVector(dx: -0.5, dy: 0.0),
                coalesced: false,
                predicted: false,
                force: sample.force,
                azimuth: sample.azimuth,
                altitude: sample.altitude,
                estimatedProperties: sample.estimatedProperties,
                estimatedPropertiesExpectingUpdates: [])
            
            let tempSampleTo = StrokeSample(
                timestamp: sample.timestamp,
                location: sample.location + CGVector(dx: 0.5, dy: 0.0),
                coalesced: false,
                predicted: false,
                force: sample.force,
                azimuth: sample.azimuth,
                altitude: sample.altitude,
                estimatedProperties:
                sample.estimatedProperties,
                estimatedPropertiesExpectingUpdates: [])
            
            let segment = StrokeSegment(sample: tempSampleFrom)
            segment.advanceWithSample(incomingSample: tempSampleTo)
            segment.advanceWithSample(incomingSample: nil)
            
            draw(segment: segment, in: context)
        } else {
            for segment in stroke {
                draw(segment: segment, in: context)
            }
        }
        
    }
    
    func draw(segment: StrokeSegment, in context: CGContext) {
        
        guard let toSample = segment.toSample else { return }
        
        let fromSample: StrokeSample = heldFromSample ?? segment.fromSample
        
        // Skip line segments that are too short.
        if (fromSample.location - toSample.location).quadrance < 0.003 {
            if heldFromSample == nil {
                heldFromSample = fromSample
                heldFromSampleUnitVector = segment.fromSampleUnitNormal
            }
            return
        }
        
        fillColor(in: context, toSample: toSample, fromSample: fromSample)
        draw(segment: segment, in: context, toSample: toSample, fromSample: fromSample)
        
        if heldFromSample != nil {
            heldFromSample = nil
            heldFromSampleUnitVector = nil
        }
    }
    
    func draw(segment: StrokeSegment,
              in context: CGContext,
              toSample: StrokeSample,
              fromSample: StrokeSample) {
        
        let forceAccessBlock = self.forceAccessBlock()
        
        
        let unitVector = heldFromSampleUnitVector != nil ? heldFromSampleUnitVector! : segment.fromSampleUnitNormal
        let fromUnitVector = unitVector * forceAccessBlock(fromSample)
        let toUnitVector = segment.toSampleUnitNormal * forceAccessBlock(toSample)
        
        let isForceEstimated = fromSample.estimatedProperties.contains(.force) || toSample.estimatedProperties.contains(.force)
        if isForceEstimated {
            if lastEstimatedSample == nil {
                lastEstimatedSample = (segment.fromSampleIndex + 1, toSample)
            }
            forceEstimatedLineSettings(in: context)
        } else {
            lineSettings(in: context)
        }

        
        context.beginPath()
        context.addLines(between: [
            fromSample.location , //+ fromUnitVector,
            toSample.location ,//+ toUnitVector,
            toSample.location ,//- toUnitVector,
            fromSample.location //- fromUnitVector  //These help with Force.
            ])
        
        context.closePath()
        context.drawPath(using: .fillStroke)
        

        
        
    }
    
    
    
    func prepareToDraw() {
        lastEstimatedSample = nil
        heldFromSample = nil
        heldFromSampleUnitVector = nil
        lockedAzimuthUnitVector = nil
    }
    
    func lineSettings(in context: CGContext) {
        
        
        context.setLineWidth(2.0)
        context.setStrokeColor(strokeColor.cgColor)
        
        
    }
    
    func forceEstimatedLineSettings(in context: CGContext) {
        lineSettings(in: context)
        
    }
    
    func azimuthSettings(in context: CGContext) {
        context.setLineWidth(1.5)
        context.setStrokeColor(#colorLiteral(red: 0, green: 0.7445889711, blue: 1, alpha: 1).cgColor)
    }
    
    func altitudeSettings(in context: CGContext) {
        context.setLineWidth(0.5)
        context.setStrokeColor(strokeColor.cgColor)
    }
    
    func forceAccessBlock() -> (_ sample: StrokeSample) -> CGFloat {
        
        var forceMultiplier = CGFloat(2.0)
        var forceOffset = CGFloat(0.1)
        var forceAccessBlock = {(sample: StrokeSample) -> CGFloat in
            return sample.forceWithDefault
        }
        
        if displayOptions == .ink {
            forceAccessBlock = {(sample: StrokeSample) -> CGFloat in
                return sample.perpendicularForce
            }
        }
        
        let previousGetter = forceAccessBlock
        forceAccessBlock = {(sample: StrokeSample) -> CGFloat in
            return previousGetter(sample) * forceMultiplier + forceOffset
        }
        
        return forceAccessBlock
    }
    
    func fillColor(in context: CGContext, toSample: StrokeSample, fromSample: StrokeSample) {
        let fillColorRegular = UIColor.black.cgColor
        let fillColorCoalesced = UIColor.lightGray.cgColor
        let fillColorPredicted = UIColor.red.cgColor
        context.setFillColor(fillColorRegular)
        if toSample.predicted {
            context.setFillColor(fillColorRegular)
        }
    }
    
}


    
