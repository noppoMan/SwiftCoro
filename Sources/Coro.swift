//
//  Coro.swift
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

public class CoroStack {
    var stack: UnsafeMutablePointer<coro_stack>
    
    convenience init(sptr: UnsafeMutableRawPointer?, ssze: Int){
        self.init()
        self.stack.pointee.sptr = sptr
        self.stack.pointee.ssze = 0
    }
    
    init() {
        self.stack = UnsafeMutablePointer<coro_stack>.allocate(capacity: MemoryLayout<coro_stack>.size)
    }
    
    public func alloc(stackSize: UInt32 = 0) throws {
        let r = coro_stack_alloc(stack, stackSize)
        if r < 0 {
            throw SystemError.lastOperationError ?? SystemError.other(errorNumber: errno)
        }
    }
    
    deinit {
        coro_stack_free(stack)
    }
}

public class CoroContext {
    var context: UnsafeMutablePointer<coro_context>
    
    init() {
        self.context = UnsafeMutablePointer<coro_context>.allocate(capacity: MemoryLayout<coro_context>.size)
    }
    
    deinit {
        swift_coro_destroy(context)
    }
}

