// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DittoChatPackage",
    platforms: [ .iOS(.v17) ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "DittoChatPackage",
            targets: ["DittoChatPackage"]),
    ],
    dependencies: [
        .package(url: "https://github.com/getditto/DittoSwiftPackage", from: "4.0.0"),
        .package(url: "https://github.com/getditto/DittoSwiftTools", from: "4.0.0"),
        .package(url: "https://github.com/twostraws/CodeScanner", from: "2.0.0"),
        .package(url: "https://github.com/vadymmarkov/Fakery", from: "5.0.0"),
        .package(url: "https://github.com/apple/swift-collections", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "DittoChatPackage",
            dependencies: [
                .product(name: "DittoSwift", package: "DittoSwiftPackage"),
                .product(name: "DittoPresenceViewer", package: "DittoSwiftTools"),
                .product(name: "DittoDataBrowser", package: "DittoSwiftTools"),
                .product(name: "DittoExportLogs", package: "DittoSwiftTools"),
                .product(name: "DittoDiskUsage", package: "DittoSwiftTools"),
                .product(name: "DittoExportData", package: "DittoSwiftTools"),
                .product(name: "DittoPeersList", package: "DittoSwiftTools"),
                .product(name: "CodeScanner", package: "CodeScanner"),
                .product(name: "Fakery", package: "Fakery"),
                .product(name: "OrderedCollections", package: "swift-collections"),
            ]
        ),
        .testTarget(
            name: "DittoChatPackageTests",
            dependencies: ["DittoChatPackage"]),
    ]
)
