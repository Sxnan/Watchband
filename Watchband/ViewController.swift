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
    private var recordingFlag = false
    private var currentFileName: String?
    
    @IBOutlet weak var measurementLabel: UILabel!
    @IBOutlet weak var connectingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectingIndicator.hidesWhenStopped = true
        btmodel = BluetoothModel()
        btmodel.delegate = self
        saver = MeasurementSaver()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        timeFormatter.timeZone = TimeZone.current
        timeFormatter.dateFormat = "HH:mm:ss.SSS"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        connectingIndicator.stopAnimating()
    }
    
    @IBAction func toggleRecoding(_ sender: UIButton) {
        switch (sender.currentTitle) {
        case "start":
            let now = Date()
            currentFileName = "\(formatter.string(from: now)).csv"
            sender.setTitle("stop", for: .normal)
            recordingFlag = true
        case "stop":
            sender.setTitle("start", for: .normal)
            recordingFlag = false
        default:
            break
        }
    }
}

extension ViewController {
    func didMeasurementUpdate(_ measurement: Float32) {

        if measurement < 0 {
            self.measurementLabel.text = "No Skin Contact"
            return
        }
        self.measurementLabel.text = String(format: "%.2f", measurement)
        
        if recordingFlag {
            let now = Date()
            let timeString = timeFormatter.string(from: now)
            let data = Measurement(time: timeString, value: measurement)
            if saver.saveMeasurement(data, toFile: currentFileName!) {
                print("\(data) is saved")
            } else {
                print("save \(data) failed")
            }      
        }
    }
    
    func bluetoothIsPoweredOff() {
        self.measurementLabel.text = "Bluetooth is Off"
    }
    
    func bluetoothIsPoweredOn() {
        
    }
    
    func didDisconnectedWith(Peripheral peripheral: CBPeripheral) {
        self.measurementLabel.text = "Disconnected"
    }
    
    func startConnectingTo(Peripheral peripheral: CBPeripheral) {
        connectingIndicator.startAnimating()
    }
    
    func didConnectTo(Peripheral peripheral: CBPeripheral) {
        connectingIndicator.stopAnimating()
    }
}

