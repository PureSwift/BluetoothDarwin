//
//  BluetoothDarwin.swift
//  PureSwift
//
//  Created by Alsey Coleman Miller on 3/25/18.
//  Copyright © 2018 PureSwift. All rights reserved.
//

import Foundation
import IOBluetooth
import CBluetoothDarwin
import Bluetooth

/// Returns event parameter data.
internal func HCISendRequest <Command: HCICommand> (command: Command,
                                                    commandParameterData: [UInt8],
                                                    returnParameterData: inout [UInt8],
                                                    timeout: Int) throws {
    
    let commandHeader = HCICommandHeader(command: command, parameterLength: UInt8(commandParameterData.count))
    let commandRawData = commandHeader.byteValue + commandParameterData
    
    var request: BluetoothHCIRequestID = 0
    var error: CInt = 0
    
    error = BluetoothHCIRequestCreate(&request, CInt(timeout), nil, 0)
    
    guard error == 0
        else { throw HostController.DarwinError(errorCode: error) }
    
    assert(request != 0)
    
    error = BluetoothHCISendRawCommand(request: request, commandData: commandRawData, returnParameter: &returnParameterData)
    
    guard error == 0
        else { throw HostController.DarwinError(errorCode: error) }
    
    if timeout > 0 {
        
        usleep(useconds_t(timeout))
    }
    
    BluetoothHCIRequestDelete(request)
}

/// IOBluetoothHostController::SendRawHCICommand(unsigned int, char*, unsigned int, unsigned char*, unsigned int)
internal func BluetoothHCISendRawCommand(request: BluetoothHCIRequestID,
                                       commandData: [UInt8],
                                       returnParameter outputData: inout [UInt8]) -> CInt {
    
    assert(commandData.isEmpty == false)
    assert(request != 0)
    
    var request = request
    let commandData = commandData
    var commandSize = commandData.count
    var returnParameterSize = outputData.count
    
    var dispatchParameters = IOBluetoothHCIDispatchParams()
    
    withUnsafePointer(to: &request, {
        dispatchParameters.args.0 = UInt64(uintptr_t(bitPattern: $0))
    })
    commandData.withUnsafeBufferPointer {
        if let address = $0.baseAddress {
            dispatchParameters.args.1 = UInt64(uintptr_t(bitPattern: address))
        }
    }
    withUnsafePointer(to: &commandSize, {
        dispatchParameters.args.2 = UInt64(uintptr_t(bitPattern: $0))
    })
    
    dispatchParameters.sizes.0 = UInt64(MemoryLayout<UInt32>.size) // sizeof(uint32);
    dispatchParameters.sizes.1 = UInt64(commandSize)
    dispatchParameters.sizes.2 = UInt64(MemoryLayout<uintptr_t>.size) // sizeof(uintptr_t);
    dispatchParameters.index = 0x000060c000000062 // Method ID
    
    return BluetoothHCIDispatchUserClientRoutine(&dispatchParameters, &outputData, &returnParameterSize)
}
