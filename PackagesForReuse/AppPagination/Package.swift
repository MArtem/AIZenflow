// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AppPagination",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(name: "AppPagination", targets: ["AppPagination"])
    ],
    targets: [
        .target(name: "AppPagination"),
        .testTarget(name: "AppPaginationTests", dependencies: ["AppPagination"])
    ]
)
