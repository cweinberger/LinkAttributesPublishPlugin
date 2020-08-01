// swift-tools-version:5.2

import PackageDescription

let package = Package(
  name: "LinkAttributesPublishPlugin",
  products: [
    .library(
      name: "LinkAttributesPublishPlugin",
      targets: ["LinkAttributesPublishPlugin"]),
  ],
  dependencies: [
    .package(name: "Publish", url: "https://github.com/johnsundell/publish.git", from: "0.7.0"),
  ],
  targets: [
    .target(
      name: "LinkAttributesPublishPlugin",
      dependencies: ["Publish"]),
    .testTarget(
      name: "LinkAttributesPublishPluginTests",
      dependencies: ["LinkAttributesPublishPlugin"]),
  ]
)
