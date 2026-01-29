import ProjectDescription

let projectName = "CryptoBook"
let organizationName = "io.tuist"

let appSettings: Settings = .settings(
    base: [
        "MARKETING_VERSION": "1.0",
        "CURRENT_PROJECT_VERSION": "1"
    ],
    configurations: [
        .debug(name: "Debug", xcconfig: "Configs/Secrets.xcconfig"),
        .release(name: "Release", xcconfig: "Configs/Secrets.xcconfig")
    ]
)

// MARK: - Project

let project = Project(
    name: projectName,
    organizationName: organizationName,
    packages: [
        .remote(url: "https://github.com/hmlongco/Factory.git", requirement: .upToNextMajor(from: "2.5.1")),
        .remote(url: "https://github.com/pointfreeco/swift-composable-architecture.git", requirement: .upToNextMajor(from: "1.23.1"))
    ],
    settings: appSettings,
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
                    "API_KEY": "$(API_KEY)",
                    "CRYPTOPANIC_API_KEY": "$(CRYPTOPANIC_API_KEY)",
                    "GEMINI_API_KEY": "$(GEMINI_API_KEY)",
                    "NSAppTransportSecurity": .dictionary([
                        "NSExceptionDomains": .dictionary([
                            "www.koreaexim.go.kr": .dictionary([
                                "NSIncludesSubdomains": .boolean(true),
                                "NSExceptionRequiresForwardSecrecy": .boolean(false),
                                "NSExceptionMinimumTLSVersion": .string("TLSv1.2")
                            ])
                        ])
                    ])
                ]
            ),
            sources: ["Targets/App/Sources/**"],
            resources: ["Targets/App/Resources/**"],
            dependencies: [
                .target(name: "Domain"),
                .target(name: "Data"),
                .target(name: "Infra"),
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
            sources: ["Targets/Data/Sources/**"],
            dependencies: [
                .target(name: "Domain"),
                .target(name: "Entity"),
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
            dependencies: [
                .target(name: "Data")
            ]
        )
    ]
)
