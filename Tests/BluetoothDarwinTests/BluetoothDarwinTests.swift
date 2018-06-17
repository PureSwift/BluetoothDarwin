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
import CBluetoothDarwin
@testable import BluetoothDarwin

final class BluetoothDarwinTests: XCTestCase {
    
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
        
        guard let controller = HostController.default
            else { XCTFail("No Bluetooth hardware availible"); return }
        
        let hciController = controller.controller
        
        guard hciController.lowEnergySupported()
            else { return }
        
        class HCIDelegate: IOBluetoothHostControlllerDelegate {
            
            @objc(BluetoothHCIEventNotificationMessage:inNotificationMessage:)
            func bluetoothHCIEventNotificationMessage(_ controller: IOBluetoothHostController,
                                                      in message: UnsafePointer<IOBluetoothHCIEventNotificationMessage>) {
                
                print(#function, message)
            }
        }
        
        let hciDelegate = HCIDelegate()
        hciController.delegate = hciDelegate
        
        XCTAssertNoThrow(try controller.lowEnergyScan(duration: 10, filterDuplicates: true))
    }
}
