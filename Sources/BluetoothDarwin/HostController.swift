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
import BluetoothHCI

@objc(BluetoothHostController)
public final class HostController: NSObject, BluetoothHostControllerInterface {
    
    // MARK: - Properties
    
    internal let controller: IOBluetoothHostController
    
    internal var hciEvent: (([UInt8]) -> ())?
    
    // MARK: - Initialization
    
    private init(_ controller: IOBluetoothHostController) {
        
        self.controller = controller
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
    
    /// The current controller's power state.
    ///
    /// - Note: Only Apple Bluetooth adapters support power off.
    public var powerState: PowerState {
        guard let powerState = PowerState(rawValue: numericCast(controller.powerState.rawValue)) else {
            assertionFailure("Invalid power state \(controller.powerState.rawValue)")
            return .unintialized
        }
        return powerState
    }
    
    /// The current controller's power state.
    /// 
    /// - Note: Only Apple Bluetooth adapters support power off.
    public func setPowerState(_ isOn: Bool) throws {
        
        let errorCode = controller.setPowerState(isOn ? 1 : 0)
        guard errorCode == 0
            else { throw BluetoothDarwinError.hciError(errorCode) }
    }
    
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
    
    public func recieve<Event>(
        _ eventType: Event.Type
    ) throws -> Event where Event : HCIEventParameter, Event.HCIEventType == HCIGeneralEvent {
        
        fatalError("Not implemented")
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
    
    enum PowerState: UInt8 {
        
        case off = 0x00
        case on = 0x01
        case unintialized = 0xFF
    }
}
