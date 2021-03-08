// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MyPackage",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "MyPackage",
            targets: ["MyPackage"]),
        .library(
            name: "MyPackageObjC",
            targets: ["MyPackageObjC"]),
        .library(
            name: "MyPackageSwift",
            targets: ["MyPackageSwift"]), 
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "MyPackage",
            dependencies: ["MyPackageSwift","MyPackageObjC"]),
        .target(
            name: "MyPackageObjC",
            dependencies: ["MyPackageSwift"]),
        .target(
            name: "MyPackageSwift",
            dependencies: []),
        .testTarget(
            name: "MyPackageTests",
            dependencies: ["MyPackageSwift", "MyPackageObjC"]),
    ]
)
