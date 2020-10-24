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
import BluetoothHCI

/// Returns event parameter data.
internal func HCISendRequest <Command: HCICommand> (command: Command,
                                                    commandParameterData: Data,
                                                    returnParameterData: inout Data,
                                                    timeout: HCICommandTimeout = .default) throws {
    
    let commandHeader = HCICommandHeader(command: command, parameterLength: UInt8(commandParameterData.count))
    let commandRawData = commandHeader.data + commandParameterData
    
    var request: BluetoothHCIRequestID = 0
    var error: CInt = 0
    
    error = BluetoothHCIRequestCreate(&request, CInt(timeout.rawValue), nil, 0)
    
    guard error == 0
        else { throw BluetoothDarwinError(errorCode: error) }
    
    assert(request != 0)
    
    error = BluetoothHCISendRawCommand(request: request, commandData: commandRawData, returnParameter: &returnParameterData)
    
    guard error == 0
        else { throw BluetoothDarwinError.hciError(error) }
    
    BluetoothHCIRequestDelete(request)
}

/// IOBluetoothHostController::SendRawHCICommand(unsigned int, char*, unsigned int, unsigned char*, unsigned int)
internal func BluetoothHCISendRawCommand(request: BluetoothHCIRequestID,
                                         commandData: Data,
                                         returnParameter outputData: inout Data) -> CInt {
    
    assert(commandData.isEmpty == false)
    assert(request != 0)
    
    var request = request
    let commandData = commandData as NSData
    var commandSize = commandData.length
    var returnParameterSize = outputData.count
    
    var dispatchParameters = IOBluetoothHCIDispatchParams()
    
    withUnsafePointer(to: &request, {
        dispatchParameters.args.0 = UInt64(uintptr_t(bitPattern: $0))
    })
    
    dispatchParameters.args.1 = UInt64(uintptr_t(bitPattern: commandData.bytes))
    
    withUnsafePointer(to: &commandSize, {
        dispatchParameters.args.2 = UInt64(uintptr_t(bitPattern: $0))
    })
    
    dispatchParameters.sizes.0 = UInt64(MemoryLayout<UInt32>.size) // sizeof(uint32);
    dispatchParameters.sizes.1 = UInt64(commandSize)
    dispatchParameters.sizes.2 = UInt64(MemoryLayout<uintptr_t>.size) // sizeof(uintptr_t);
    dispatchParameters.index = 0x000060c000000062 // Method ID
    
    return outputData.withUnsafeMutableBytes {
        BluetoothHCIDispatchUserClientRoutine(
            &dispatchParameters,
            $0.baseAddress!.assumingMemoryBound(to: UInt8.self),
            &returnParameterSize
        )
    }
}
