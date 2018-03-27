//
//  Adapter.swift
//  BluetoothDarwin
//
//  Created by Alsey Coleman Miller on 3/25/18.
//  Copyright © 2018 PureSwift. All rights reserved.
//

import Foundation
import IOBluetooth
import CBluetoothDarwin
import Bluetooth

@objc(BluetoothHostController)
public final class HostController: NSObject, BluetoothHostControllerInterface {
    
    // MARK: - Properties
    
    internal let controller: IOBluetoothHostController
    
    public let address: Bluetooth.Address
    
    // MARK: - Initialization
    
    private init(_ controller: IOBluetoothHostController) {
        
         let addressString = controller.addressAsString().uppercased()
        
        guard let address = Address(rawValue: addressString)
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
    
        let commandParameterData = [UInt8]()
        var returnParameterData = [UInt8]()
        
        try HCISendRequest(command: command,
                           commandParameterData: commandParameterData,
                           returnParameterData: &returnParameterData,
                           timeout: 0)
    }
    
    public func deviceCommand<T: HCICommandParameter>(_ commandParameter: T) throws {
        
        let commandParameterData = commandParameter.byteValue
        var returnParameterData = [UInt8]()
        
        try HCISendRequest(command: T.command,
                           commandParameterData: commandParameterData,
                           returnParameterData: &returnParameterData,
                           timeout: 0)
    }
    
    public func deviceRequest<C: HCICommand>(_ command: C, timeout: Int = HCI.defaultTimeout) throws {
        
        let commandParameterData = [UInt8]()
        var returnParameterData = [UInt8]()
            
        try HCISendRequest(command: command,
                           commandParameterData: commandParameterData,
                           returnParameterData: &returnParameterData,
                           timeout: timeout)
    }
    
    public func deviceRequest<CP>(_ commandParameter: CP, timeout: Int = HCI.defaultTimeout) throws where CP : HCICommandParameter {
            
        let commandParameterData = commandParameter.byteValue
        var returnParameterData = [UInt8]()
        
        try HCISendRequest(command: CP.command,
                           commandParameterData: commandParameterData,
                           returnParameterData: &returnParameterData,
                           timeout: timeout)
    }
    
    public func deviceRequest<CP, EP>(commandParameter: CP, eventParameterType: EP.Type, timeout: Int = HCI.defaultTimeout) throws -> EP where CP : HCICommandParameter, EP : HCIEventParameter {
        
        fatalError("not implemented")
    }
    
    public func deviceRequest <Return: HCICommandReturnParameter> (_ commandReturnType: Return.Type, timeout: Int = HCI.defaultTimeout) throws -> Return {
        
        let commandParameterData = [UInt8]()
        var returnParameterData = [UInt8](repeating: 0, count: commandReturnType.length)
        
        try HCISendRequest(command: Return.command,
                           commandParameterData: commandParameterData,
                           returnParameterData: &returnParameterData,
                           timeout: timeout)
        
        guard let response = Return.init(byteValue: [UInt8](returnParameterData))
            else { throw BluetoothHostControllerError.garbageResponse(Data(returnParameterData)) }
        
        return response
    }
    
    public func pollEvent<T: HCIEventParameter >(_ eventParameterType: T.Type,
                                                 shouldContinue: () -> (Bool),
                                                 event: (T) throws -> ()) throws {
        
        fatalError("Not implemented")
    }
    
    @objc(controllerHCIEvent:message:)
    func controllerHCIEvent(_ controller: IOBluetoothHostController, message: CUnsignedInt) {
        
        print(#function, message)
    }
    
    @objc(controllerNotification:message:)
    func controllerNotification(_ controller: IOBluetoothHostController, message: CUnsignedInt) {
        
        print(#function, message)
    }
    
    @objc(BluetoothHCIEventNotificationMessage:inNotificationMessage:)
    func bluetoothHCIEventNotificationMessage(_ controller: IOBluetoothHostController,
                                              in message: UnsafePointer<IOBluetoothHCIEventNotificationMessage>) {
        
        print(#function, message)
    }
}

// MARK: - Errors

public extension HostController {
    
    public typealias Error = BluetoothHostControllerError
}

public extension HostController {
    
    public struct DarwinError: Swift.Error {
        
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
