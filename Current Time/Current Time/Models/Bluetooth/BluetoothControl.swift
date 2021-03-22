//
//  BluetoothControl.swift
//  Current Time
//
//  Created by Stacy Zeder on 3/20/21.
//

import Foundation
import CoreBluetooth


protocol BluetoothControlDelegate: AnyObject {
  func notifyCentralStateIsOff()
  func notifyNoPeripheralFound()
  func didReceiveTime(date: Date)
}


/// BluetoothControl - a class to manage and control the bluetooth communications. It contains the code for scanning, discovering services and characteristics, for setting the method (.read or .notify) that the peripheral supports.
class BluetoothControl: NSObject, ObservableObject, CBCentralManagerDelegate {
  
  weak var delegate: BluetoothControlDelegate?
  var timer: Timer = Timer()
  private var central: CBCentralManager!
  var peripheralData: [PeripheralData] = []
  var peripheralCharacteristics: [PeripheralCharacteristic] = []
  
  // Generic service object
  // FUTURE: Have a selector so users can choose from a list of services,
  // including all. For now start with generic and assign to Current
  // Time Service.
  var service: CBUUID = CBUUID(string: "0x1800")
  var peripheral: CBPeripheral!
  
  override init() {
    print("[BluetoothControl | init]")
    
    super.init()
    
    // Initialize central object, establish connection to central's delegate.
    central = CBCentralManager(delegate: self, queue: nil)
    central.delegate = self
    
    // Assign service to connect to
    service = CBUUID(string: BTService.currentTime.rawValue)
  }
  
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    print("[BluetoothControl | centralManagerDidUpdateState]")
    
    switch central.state {
    case .unknown:
      print("unknown")
    case .resetting:
      print("resetting")
    case .unsupported:
      print("unsupported")
    case .unauthorized:
      print("unauthorized")
    case .poweredOff:
      print("poweredOff")
      delegate?.notifyCentralStateIsOff()
    case .poweredOn:
      print("poweredOn")
    @unknown default:
      print("central.state is @unknown default")
    }
  }
  
  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    print ("[BluetoothControl | centralManager, didDiscover]")
    
    self.peripheral = peripheral
    self.peripheral.delegate = self
    
    // Shut down timer, peripheral was discovered.
    timer.invalidate()
    stopScan()
    central.connect(self.peripheral, options: nil)
  }
  
  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    print ("!!!! connected !!!!!")
    // NOTE: Set up to discover only one service.
    peripheral.discoverServices([service])
  }
  
  func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    print ("-------------- disconnected --------------")
    if central.isScanning {
      stopScan()
    }
    self.delegate?.notifyNoPeripheralFound()
  }
  
  
  @objc func noPeripheralFound() {
    print("[BluetoothControl | noPeripheralFound]")
    stopScan()
    delegate?.notifyNoPeripheralFound()
    timer.invalidate()
  }
  
  func startScan() {
    print ("[BluetoothControl | startScan]")
    // TODO: FUTURE - Add ability to choose services scanning by
    // passing [CBUUID], or nil for all services
    
    print ("[BluetoothControl | startScan] central.state: \(central.state)")
    print ("[BluetoothControl | startScan] service.uuidString: \(service.uuidString)")
    
    if central.state == .poweredOn {
      central.scanForPeripherals(withServices: [service], options: nil)
      
      // kick off one-shot timer
      timer = Timer.scheduledTimer(
        timeInterval: 0.5,
        target: self,
        selector: #selector(noPeripheralFound),
        userInfo: nil,
        repeats: false)
      
    } else if central.state == .poweredOff {
      delegate?.notifyCentralStateIsOff()
    }
  }
  
  func stopScan() {
    print ("[BluetoothControl | stopScan]")
    if central.state == .poweredOn {
      central.stopScan()
    }
  }
}


// MARK: Extension - Conform to CBPeripheralDelegate

extension BluetoothControl: CBPeripheralDelegate {
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    print ("[BluetoothControl | CBPeripheralDelegate - didDiscoverServices]")
    
