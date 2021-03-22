//
//  PeripheralData.swift
//  Current Time
//
//  Created by Stacy Zeder on 3/20/21.
//

import Foundation
import CoreBluetooth

struct PeripheralData: Identifiable {
  let id: String
  let name: String
  let rssi: Int
  let txPowerLevel: Double
  
  var description: String {
    var msg = id + ", "
    msg = msg + name + ", "
    msg = msg + rssi.description + ", "
    msg = msg + txPowerLevel.description + ", "
    return msg
  }
}

extension PeripheralData {
  init() {
    id = "0"
    name = "unknown"
    rssi = -999
    txPowerLevel = -999.9
  }
}
