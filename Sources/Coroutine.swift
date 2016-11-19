//
//  Coroutine.swift
//  SwiftCoro
//
//  Created by Yuki Takei on 2016/11/13.
//
//

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

import CLibcoro

private class Scheduler {
    static let shared = Scheduler()
    
    let main: Coro
    
    var current: Coro
    
    init(){
        main = try! Coro()
        main.identifier = "main"
        current = main
    }
}

public class Coroutine<T> {
    
    var _coroutine: Coro?
    
    var coroutine: Coro {
        return _coroutine!
    }
    
    fileprivate var back: Coro?
    
    fileprivate var value: T?
    
    public init(_ routine: @escaping ((T) -> Void) -> Void){
        do {
            self._coroutine = try Coro { [unowned self] _ in
                let yield: (T) -> Void = {
                    self.value = $0
                    self.coroutine.transfer(self.back!)
                }
                routine(yield)
            }
        } catch {
            fatalError("\(error)")
        }
    }
    
    public static func resume<T>(_ coro: Coroutine<T>) -> T {
        coro.back = Scheduler.shared.current
        
        Scheduler.shared.current = coro.coroutine
        
        coro.back?.transfer(Scheduler.shared.current)
        
        Scheduler.shared.current = coro.back!
        
        return coro.value!
    }
}
