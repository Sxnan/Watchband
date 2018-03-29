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
    
    @IBOutlet weak var measurement: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btmodel = BluetoothModel()
        btmodel.delegate = self
    }
}

extension ViewController {
    func didMeasurementUpdate(_ measurement: Int32) {
        self.measurement.text = "\(measurement)"
    }
    
    func bluetoothIsPoweredOff() {
        let alert = UIAlertController(title: "Bluetooth is Powered Off", message: "Turn on the bluetooth", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) {
            _ in
            print("Ok is pressed")
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    func bluetoothIsPoweredOn() {
        
    }
    
    func didDisconnectedWith(Peripheral peripheral: CBPeripheral) {
        let alert = UIAlertController(title: "Bluetooth Disconnected", message: "Try to reconnect\n Make sure the Bluetooth is on", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) {
            _ in
            print("Ok is pressed")
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    func startConnectingTo(Peripheral peripheral: CBPeripheral) {
        
    }
}

