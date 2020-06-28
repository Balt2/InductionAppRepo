//
//  ApplePencilReachability.swift
//  InductionApp
//
//  Created by Ben Altschuler on 5/23/20.
//  Copyright © 2020 Ben Altschuler. All rights reserved.
//

import Foundation
import CoreBluetooth
//Code copied from: https://stackoverflow.com/questions/32542250/detect-whether-apple-pencil-is-connected-to-an-ipad-pro
class ApplePencilReachability: NSObject, CBCentralManagerDelegate {

  private let centralManager = CBCentralManager()
  var pencilAvailabilityDidChangeClosure: ((_ isAvailable: Bool) -> Void)?

  var timer: Timer? {
    didSet {
      if oldValue !== timer { oldValue?.invalidate() }
    }
  }

  var isPencilAvailable = false {
    didSet {
      guard oldValue != isPencilAvailable else { return }
      pencilAvailabilityDidChangeClosure?(isPencilAvailable)
    }
  }

  override init() {
    super.init()
    centralManager.delegate = self
    centralManagerDidUpdateState(centralManager) // can be powered-on already?
  }
  deinit { timer?.invalidate() }

  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    if central.state == .poweredOn {
      timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
        [weak self] timer in // break retain-cycle
        self?.checkAvailability()
        if self == nil { timer.invalidate() }
      }
    } else {
      timer = nil
      isPencilAvailable = false
    }
  }

  private func checkAvailability() {
    let peripherals = centralManager.retrieveConnectedPeripherals(withServices: [CBUUID(string: "180A")])
    //let oldPencilAvailability = isPencilAvailable
    isPencilAvailable = peripherals.contains(where: { $0.name == "Apple Pencil" })
    if isPencilAvailable {
      timer = nil // only if you want to stop once detected
    }
  }

}
