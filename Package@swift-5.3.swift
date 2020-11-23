// swift-tools-version:5.3
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
                .product(
                    name: "Bluetooth",
                    package: "Bluetooth"
                ),
                .product(
                    name: "BluetoothHCI",
                    package: "Bluetooth"
                ),
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
