import PackageDescription

let package = Package(
    name: "SwiftCoro",
    dependencies: [
        .Package(url: "https://github.com/noppoMan/CLibcoro", majorVersion: 0, minor: 1),
    ]
)
