// swift-tools-version: 5.9

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "Align",
    platforms: [
        .iOS("17.0")
    ],
    products: [
        .iOSApplication(
            name: "Align",
            targets: ["AlignApp"],
            bundleIdentifier: "com.emilytanis.align",
            teamIdentifier: "",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .asset("AppIcon"),
            accentColor: .asset("AccentColor"),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AlignApp",
            path: "Sources/AlignApp",
            resources: [
                .process("Assets.xcassets")
            ]
        )
    ]
)
