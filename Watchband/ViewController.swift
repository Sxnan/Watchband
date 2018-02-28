//
//  ViewController.swift
//  test
//
//  Created by Xuannan Su on 2/5/18.
//  Copyright © 2018 Xuannan Su. All rights reserved.
//

import UIKit


class ViewController: UIViewController{
    private var btmodel: BluetoothModel!
    
    @IBOutlet weak var measurement: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btmodel = BluetoothModel()
        btmodel.onMeasurementUpdate = {
            (_ measurement: UInt16) -> Void in
            self.measurement.text = "\(measurement)"
        }
    }
}


