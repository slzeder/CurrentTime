//
//  PeripheralCharacteristic.swift
//  Current Time
//
//  Created by Stacy Zeder on 3/20/21.
//

import Foundation


struct PeripheralCharacteristic: Identifiable {
  var id: String
  let properties: UInt
  let containsNotify: Bool
  let containsRead: Bool
  let notifying: Bool
  
  var description: String {
    var msg = id + ", "
    msg = msg + "0x" + String(format: "%02X, properties.description") + ", "  // TODO: Print as hex
    msg = msg + containsNotify.description + ", "
    msg = msg + containsRead.description + ", "
    msg = msg + notifying.description + ", "
    return msg
  }
}
