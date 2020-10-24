//
//  Error.swift
//  BluetoothDarwin
//
//  Created by Alsey Coleman Miller on 4/30/19.
//

import Foundation
import BluetoothHCI

public struct BluetoothDarwinError: Swift.Error {
    
    public let errorCode: CInt
    
    internal init(errorCode: CInt) {
        assert(errorCode != 0)
        self.errorCode = errorCode
    }
}

internal extension BluetoothDarwinError {
    
    /// Attempt to handle error code as a HCI error, or as a kernel error.
    static func hciError(_ errorCode: CInt) -> Swift.Error {
        
        if errorCode <= CInt(UInt8.max),
            errorCode >= CInt(UInt8.min),
            let hciError = HCIError(rawValue: UInt8(errorCode)) {
            return hciError
        } else {
            return BluetoothDarwinError(errorCode: errorCode)
        }
    }
}
