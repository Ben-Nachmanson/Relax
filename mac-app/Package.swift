// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Relax",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "Relax", targets: ["Relax"]),
    ],
    targets: [
        .executableTarget(
            name: "Relax",
            path: "Sources/Relax"
        )
    ]
)
