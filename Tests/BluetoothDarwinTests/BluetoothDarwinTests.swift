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
    
    func testReadName() async {
        
        guard let controller = HostController.default
            else { XCTFail("No Bluetooth hardware availible"); return }
        
        do {
            
            let localName = try await controller.readLocalName()
            print("Local name: \(localName)")
            XCTAssert(localName.isEmpty == false, "Should not have empty name")
            XCTAssert(localName == IOBluetoothHostController.default().nameAsString())
        }
        catch { XCTFail("Error: \(error)") }
    }
    
    func testReadDeviceAddress() async {
        
        guard let controller = HostController.default
            else { XCTFail("No Bluetooth hardware availible"); return }
        
        do {
            
            let address = try await controller.readDeviceAddress()
            print("Address: \(address)")
            XCTAssertNotEqual(address, .zero)
            XCTAssertEqual(address.rawValue, IOBluetoothHostController.default()?.addressAsString()?.replacingOccurrences(of: "-", with: ":").uppercased())
        }
        catch { XCTFail("Error: \(error)") }
    }
    
    func testPowerState() async {
        
        guard let controller = HostController.default
            else { XCTFail("No Bluetooth hardware availible"); return }
        
        let powerState = controller.powerState
        print("Power State: \(powerState)")
        XCTAssertEqual(powerState, .on)
    }
}
