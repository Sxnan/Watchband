//
//  ViewController.swift
//  test
//
//  Created by Xuannan Su on 2/5/18.
//  Copyright © 2018 Xuannan Su. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, BluetoothModelDelegate{    

    private var btmodel: BluetoothModel!
    private var saver: MeasurementSaver!
    private let formatter = DateFormatter()
    private let timeFormatter = DateFormatter()
    
    @IBOutlet weak var measurement: UILabel!
    @IBOutlet weak var connectingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectingIndicator.hidesWhenStopped = true
        btmodel = BluetoothModel()
        btmodel.delegate = self
        saver = MeasurementSaver()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        timeFormatter.timeZone = TimeZone.current
        timeFormatter.dateFormat = "HH:mm:ss.SSS"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        connectingIndicator.stopAnimating()
    }
}

extension ViewController {
    func didMeasurementUpdate(_ measurement: Float32) {
        let now = Date()

        self.measurement.text = "\(measurement)"
        
        // save the measurement
        let fileName = "\(formatter.string(from: now)).csv"
        let timeString = timeFormatter.string(from: now)
        let data = Measurement(time: timeString, value: measurement)
        if saver.saveMeasurement(data, toFile: fileName) {
            print("\(data) is saved")
        } else {
            print("save \(data) failed")
        }
    }
    
    func bluetoothIsPoweredOff() {
        self.measurement.text = "Bluetooth is Off"
    }
    
    func bluetoothIsPoweredOn() {
        
    }
    
    func didDisconnectedWith(Peripheral peripheral: CBPeripheral) {
        self.measurement.text = "Disconnected"
    }
    
    func startConnectingTo(Peripheral peripheral: CBPeripheral) {
        connectingIndicator.startAnimating()
    }
    
    func didConnectTo(Peripheral peripheral: CBPeripheral) {
        connectingIndicator.stopAnimating()
    }
}

