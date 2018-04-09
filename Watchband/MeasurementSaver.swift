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
    
    override init() {
        dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    func saveMeasurement(_ measurement: Measurement, toFile fileName:String) -> Bool {
        
        let fileUrl = dir!.appendingPathComponent(fileName)
        if let outputStream = OutputStream(url: fileUrl, append: true) {
            outputStream.open()
            let text = "\(measurement)\n"
            if outputStream.write(text, maxLength: text.count) < 0 {
                print("Write failure")
                outputStream.close()
                return false
            }
            outputStream.close()
        } else {
            print("Unable to open file")
            return false
        }
        return true
    }
}
