//
//  OrientationInfoClass.swift
//  InductionApp
//
//  Created by Ben Altschuler on 8/1/20.
//  Copyright © 2020 Ben Altschuler. All rights reserved.
//
//https://developer.apple.com/forums/thread/126878

import Foundation
import SwiftUI

final class OrientationInfo: ObservableObject {
    enum Orientation: String {
        case portrait = "Portrait"
        case landscape = "Landscape"
    }
    
    @Published var orientation: Orientation
    
    private var _observer: NSObjectProtocol?
    
    init() {
        // fairly arbitrary starting value for 'flat' orientations
        if UIDevice.current.orientation.isLandscape {
            self.orientation = .landscape
        }
        else {
            self.orientation = .portrait
        }
        
        // unowned self because we unregister before self becomes invalid
        _observer = NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: nil) { [unowned self] note in
            guard let device = note.object as? UIDevice else {
                return
            }
            if device.orientation.isPortrait {
                self.orientation = .portrait
            }
            else if device.orientation.isLandscape {
                self.orientation = .landscape
            }
        }
    }
    
    deinit {
        if let observer = _observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
