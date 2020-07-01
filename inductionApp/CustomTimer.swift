//
//  CustomTimer.swift
//  InductionApp
//
//  Created by Ben Altschuler on 5/17/20.
//  Copyright © 2020 Ben Altschuler. All rights reserved.
//

import Foundation


//Custom Timer for the test view
class CustomTimer: ObservableObject {
    private var endDate: Date?
    private var timer: Timer?
    private var remainingTimeAtLastAnswer: Double
    private var allotedTime: Double
    @Published var done = false
    
    var timeRemaining: Double {
        didSet {
            self.setRemaining()
        }
    }
    
    @Published var timeLeftFormatted = ""
    
    // gets the time delta between the last question answered and the current one
    var timeDelta: Double{
        let td = remainingTimeAtLastAnswer - timeRemaining
        remainingTimeAtLastAnswer = timeRemaining
        return td
    }
    
    init(duration: Int) {
        self.timeRemaining = Double(duration)
        self.remainingTimeAtLastAnswer = Double(duration)
        self.allotedTime = Double(duration)
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
                self.done = true
                self.timer = nil
            }
        }
        RunLoop.current.add(self.timer!, forMode: .common)
    }
    
//    func reset(){
//        self.timeRemaining = Double(d)
//    }

    private func setRemaining() {
        let min = max(floor(self.timeRemaining / 60),0)
        let sec = max(floor((self.timeRemaining - min*60).truncatingRemainder(dividingBy:60)),0)
        self.timeLeftFormatted = "\(String(format: "%02d", Int(min))):\(String(format: "%02d", Int(sec)))"
        //"\(Int(min)):\(Int(sec))"
        
    }

    func endTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
}
