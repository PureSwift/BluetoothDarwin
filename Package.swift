// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "BluetoothDarwin",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .watchOS(.v6),
        .tvOS(.v13),
    ],
    products: [
        .library(
            name: "BluetoothDarwin",
            targets: ["BluetoothDarwin"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/PureSwift/Bluetooth.git",
            .branch("feature/async")
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
