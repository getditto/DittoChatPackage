// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DittoChatPackage",
    platforms: [ .iOS(.v16), .tvOS(.v17) ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "DittoChatCore",
            targets: ["DittoChatCore"]),
        .library(
            name: "DittoChatUI",
            targets: ["DittoChatUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/getditto/DittoSwiftPackage", from: "4.8.0"),
        .package(url: "https://github.com/vadymmarkov/Fakery", from: "5.0.0"),
        .package(url: "https://github.com/apple/swift-collections", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "DittoChatCore",
            dependencies: [
                .product(name: "DittoSwift", package: "DittoSwiftPackage"),
                .product(name: "Fakery", package: "Fakery"),
                .product(name: "OrderedCollections", package: "swift-collections"),
            ]
        ),
        .target(
            name: "DittoChatUI",
            dependencies: ["DittoChatCore"]
               ),
        .testTarget(
            name: "DittoChatPackageTests",
            dependencies: ["DittoChatCore"]),
    ]
)
