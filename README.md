# SwiftCoro

A tiny coroutine implementation for Swift

# ⚠️
SwiftCoro is in early development and pretty experimental So Don't use this in your project.

Currently, objects used in coroutines are not freed because we use coro_transfer(setjmp/longjmp) in the C world before reaching the tail of the function in Swift world.(ARC would work if the function call is finished)

## Usage

### The Basic

Make a coroutine and `resume` it then context is switched to it and enters an anonymous function.
By calling `yield` in anonymous function, you interrupt the execution of the coroutine and back to the next line of the previous `resume`.
Also if you call `resume` again the coroutine is executed from the next line of the previous `yield`.

```swift
let co = Coroutine<Int> { yield in
    yield(1)
    yield(2)
    yield(3)
}

Coroutine<Int>.resume(co) // => 1
Coroutine<Int>.resume(co) // => 2
Coroutine<Int>.resume(co) // => 3
```

### Coro(Low API)

You can use the low layer api of SwiftCoro that allows you to manually managed context switch.  
In the following code, three coroutines are context switched and executed sequentially.

```swift
private let _main = try! Coro()  //main coroutine

let coro3 = try! Coro { c in
    print("coro3: 1")
    c.transfer(_main) // goto _main:2

    print("coro3: 2")
    c.transfer(_main)  // goto done
}

let coro2 = try! Coro { c in
    print("coro2: 1")
    c.transfer(coro3) // goto coro3:1

    print("coro2: 2")
    c.transfer(coro3) // goto coro3:2
}

let coro1 = try! Coro { c in
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
