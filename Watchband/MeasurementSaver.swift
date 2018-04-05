//
//  MeasurementSaver.swift
//  Watchband
//
//  Created by Xuannan Su on 3/29/18.
//  Copyright © 2018 Xuannan Su. All rights reserved.
//

import UIKit

struct Measurement: CustomStringConvertible {
    var time: String
    var value: Int32
    
    var description: String {
        return "\(time), \(value)"
    }
}

class MeasurementSaver: NSObject {
    var dir: URL?
    var fileUrl: URL?
    
    override init() {
        dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    func openFile(_ fileName: String) {
        if let _dir = dir {
            fileUrl = _dir.appendingPathComponent(fileName)
        } else {
            print("File open failed\n")
        }
    }
    
    func saveMeasurement(_ measurement: Measurement) -> Bool {
        do {
            if let _fileUrl = fileUrl {
                let text = "\(measurement)"
                try text.write(to: _fileUrl, atomically: false, encoding: .utf8)
            }
        } catch {
            print("Measurement save failed\n")
            return false
        }
        return true
    }
}
