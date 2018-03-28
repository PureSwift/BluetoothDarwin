//
//  BluetoothDarwinTests.swift
//  PureSwift
//
//  Created by Alsey Coleman Miller on 3/25/18.
//  Copyright © 2018 PureSwift. All rights reserved.
//

import Foundation
import XCTest
import IOBluetooth
import Bluetooth
import BluetoothDarwin
import CBluetoothDarwin

final class BluetoothDarwinTests: XCTestCase {
    
    static var allTests = [
        ("testReadName", testReadName),
        ]
    
    func testReadName() {
        
        guard let controller = HostController.default
            else { XCTFail("No Bluetooth hardware availible"); return }
        
        do {
            
            let localName = try controller.readLocalName()
            
            print("Local name: \(localName)")
            
            XCTAssert(localName.isEmpty == false, "Should not have empty name")
            
            XCTAssert(localName == IOBluetoothHostController.default().nameAsString())
        }
        
        catch { XCTFail("Error: \(error)") }
    }
    
    func testLEScan() {
        
        guard let hciController = IOBluetoothHostController.default()
            else { return }
        
        guard hciController.lowEnergySupported()
            else { return }
        
        hciController.bluetoothHCILESetScanEnable(0, filterDuplicates: 0)
        hciController.bluetoothHCILESetScanParameters(0, leScanInterval: 0x01E0, leScanWindow: 0x0030, ownAddressType: 0, scanningFilterPolicy: 0)
        hciController.bluetoothHCILESetScanEnable(1, filterDuplicates: 1)
        defer { hciController.bluetoothHCILESetScanEnable(0, filterDuplicates: 0) }
        
        class HCIDelegate: NSObject {
            
            @objc(BluetoothHCIEventNotificationMessage:inNotificationMessage:)
            func bluetoothHCIEventNotificationMessage(_ controller: IOBluetoothHostController,
                                                      in message: UnsafePointer<IOBluetoothHCIEventNotificationMessage>) {
                
                print(#function, message)
            }
        }
        
        let hciDelegate = HCIDelegate()
        hciController.delegate = hciDelegate
        
        sleep(10)
        
        
    }
}
