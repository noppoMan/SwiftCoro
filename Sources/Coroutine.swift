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

public class Coroutine {
    
    let context: CoroContext
    
    let stack: CoroStack
    
    public init(stackSize: UInt32 = 0, arg: UnsafeMutableRawPointer? = nil, coro: @escaping coro_func) throws {
        context = CoroContext()
        stack = CoroStack()
        try stack.alloc(stackSize: stackSize)
        create(coro: coro, arg: arg, stack: stack)
    }
    
    public init(_ context: CoroContext, _ stack: CoroStack) {
        self.context = context
        self.stack = stack
    }
    
    public convenience init() throws {
        self.init(CoroContext(), CoroStack(sptr: nil, ssze: 0))
        create(stack: stack)
    }
    
    public func create(coro: @escaping coro_func, arg: UnsafeMutableRawPointer?, stack: CoroStack){
        coro_create(context.context, coro, arg, stack.stack.pointee.sptr, stack.stack.pointee.ssze)
    }
    
    public func create(stack: CoroStack){
        coro_create(context.context, nil, nil, stack.stack.pointee.sptr, stack.stack.pointee.ssze)
    }
    
    public func create(){
        coro_create(context.context, nil, nil, nil, 0)
    }
    
    public func transfer(_ next: Coroutine){
        swift_coro_transfer(context.context, next.context.context)
    }
}

extension Coroutine: Equatable {}

public func ==(lhs: Coroutine, rhs: Coroutine) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}
