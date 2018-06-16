// swift-tools-version:3.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BluetoothDarwin",
    targets: [
        Target(
            name: "BluetoothDarwin",
            dependencies: [
                .Target(name: "CBluetoothDarwin")
            ]),
        Target(
            name: "CBluetoothDarwin"),
        Target(
            name: "BluetoothDarwinTests",
            dependencies: [
                .Target(name: "BluetoothDarwin")
            ])
    ],
    dependencies: [
        .Package(url: "https://github.com/PureSwift/Bluetooth.git", majorVersion: 2)
    ]
)
