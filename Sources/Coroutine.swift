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
    
    public init(_ routine: @escaping (Coroutine<T>) -> Void){
        do {
            self._coroutine = try Coro { [unowned self] c in
                routine(self)
            }
        } catch {
            fatalError("\(error)")
        }
    }
    
    public func yield(_ value: T) {
        self.value = value
        coroutine.transfer(back!)
    }
    
    public static func resume<T>(_ coro: Coroutine<T>) -> T {
        coro.back = Scheduler.shared.current
        
        Scheduler.shared.current = coro.coroutine
        
        coro.back?.transfer(Scheduler.shared.current)
        
        Scheduler.shared.current = coro.back!
        
        return coro.value!
    }
}
