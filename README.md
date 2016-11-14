# SwiftCoro

A tiny coroutine implementation for Swift

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

In the following code, three coroutines are context switched and executed sequentially.

```swift
private let _main = try! Coroutine()  //main coroutine

let coro3 = try! Coroutine { c in
    print("coro3: 1")
    c.transfer(_main) // goto _main:2

    print("coro3: 2")
    c.transfer(_main)  // goto done
}

let coro2 = try! Coroutine { c in
    print("coro2: 1")
    c.transfer(coro3) // goto coro3:1

    print("coro2: 2")
    c.transfer(coro3) // goto coro3:2
}

let coro1 = try! Coroutine { c in
    print("coro1: 1")
    c.transfer(coro2) // goto coro2:1

    print("coro1: 2")
    c.transfer(coro2) // goto coro2:2
}

print("main: 1")
_main.transfer(coro1) // goto coro1:1

print("main: 2")
_main.transfer(coro1) // goto coro1:2

print("done")
```
*Result*
```
main: 1
coro1: 1
coro2: 1
coro3: 1
main: 2
coro1: 2
coro2: 2
coro3: 2
done
```

## License
This project is released under the MIT license.
