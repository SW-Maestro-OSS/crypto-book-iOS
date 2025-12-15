import ProjectDescription

let projectName = "CryptoBook"
let organizationName = "io.tuist"

// MARK: - Project

let project = Project(
    name: projectName,
    organizationName: organizationName,
    packages: [
        .remote(url: "https://github.com/hmlongco/Factory.git", requirement: .upToNextMajor(from: "2.5.1")),
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
                .package(product: "ComposableArchitecture"),
                .package(product: "Factory")
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
        .target(
            name: "Entity",
            destinations: .iOS,
            product: .framework,
            bundleId: "\(organizationName).Entity",
            deploymentTargets: .iOS("16.0"),
            sources: ["Targets/Entity/Sources/**"],
            dependencies: []
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
            dependencies: [
                .target(name: "Entity")
            ]
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
                .target(name: "Entity"),
                .target(name: "Infra"),
                .package(product: "Factory")
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
