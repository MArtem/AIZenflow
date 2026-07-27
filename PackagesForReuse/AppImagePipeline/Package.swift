// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AppImagePipeline",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(name: "AppImagePipeline", targets: ["AppImagePipeline"])
    ],
    targets: [
        .target(name: "AppImagePipeline"),
        .testTarget(name: "AppImagePipelineTests", dependencies: ["AppImagePipeline"])
    ]
)
