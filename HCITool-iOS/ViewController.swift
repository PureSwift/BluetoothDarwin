//
//  ViewController.swift
//  HCITool-iOS
//
//  Created by Alsey Coleman Miller on 3/25/18.
//  Copyright © 2018 PureSwift. All rights reserved.
//

import UIKit
import BluetoothDarwin
import CBluetoothDarwin
import CoreBluetooth
import ExternalAccessory

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var connectionAcceptTimeout: UInt16 = 0
        
        withUnsafeMutablePointer(to: &connectionAcceptTimeout) {
            
            IOBluetoothHostController.default().bluetoothHCIReadConnectionAcceptTimeout($0)
        }
        
        print("bluetoothHCIReadConnectionAcceptTimeout: \(connectionAcceptTimeout)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

