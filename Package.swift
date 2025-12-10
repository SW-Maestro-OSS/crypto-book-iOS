// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Dependencies",
    platforms: [.iOS(.v16)],
    products: [],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.23.1")
    ]
)
