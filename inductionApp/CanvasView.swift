//
//  CanvasView.swift
//  InductionApp
//
//  Created by Ben Altschuler on 4/22/20.
//  Copyright © 2020 Josh Breite. All rights reserved.
//

import Foundation
import UIKit
import PencilKit

class CanvasView: UIControl, PKCanvasViewDelegate {
  var drawingImage: UIImage?
    private let defaultLineWidth: CGFloat = 0.5
    private let minLineWidth: CGFloat = 0.4
    private let forceSensitivity: CGFloat = 1
  
    var canvasViewPK: PKCanvasView
    
  init(drawingImage: UIImage?) {
    self.drawingImage = drawingImage
    self.canvasViewPK = PKCanvasView()
    
    super.init(frame: .zero)
    self.addSubview(self.canvasViewPK)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
    
    override func didMoveToWindow() {
        canvasViewPK.delegate = self
        print("BEN")
        canvasViewPK.drawing = PKDrawing()
        canvasViewPK.allowsFingerDrawing = false
    }
    
    // MARK: Canvas View Delegate
       
       /// Delegate method: Note that the drawing has changed.
       func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
           print("Drawing Canvas View Drawing Did Change")
          
       }
  
  override func draw(_ rect: CGRect) {
    drawingImage?.draw(in: rect)
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    sendActions(for: .valueChanged)
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    drawingImage = UIGraphicsImageRenderer(size: bounds.size).image { context in
      UIColor.white.setFill()
      context.fill(bounds)
      drawingImage?.draw(in: bounds)
        var touches = [UITouch]()
        if let coalescedTouches = event?.coalescedTouches(for: touch){
            touches = coalescedTouches
        }else{
            touches.append(touch)
        }
      drawStroke(context: context.cgContext, touch: touch)
      setNeedsDisplay()
    }
  }
  
  private func drawStroke(context: CGContext, touch: UITouch) {
    let previousLocation = touch.previousLocation(in: self)
    let location = touch.location(in: self)
    
    var lineWidth: CGFloat = defaultLineWidth
    if touch.force > 0{
        lineWidth = touch.force * forceSensitivity
    }
    context.setLineWidth(lineWidth)
    context.setLineCap(.round)
    
    
    context.move(to: previousLocation)
    context.addLine(to: location)
    context.strokePath()
  }
}
