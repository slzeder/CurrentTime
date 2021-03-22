//
//  Enums.swift
//  Current Time
//
//  Created by Stacy Zeder on 3/21/21.
//

import Foundation
import CoreBluetooth


// MARK: Service Assigned numbers

// BT Service GATT assigned numbers
enum BTService: String {
  // Time service peripheral supports three services:
  case currentTime = "0x1805"
  case referenceTimeUpdate = "0x1806"
  case timeWithDST = "0x1807"
  
  // TODO: FUTURE - could extend app to support other services, such as:
  case battery = "0x180F"
  case heartRate = "0x180D"
}


// MARK: Characteristic Assigned numbers

// MARK: Characteristics - for Current Time Service

// Refs:
//   * https://btprodspecificationrefs.blob.core.windows.net/assigned-values/16-bit%20UUID%20Numbers%20Document.pdf
//   * file:///Users/stacy/Downloads/CTS_SPEC_V1.1.0.pdf
// GATT Characteristic and Object Type 0x2A2B Current Time
enum TimeCharacteristic: String {
  case currentTime = "0x2A2B"               // Required
  case localTimeInformation = "0x2A0F"      // Optional
  case referenceTimeInformation = "0x2A14"  // Optional
}

enum CurrentTimeAdjustReason: Int, CustomStringConvertible {
  case manualTimeUpdate = 1             // Bit0
  case externalReferenceTimeUpdate = 2  // Bit1
  case changeOfTimeZone = 4             // Bit2
  case changeOfDST = 8                  // Bit3
//  case reservedForFutureUse = 16  // Bit4-7

  public var description: String {
    return name
  }
  
  var name: String {
    switch self {
    case .manualTimeUpdate: return "Manual time update"
    case .externalReferenceTimeUpdate: return "External reference time update"
    case .changeOfTimeZone: return "Change of Time Zone"
    case .changeOfDST: return "Change of DST"
    default:
      return "Reserved for future use"
    }
  }
}

// Daylight Savings Time
enum DSTOffsetField: Int {
  case standardTime = 0
  case halfAnHourDaylightTime = 2  // (+ 0.5h)
  case daylightTime = 4            // (+ 1h)
  case doubleDaylightTime = 8      // (+ 2h)
  case DSTOffsetUnknown = 255
  
  var offsetValue: Float {
    switch self {
    case .standardTime: return 0.0
    case .halfAnHourDaylightTime: return 0.5
    case .daylightTime: return 1.0
    case .doubleDaylightTime: return 2.0
    case .DSTOffsetUnknown: return 0.0
    }
  }
}

enum DayOfWeek: Int, CustomStringConvertible {
  case monday = 1
  case tuesday = 2
  case wednesday = 3
  case thursday = 4
  case friday = 5
  case saturday = 6
  case sunday = 7
  
  public var description: String {
    return name
  }
  
  var name: String {
    switch self {
    case .monday: return "Monday"
    case .tuesday: return "Tuesday"
    case .wednesday: return "Wednesday"
    case .thursday: return "Thursday"
    case .friday: return "Friday"
    case .saturday: return "Saturday"
    case .sunday: return "Sunday"
    }
  }
}

enum Month: Int, CustomStringConvertible {
  case jan = 1
  case feb = 2
  case mar = 3
  case apr = 4
  case may = 5
  case jun = 6
  case jul = 7
  case aug = 8
  case sep = 9
  case oct = 10
  case nov = 11
  case dec = 12

  public var description: String {
    return name
  }
  
  var name: String {
    switch self {
    case .jan: return "Jan"
    case .feb: return "Feb"
    case .mar: return "Mar"
    case .apr: return "Apr"
    case .may: return "May"
    case .jun: return "Jun"
    case .jul: return "Jul"
    case .aug: return "Aug"
    case .sep: return "Sep"
    case .oct: return "Oct"
    case .nov: return "Nov"
    case .dec: return "Dec"
    }
  }
}

