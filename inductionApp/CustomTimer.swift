//
//  CustomTimer.swift
//  InductionApp
//
//  Created by Ben Altschuler on 5/17/20.
//  Copyright © 2020 Ben Altschuler. All rights reserved.
//

import Foundation

class CustomTimer: ObservableObject {
    private var endDate: Date?
    private var timer: Timer?
    var timeRemaining: Double {
        didSet {
            self.setRemaining()
        }
    }
    @Published var timeLeftFormatted = ""
    
    init(duration: Int) {
        self.timeRemaining = Double(duration)
    }
    

    func startTimer() {
        self.endDate = Date().advanced(by: self.timeRemaining)
        
        guard self.timer == nil else {
            return
        }
        
        self.timer = Timer(timeInterval: 0.2, repeats: true) { (timer) in
            self.timeRemaining = self.endDate!.timeIntervalSince(Date())
            if self.timeRemaining < 0 {
                timer.invalidate()
                self.timer = nil
            }
        }
        RunLoop.current.add(self.timer!, forMode: .common)
    }

    private func setRemaining() {
        let min = max(floor(self.timeRemaining / 60),0)
        let sec = max(floor((self.timeRemaining - min*60).truncatingRemainder(dividingBy:60)),0)
        self.timeLeftFormatted = "\(Int(min)):\(Int(sec))"
    }

    func endTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
}
