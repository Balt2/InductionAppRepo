//
//  CanvasView.swift
//  InductionApp
//
//  Created by Ben Altschuler on 4/22/20.
//  Copyright © 2020 Josh Breite. All rights reserved.
//

import Foundation
import UIKit

class CanvasView: UIControl {
    var drawingImage: UIImage?
    
    init(drawingImage: UIImage?){
        self.drawingImage = drawingImage
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
