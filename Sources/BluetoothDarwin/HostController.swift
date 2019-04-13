//
//  Adapter.swift
//  BluetoothDarwin
//
//  Created by Alsey Coleman Miller on 3/25/18.
//  Copyright © 2018 PureSwift. All rights reserved.
//

import Foundation
import IOBluetooth
import Darwin
import CBluetoothDarwin
import Bluetooth

@objc(BluetoothHostController)
public final class HostController: NSObject, BluetoothHostControllerInterface {
    
    // MARK: - Properties
    
    internal let controller: IOBluetoothHostController
    
    public let address: BluetoothAddress
    
    internal var hciEvent: (([UInt8]) -> ())?
    
    // MARK: - Initialization
    
    private init(_ controller: IOBluetoothHostController) {
        
        let addressString = controller.addressAsString().uppercased().replacingOccurrences(of: "-", with: ":")
        
        guard let address = BluetoothAddress(rawValue: addressString)
            else { fatalError("Invalid Bluetooth Address \(addressString)") }
        
        self.controller = controller
        self.address = address
        
        super.init()
        self.controller.delegate = self
    }
    
    public static var controllers: [HostController] {
        
        return IOBluetoothHostController.controllers().map { HostController($0) }
    }
    
    public static var `default`: HostController? {
        
        guard let controller = IOBluetoothHostController.default()
            else { return nil }
        
        return HostController(controller)
    }
    
    // MARK: - Methods
    
    public func deviceCommand<T>(_ command: T) throws where T : HCICommand {
    
        let commandParameterData = Data()
        var returnParameterData = Data()
        
        try HCISendRequest(command: command,
                           commandParameterData: commandParameterData,
                           returnParameterData: &returnParameterData,
                           timeout: 0)
    }
    
    public func deviceCommand<T: HCICommandParameter>(_ commandParameter: T) throws {
        
        let commandParameterData = commandParameter.data
        var returnParameterData = Data()
        
        try HCISendRequest(command: T.command,
                           commandParameterData: commandParameterData,
                           returnParameterData: &returnParameterData,
                           timeout: 0)
    }
    
    public func deviceRequest<C: HCICommand>(_ command: C, timeout: HCICommandTimeout = .default) throws {
        
        let commandParameterData = Data()
        var returnParameterData = Data()
            
        try HCISendRequest(command: command,
                           commandParameterData: commandParameterData,
                           returnParameterData: &returnParameterData,
                           timeout: timeout)
    }
    
    public func deviceRequest<CP>(_ commandParameter: CP, timeout: HCICommandTimeout = .default) throws where CP : HCICommandParameter {
            
        let commandParameterData = commandParameter.data
        var returnParameterData = Data()
        
        try HCISendRequest(command: CP.command,
                           commandParameterData: commandParameterData,
                           returnParameterData: &returnParameterData,
                           timeout: timeout)
    }
    
    public func deviceRequest<CP, EP>(_ commandParameter: CP, _ eventParameterType: EP.Type, timeout: HCICommandTimeout = .default) throws -> EP where CP : HCICommandParameter, EP : HCIEventParameter {
        
        fatalError("not implemented")
    }
    
    public func deviceRequest <Return: HCICommandReturnParameter> (_ commandReturnType: Return.Type, timeout: HCICommandTimeout = .default) throws -> Return {
        
        let commandParameterData = Data()
        var returnParameterData = Data(repeating: 0, count: commandReturnType.length)
        
        try HCISendRequest(command: Return.command,
                           commandParameterData: commandParameterData,
                           returnParameterData: &returnParameterData,
                           timeout: timeout)
        
        guard let response = Return.init(data: returnParameterData)
            else { throw BluetoothHostControllerError.garbageResponse(returnParameterData) }
        
        return response
    }
    
    public func deviceRequest<CP, Return>(_ commandParameter: CP, _ commandReturnType: Return.Type, timeout: HCICommandTimeout = .default) throws -> Return where CP : HCICommandParameter, Return : HCICommandReturnParameter {
        
        assert(CP.command.rawValue == Return.command.rawValue)
        
        let commandParameterData = commandParameter.data
        var returnParameterData = Data(repeating: 0, count: commandReturnType.length)
        
        try HCISendRequest(command: CP.command,
                           commandParameterData: commandParameterData,
                           returnParameterData: &returnParameterData,
                           timeout: timeout)
        
        guard let response = Return.init(data: returnParameterData)
            else { throw BluetoothHostControllerError.garbageResponse(Data(returnParameterData)) }
        
        return response
    }
    
    public func deviceRequest<C, EP>(_ command: C, _ eventParameterType: EP.Type, timeout: HCICommandTimeout) throws -> EP where C : HCICommand, EP : HCIEventParameter {
        
        fatalError("Not implemented")
    }
    
    public func pollEvent<T: HCIEventParameter >(_ eventParameterType: T.Type,
                                                 shouldContinue: () -> (Bool),
                                                 event: (T) throws -> ()) throws {
        
        var error: Error?
        
        self.hciEvent = { (eventMessage) in
            
            error = nil
        }
        
        while error == nil, shouldContinue() {
            
            sleep(1)
        }
        
        self.hciEvent = nil
        
        if let error = error {
            throw error
        }
    }
}

extension HostController: IOBluetoothHostControllerDelegate {
    
    @objc(controllerHCIEvent:message:)
    func controllerHCIEvent(_ controller: IOBluetoothHostController, message: CUnsignedInt) {
        
        //print(#function, message)
    }
    
    @objc(controllerNotification:message:)
    func controllerNotification(_ controller: IOBluetoothHostController, message: CUnsignedInt) {
        
        //print(#function, message)
    }
    
    @objc(BluetoothHCIEventNotificationMessage:inNotificationMessage:)
    public func bluetoothHCIEventNotificationMessage(_ controller: IOBluetoothHostController,
                                                     in message: IOBluetoothHCIEventNotificationMessageRef) {
        
        //print(#function)
        
        //let opcode = message.pointee.dataInfo.opcode
        
        //let data = IOBluetoothHCIEventParameterData(message)
        
        //print("HCI Event \(opcode):", data)
    }
}

// MARK: - Errors

public extension HostController {
    
    typealias Error = BluetoothHostControllerError
}

public extension HostController {
    
    struct DarwinError: Swift.Error {
        
        public let errorCode: CInt
        
        internal init(errorCode: CInt) {
            
            assert(errorCode != 0)
            
            self.errorCode = errorCode
        }
        
        internal static func hciError(_ errorCode: CInt) -> Swift.Error {
            
            if errorCode <= CInt(UInt8.max),
                let hciError = HCIError(rawValue: UInt8(errorCode)) {
                
                return hciError
                
            } else {
                
                return DarwinError(errorCode: errorCode)
            }
        }
    }
}
