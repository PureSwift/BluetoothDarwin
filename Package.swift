// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "BluetoothDarwin",
    products: [
        .library(
            name: "BluetoothDarwin",
            targets: ["BluetoothDarwin"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/PureSwift/Bluetooth.git",
            .upToNextMinor(from: "4.2.0")
        )
    ],
    targets: [
        .target(name: "BluetoothDarwin", dependencies: ["Bluetooth", "CBluetoothDarwin"]),
        .target(name: "CBluetoothDarwin"),
        .testTarget(name: "BluetoothDarwinTests", dependencies: ["BluetoothDarwin"])
    ]
)
