//
//  BluetoothManager.swift
//  test
//
//  Created by Xuannan Su on 2/8/18.
//  Copyright © 2018 Xuannan Su. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol BluetoothModelDelegate: class {
    func didMeasurementUpdate(_ measurement: Float32)
    func bluetoothIsPoweredOff()
    func bluetoothIsPoweredOn()
    func startConnectingTo(Peripheral peripheral: CBPeripheral)
    func didConnectTo(Peripheral peripheral: CBPeripheral)
    func didDisconnectedWith(Peripheral peripheral: CBPeripheral)
}

class BluetoothModel: NSObject {
    
    weak var delegate: BluetoothModelDelegate?
    
    private var centralManager: CBCentralManager!
    
    private var connectedPeripherals: [CBPeripheral]!
    
    var rxCharacteristic: CBCharacteristic?
    
    private var measurement:Float32 = 0

    private var peripheral:CBPeripheral? {
        get {
            if (connectedPeripherals.count != 0) {
                return connectedPeripherals[0]
            } else {
                return nil
            }
            
        }
    }
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        connectedPeripherals = [CBPeripheral]()
    }
    
    func retriveConnectedDevice(withServiceUUID uuid: CBUUID) {
        print("Start retriving connected device")
        connectedPeripherals = centralManager.retrieveConnectedPeripherals(withServices: [uuid])
        if connectedPeripherals.count != 0 {
            print("Retriving successed")
            for peripheral in connectedPeripherals {
                print(peripheral)
            }
            if let _peripheral = peripheral {
                centralManager.connect(_peripheral, options: nil)
            }
        } else {
            print("No device with \(uuid) service is retrived from the system")
            print("Scanning start")
            centralManager.scanForPeripherals(withServices: [uuid], options: nil)
        }
    }
    
    func connect(toPeripheral peripheral: CBPeripheral) {
        print("Connecting to \(peripheral.name ?? "no name")")
        delegate?.startConnectingTo(Peripheral: peripheral)
        centralManager.connect(peripheral, options: nil)
    }
    
    func discoverService(withServiceUUID uuid:CBUUID) {
        print("Start discover service with UUID: \(uuid)")
        peripheral?.discoverServices([uuid])
    }
    
    func discoverCharacteristic(withCharacteristicUUID uuid:CBUUID, forService service:CBService) {
        print("Start discovering characteristic \(uuid) for serivce \(service)")
        peripheral?.discoverCharacteristics([uuid], for: service)
    }
}

extension BluetoothModel: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case CBManagerState.poweredOn:
            print("\(central.description) is power on")
            delegate?.bluetoothIsPoweredOn()
            if connectedPeripherals.count == 0 {
                retriveConnectedDevice(withServiceUUID: CBUUID(string: "180D"))
            } else {
                if let _peripheral = peripheral {
                    connect(toPeripheral: _peripheral)
                }
            }
        case CBManagerState.poweredOff:
            print("\(central.description) is power off")
            print("Make sure bluetooth is on")
            delegate?.bluetoothIsPoweredOff()
        default:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Discover \(peripheral.name ?? "None Name")")
        connectedPeripherals.append(peripheral)
        connect(toPeripheral: peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("\(central) is connected to \(peripheral)")
        peripheral.delegate = self
        delegate?.didConnectTo(Peripheral: peripheral)
        discoverService(withServiceUUID: CBUUID(string: "180d"))
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("\(central) failed to connect to \(peripheral.name ?? "None Name")")
        print("Try to reconnect in 5 secs")
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if let _peripheral = self.peripheral {
                self.connect(toPeripheral: _peripheral)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("\(central) is diconnected to \(peripheral.name ?? "No Name")")
        print("Try to reconnect")
        delegate?.didDisconnectedWith(Peripheral: peripheral)
        connect(toPeripheral: peripheral)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let err = error {
            print("Set notification for \(characteristic) of \(peripheral.name ?? "No name") fail")
            print(err)
        }
        
        print("Set notification for \(characteristic) of \(peripheral.name ?? "No name") success")

    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value {
            measurement = data.swapData().withUnsafeBytes({(ptr: UnsafePointer<Float32>) -> Float32 in
                let m = ptr.pointee
                return m
            })
        }
        print(measurement)
        delegate?.didMeasurementUpdate(measurement)
        print(characteristic.value?.hexDescription ?? "Error")
    }
    
}

extension BluetoothModel: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let err = error {
            print("service discovering fail: \(err)")
            return
        }
        
        print("service discovering success")
        print("\(peripheral.name ?? "No Name") has service:")
        discoverCharacteristic(withCharacteristicUUID: CBUUID(string: "2A37"), forService: peripheral.services![0])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let err = error {
            print("characteristic discovering fail: \(err)")
            return
        }
        
        print("characteristic discovering success")
        if let characteristics = service.characteristics {
            print(characteristics)
            rxCharacteristic = characteristics[0]
            peripheral.setNotifyValue(true, for: rxCharacteristic!)
        }
        
    }
    
}

extension Data {
    var hexDescription: String {
        return reduce("") {$0 + String(format: "%02x", $1)}
    }
    
    func swapData() -> Data {
        var mdata = self // make a mutable copy
        let count = self.count / MemoryLayout<UInt8>.size
        mdata.withUnsafeMutableBytes { (i8ptr: UnsafeMutablePointer<UInt8>) in
            for i in 0..<(count/2) {
                let tmp = i8ptr[i]
                i8ptr[i] =  i8ptr[count - i - 1]
                i8ptr[count - i - 1] = tmp
            }
        }
        print(self.hexDescription)
        print(mdata.hexDescription)
        return mdata
    }
}
