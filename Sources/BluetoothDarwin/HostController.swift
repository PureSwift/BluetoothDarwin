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
        
        guard let addressString = controller.addressAsString().uppercased()
            else { fatalError("Could not get Bluetooth address of controller") }
        
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
    
    public func deviceCommand<T>(_ command: T) throws
        where T : HCICommand {
            
            
    }
    
    public func deviceCommand<T>(_ commandParameter: T) throws
        where T : HCICommandParameter {
            
            
    }
    
    public func deviceRequest<C>(_ command: C, timeout: Int = HCI.defaultTimeout) throws
        where C : HCICommand {
            
        
    }
    
    public func deviceRequest<CP>(_ commandParameter: CP, timeout: Int = HCI.defaultTimeout) throws
        where CP : HCICommandParameter {
            
            
    }
    
    public func deviceRequest<CP, EP>(commandParameter: CP, eventParameterType: EP.Type, timeout: Int = HCI.defaultTimeout) throws -> EP
        where CP : HCICommandParameter, EP : HCIEventParameter {
            
            
    }
    
    public func deviceRequest<Return>(_ commandReturnType: Return.Type, timeout: Int = HCI.defaultTimeout) throws -> Return
        where Return : HCICommandReturnParameter {
            
        
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

