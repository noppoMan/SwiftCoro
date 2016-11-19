//
//  Coro.swift
//  SwiftCoro
//
//  Created by Yuki Takei on 2016/11/13.
//
//

import CLibcoro

public class Coro {
    
    var context: CoroContext
    
    let stack: CoroStack
    
    var identifier: String? = nil
    
    var retainedSelf: Unmanaged<Coro>?
    
    private var routine: (((Coro) -> Void) -> Void)?
    
    public init(stackSize: UInt32 = 0, routine: @escaping ((Coro) -> Void) -> Void) throws {
        self.routine = routine
        context = CoroContext()
        stack = CoroStack()
        try stack.alloc(stackSize: stackSize)
        
        let corofn: @convention(c) (UnsafeMutableRawPointer?) -> Void = { ptr in
            let c = Unmanaged<Coro>.fromOpaque(ptr!).takeUnretainedValue()
            
            let transfer: (Coro) -> Void = { [weak c] next in
                c?.transfer(next)
            }
            
            c.routine?(transfer)
        }
        
        let arg = Unmanaged.passUnretained(self).toOpaque()
        create(coro: corofn, arg: arg, stack: stack)
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
        coro_create(&context.context, coro, arg, stack.stack.sptr, stack.stack.ssze)
    }
    
    public func create(stack: CoroStack){
        coro_create(&context.context, nil, nil, stack.stack.sptr, stack.stack.ssze)
    }
    
    public func create(){
        coro_create(&context.context, nil, nil, nil, 0)
    }
    
    public func transfer(_ next: Coro){
        swift_coro_transfer(&context.context, &next.context.context)
    }
    
    public func retain(){
        retainedSelf = Unmanaged<Coro>.passRetained(self)
    }
    
    public func release(){
        retainedSelf?.release()
    }
}

extension Coro: CustomStringConvertible {
    public var description: String {
        return "\nidentifier: \(identifier ?? "untitled")\nstack size: \(stack.stack.ssze)"
    }
}

extension Coro: Equatable {}

public func ==(lhs: Coro, rhs: Coro) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

