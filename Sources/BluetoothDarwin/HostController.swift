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

public final class HostController: BluetoothHostControllerInterface {
    
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
        
        let (_, headerData) = HCICommandHeader.from(commandParameter)
        let commandParameterData = Data(headerData + commandParameter.byteValue)
        var returnParameterData = Data()
        
        try HCISendRequest(command: T.command,
                           commandParameterData: commandParameterData,
                           returnParameterData: &returnParameterData,
                           timeout: 0)
    }
    
    public func deviceRequest<C: HCICommand>(_ command: C, timeout: Int = HCI.defaultTimeout) throws {
        
        let commandParameterData = Data()
        var returnParameterData = Data()
            
        try HCISendRequest(command: command,
                           commandParameterData: commandParameterData,
                           returnParameterData: &returnParameterData,
                           timeout: timeout)
    }
    
    public func deviceRequest<CP>(_ commandParameter: CP, timeout: Int = HCI.defaultTimeout) throws where CP : HCICommandParameter {
            
        let commandParameterData = Data(commandParameter.byteValue)
        var returnParameterData = Data()
        
        try HCISendRequest(command: CP.command,
                           commandParameterData: commandParameterData,
                           returnParameterData: &returnParameterData,
                           timeout: timeout)
    }
    
    public func deviceRequest<CP, EP>(commandParameter: CP, eventParameterType: EP.Type, timeout: Int = HCI.defaultTimeout) throws -> EP
        where CP : HCICommandParameter, EP : HCIEventParameter {
            
            fatalError("not implemented")
    }
    
    public func deviceRequest <Return: HCICommandReturnParameter> (_ commandReturnType: Return.Type, timeout: Int = HCI.defaultTimeout) throws -> Return {
        
        let commandParameterData = Data()
        var returnParameterData = Data(count: commandReturnType.length)
        
        try HCISendRequest(command: Return.command,
                           commandParameterData: commandParameterData,
                           returnParameterData: &returnParameterData,
                           timeout: timeout)
        
        guard let response = Return.init(byteValue: [UInt8](returnParameterData))
            else { throw BluetoothHostControllerError.garbageResponse(returnParameterData) }
        
        return response
    }
}

public extension HostController {
    
    public struct DarwinError: Swift.Error {
        
        public let errorCode: CInt
        
        internal init(errorCode: CInt) {
            
            assert(errorCode != 0)
            
            self.errorCode = errorCode
        }
    }
}

