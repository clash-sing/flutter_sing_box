// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "flutter_sing_box",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "flutter-sing-box", targets: ["flutter_sing_box"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "flutter_sing_box",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
