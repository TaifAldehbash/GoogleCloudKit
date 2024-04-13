// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GoogleCloudKit",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "GoogleCloudKit",
            targets: ["GoogleCloudKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "8.0.0"),
        .package(url: "http://github.com/firebase/firebaseui-ios", .upToNextMajor(from: "12.0.0")),
        .package(url: "https://github.com/Alamofire/Alamofire.git", branch: "master"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", branch: "master")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "GoogleCloudKit",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAuthUI", package: "firebaseui-ios"),
                .product(name: "Alamofire", package: "alamofire"),
                .product(name: "SwiftyJSON", package: "swiftyjson")
            ]
        ),
        .testTarget(
            name: "GoogleCloudKitTests",
            dependencies: ["GoogleCloudKit"]),
    ]
)
