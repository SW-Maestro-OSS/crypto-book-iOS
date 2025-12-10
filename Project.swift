import ProjectDescription

let projectName = "CryptoBook"
let organizationName = "io.tuist"

// MARK: - Project

let project = Project(
    name: projectName,
    organizationName: organizationName,
    packages: [
        .remote(url: "https://github.com/pointfreeco/swift-composable-architecture.git", requirement: .upToNextMajor(from: "1.23.1"))
    ],
    targets: [
        // App
        .target(
            name: "CryptoBookApp",
            destinations: .iOS,
            product: .app,
            bundleId: "\(organizationName).\(projectName)App",
            deploymentTargets: .iOS("16.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["Targets/App/Sources/**"],
            resources: ["Targets/App/Resources/**"],
            dependencies: [
                .target(name: "Domain"),
                .target(name: "Data"),
                .package(product: "ComposableArchitecture")
            ]
        ),
        // App Tests
        .target(
            name: "CryptoBookAppTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "\(organizationName).\(projectName)AppTests",
            deploymentTargets: .iOS("16.0"),
            infoPlist: .default,
            sources: ["Targets/App/Tests/**"],
            dependencies: [
                .target(name: "CryptoBookApp")
            ]
        ),
        // Domain
        .target(
            name: "Domain",
            destinations: .iOS,
            product: .framework,
            bundleId: "\(organizationName).Domain",
            deploymentTargets: .iOS("16.0"),
            infoPlist: .default,
            sources: ["Targets/Domain/Sources/**"],
            dependencies: []
        ),
        // Data
        .target(
            name: "Data",
            destinations: .iOS,
            product: .framework,
            bundleId: "\(organizationName).Data",
            deploymentTargets: .iOS("16.0"),
            infoPlist: .default,
            sources: ["Targets/Data/Sources/**"],
            dependencies: [
                .target(name: "Domain"),
                .target(name: "Infra")
            ]
        ),
        // Infra
        .target(
            name: "Infra",
            destinations: .iOS,
            product: .framework,
            bundleId: "\(organizationName).Infra",
            deploymentTargets: .iOS("16.0"),
            infoPlist: .default,
            sources: ["Targets/Infra/Sources/**"],
            dependencies: []
        )
    ]
)