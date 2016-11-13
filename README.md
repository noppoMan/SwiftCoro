# SwiftCoro

A tiny coroutine library for Swift

## Installation
```swift
import PackageDescription

let package = Package(
    dependencies: [
        .Package(url: "https://github.com/noppoMan/SwiftCoro.git", majorVersion: 0, minor: 1)
    ]
)
```

## Usage

```swift
func doSomething() {
    print("did something")
}

co(doSomething())

co {
  print("did something")
}

co {
  co {
    print("did something in the nested coroutine")
  }
}

print("All done")
```


## License
This project is released under the MIT license.
