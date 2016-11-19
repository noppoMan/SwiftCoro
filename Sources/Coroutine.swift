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

public class Scheduler {
    static let shared = Scheduler()
    
    var _main: Coro?
    
    var main: Coro {
        return _main!
    }
    
    var current: Coro?
    
    init(){
        _main = try! Coro()
        _main?.identifier = "main"
        current = _main
    }
    
    public static func terminate(){
        Scheduler.shared._main = nil
        Scheduler.shared.current = nil
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
            self._coroutine = try Coro { [unowned self] c in
                let yield: (T) -> Void = {
                    self.value = $0
                    c.transfer(self.back!)
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
        
        coro.back?.transfer(Scheduler.shared.current!)
        
        Scheduler.shared.current = coro.back
        
        return coro.value!
    }
    
    deinit {
        self.back = nil
        self._coroutine = nil
    }
}