    if let err = error {
      print("didDiscoverServices >>> ERROR <<< \(err.localizedDescription)")
    } else {
      
      if let services = peripheral.services {
        for service in services {
          print ("[BluetoothControl | CBPeripheralDelegate - didDiscoverServices] service: \(service), discovered. Now discovering characteristics")
          peripheral.discoverCharacteristics(nil, for: service)
        }
      }
    }
  }
  
  
  
  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    print ("[BluetoothControl | CBPeripheralDelegate - didDiscoverCharacteristicsFor] BEGIN")
    
    guard let characteristics = service.characteristics else {
      return
    }
    
    // NOTE: Limit to CurrentTimeService
    
    for characteristic in characteristics {
      if characteristic.uuid == CBUUID(string: TimeCharacteristic.currentTime.rawValue) {
        print()
        print(characteristic)
        
        var containsNotify: Bool = false
        var containsRead: Bool = false
        
        if characteristic.properties.contains(.notify) {
          print("\(characteristic.uuid.uuidString): properties contains .notify")
          containsNotify = true
          
          // >>>>> NOTICE <<<<<
          // When using the LightBlue app set as a Time virtual device
          // which indicates it supports read and notify for the CurrentTime
          // characteristic, I am only able to read from it.
          //
          // I tried many things to determine if the problem is in my code or
          // if the characteristic is not publishing even after notify is set
          // on. One thing I did was to have two iPhones running with LightBlue.
          // I was not able to see the notifications being received there
          // either. I am not yet sure of the root cause of the problem, but
          // this is why I have commented out the setNotifyValue call and
          // am performing a read. This way, at least, I am able to
          // retrieve data from the device.
          //
          // TODO: Further investigation - notify seems to get set, but
          // the callbacks do not get hit. Pub problem? or Sub problem?
          //
          // !!!!          peripheral.setNotifyValue(true, for: characteristic)
          peripheral.readValue(for: characteristic)
          
        } else {
          print("\(characteristic.uuid.uuidString): properties contains .read")
          containsRead = true
          peripheral.readValue(for: characteristic)
        }
        
        // TODO: For debug
        let periphCharacteristic = PeripheralCharacteristic(
          id: characteristic.uuid.uuidString,
          properties: characteristic.properties.rawValue,
          containsNotify: containsNotify,
          containsRead: containsRead,
          notifying: characteristic.isNotifying)
        print("------- periphChar: \(periphCharacteristic.description)")
        peripheralCharacteristics.append(periphCharacteristic)
      }
    }
  }
  
  // Confirm notification was set
  func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
    print ("[ CBPeripheralDelegate - didUpdateNotificationStateFor] BEGIN - verify notification was set")
    
    if let err = error {
      // TODO: Handle error
      print("[didUpdateNotificationStateFor] ERROR: \(err.localizedDescription)")
    } else {
      print ("[ CBPeripheralDelegate - didUpdateNotificationStateFor] characteristic UUID: \(characteristic.uuid.uuidString) isNotifying: \(characteristic.isNotifying)")
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    print ("[BluetoothControl | CBPeripheralDelegate - didUpdateValueFor] BEGIN")
    
    if let err = error {
      // TODO: Handle error
      print("[didUpdateValueFor] ERROR: \(err.localizedDescription)")
    } else {
      switch characteristic.uuid {
      case CBUUID(string: TimeCharacteristic.currentTime.rawValue):
        print("TimeCharacteristic.currentTime")
        if let _ = characteristic.value {
          getCurrentTime(from: characteristic)
        }
      case CBUUID(string: TimeCharacteristic.localTimeInformation.rawValue):
        print("TimeCharacteristic.localTimeInformation")
      case CBUUID(string: TimeCharacteristic.referenceTimeInformation.rawValue):
        print("TimeCharacteristic.referenceTimeInformation")
      default:
        print("     >>>>>>>> default - no characteristic handler found for \(characteristic.uuid.uuidString)")
      }
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
    // TODO: Notify
  }
  
  
  //
  // MARK: Interpret / parse characteristics
  //
  
  /// getCurrentTime - Parse the GATT Current Time Service
  /// REF: Document: GATT Specification Supplement v2, Section 3.52
  ///
  ///      Current Time Characteristic
  ///      ----------------------------
  ///      Exact Time 256: Bytes 0 - 9
  ///          Day Date Time - Bytes 0 - 7
  ///              Date Time: Bytes 0 - 6
  ///                  Year: Bytes 0 - 1
  ///                  Month: Byte 2
  ///                  Day: Byte 3
  ///                  Hours: Byte 4
  ///                  Min: Byte 5
  ///                  Sec: Byte 6
  ///              Day of Week: Byte 7
  ///          Fractions256: Byte 8
  ///      Adjustment Reason: Byte 9
  ///
  /// - Parameter characteristic: CBCharacteristic, the characteristic to parse
  /// - Returns: String represenation of current time
  ///
  private func getCurrentTime(from characteristic: CBCharacteristic) -> Void {
    guard let characteristicData = characteristic.value else {
      return
    }
    
    let dataBytes = characteristicData.bytes;
    
    // Determine adjust reason
    // NOTE: Could mask/bit bang, but more readable to use enums
    var adjustmentReason = CurrentTimeAdjustReason(rawValue: Int(dataBytes[9]))!
    
    // TODO: Take adjustments into account.
    // TODO: This sample app only accesses the Current Time Service.
    // The device supports the TimeWithDST. This could be retrived and
    // considered in the calculations.
    
    let year = (Int(dataBytes[1]) << 8) + Int(dataBytes[0])
    let month = Int(dataBytes[2])
    let day =   Int(dataBytes[3])
    let hours = Int(dataBytes[4])
    let min =   Int(dataBytes[5])
    let sec =   Int(dataBytes[6])
    let fractionAsInt = Int(10000 * Float(dataBytes[8]) / Float(256))
    let dateString = "\(year)-\(month)-\(day)  \(hours):\(min):\(sec).\(fractionAsInt)"
    print("[getCurrentTime] dateString: \(dateString)")
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd  HH:mm:ss.SSSS"
    let date = dateFormatter.date(from: dateString)
    
    if let dateFound = date {
      delegate?.didReceiveTime(date: dateFound)
    }
  }
}
