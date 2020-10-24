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
            .branch("master")
        )
    ],
    targets: [
        .target(
            name: "BluetoothDarwin",
            dependencies: [
                "Bluetooth",
                "BluetoothHCI",
                "CBluetoothDarwin"
            ]
        ),
        .target(
            name: "CBluetoothDarwin"
        ),
        .testTarget(
            name: "BluetoothDarwinTests",
            dependencies: [
                "BluetoothDarwin"
            ]
        )
    ]
)
