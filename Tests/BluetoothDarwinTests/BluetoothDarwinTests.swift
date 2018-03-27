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
        }
        
        catch { XCTFail("Error: \(error)") }
    }
}
