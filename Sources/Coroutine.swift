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

var _id = 0

fileprivate final class Box<A> {
    let unbox: A
    init(_ value: A) { unbox = value }
}

public class Coroutine {
    
    let id: Int
    
    let context: CoroContext
    
    let stack: CoroStack
    
    private var routine: ((Coroutine) -> Void)?
    
    public init(stackSize: UInt32 = 0, routine: @escaping (Coroutine) -> Void) throws {
        _id+=1
        self.id = _id
        self.routine = routine
        context = CoroContext()
        stack = CoroStack()
        try stack.alloc(stackSize: stackSize)
        
        let corofn: @convention(c) (UnsafeMutableRawPointer?) -> Void = { ptr in
            let c = Unmanaged<Coroutine>.fromOpaque(ptr!).takeRetainedValue()
            c.routine?(c)
        }
        
        let arg = Unmanaged.passRetained(self).toOpaque()
        create(coro: corofn, arg: arg, stack: stack)
    }
    
    public init(_ context: CoroContext, _ stack: CoroStack) {
        _id+=1
        self.id = _id
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

extension Coroutine: CustomStringConvertible {
    public var description: String {
        return "id: \(id)"
    }
}

extension Coroutine: Equatable {}

public func ==(lhs: Coroutine, rhs: Coroutine) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}
