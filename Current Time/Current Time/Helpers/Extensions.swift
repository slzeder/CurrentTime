//
//  Extensions.swift
//  Current Time
//
//  Created by Stacy Zeder on 3/22/21.
//

import Foundation


// MARK: Extensions for Data

extension Data {
  struct HexEncodingOptions: OptionSet {
    let rawValue: Int
    static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
  }
  
  func hexEncodedString(options: HexEncodingOptions = []) -> String {
    let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
    return map { String(format: format, $0) }.joined()
  }
  
  var bytes: [UInt8] {
    return [UInt8](self)
  }
  
}


