//
//  ViewController.swift
//  Current Time
//
//  Created by Stacy Zeder on 3/20/21.
//

import UIKit

class ViewController: UIViewController, BluetoothControlDelegate {

  // MARK: Properties
  
  @IBOutlet weak var startStopButton: UIButton!
  @IBOutlet weak var dateTimeTextField: UITextField!
  
  let btControl: BluetoothControl! = BluetoothControl()
  
 
  // MARK: Conform to UIViewController
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Set up self as delegate to btControl
    btControl.delegate = self
  }

  
  // MARK: Conform to BluetoothControlDelegate
  func notifyNoPeripheralFound() {
      noPeripheralFoundAlert()
  }
  
  func notifyCentralStateIsOff() {
    bluetoothIsOffAlert()
  }
  
  func didReceiveTime(date: Date) {
    print("[VC | didReceiveTime]")
    clearUI()
    
    // NOTE: Can alter dateFormatter here
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd  HH:mm:ss.SSSS"
    
    print("date: \(date.description)")
    print("dateFormatter.string(from: date): \(dateFormatter.string(from: date))")
    
    dateTimeTextField.text = dateFormatter.string(from: date)
  }
  
  // MARK: Helpers
  
  private func clearUI() {
    dateTimeTextField.text = ""
  }
  
  private func bluetoothIsOffAlert() {
    // Alert
    DispatchQueue.main.async {
      let alert = UIAlertController(title: "WARNING", message: "The bluetooth on your device is powered off. Please turn bluetooth ON", preferredStyle: UIAlertController.Style.alert)
      alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) in
        print("DEBUG - device's bluetooth needs to be turned on.")
      }))
      self.present(alert, animated: true, completion: nil)
    }
  }
  
  private func noPeripheralFoundAlert() {
    // Alert
    DispatchQueue.main.async {
      let alert = UIAlertController(title: "WARNING", message: "No peripheral data was found. Make sure peripheral device is on, in range, and able to transmit data.", preferredStyle: UIAlertController.Style.alert)
      alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) in
        print("DEBUG - peripheral not found")
      }))
      self.present(alert, animated: true, completion: nil)
    }
  }
  
  // MARK: Methods
  
  
  // MARK: Actions
    
  @IBAction func startStopButton(_ sender: UIButton) {
    clearUI()
    btControl.startScan()
  }

}

