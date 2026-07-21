// swift-tools-version: 5.9

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "TailorResume",
    platforms: [
        .iOS("17.0")
    ],
    products: [
        .iOSApplication(
            name: "TailorResume",
            targets: ["TailorResumeApp"],
            bundleIdentifier: "com.emilytanis.tailorresume",
            teamIdentifier: "",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .document),
            accentColor: .presetColor(.blue),
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
            name: "TailorResumeApp",
            path: "Sources/TailorResumeApp"
        )
    ]
)
