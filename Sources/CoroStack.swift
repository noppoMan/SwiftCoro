//
//  CoroStack.swift
//  SwiftColo
//
//  Created by Yuki Takei on 2016/11/16.
//
//

import CLibcoro

public struct CoroStack {
    var stack: coro_stack
    
    init(sptr: UnsafeMutableRawPointer?, ssze: Int){
        self.stack = coro_stack(sptr: sptr, ssze: ssze)
    }
    
    init() {
        self.stack = coro_stack()
    }
    
    public mutating func alloc(stackSize: UInt32 = 0) throws {
        let r = coro_stack_alloc(&stack, stackSize)
        if r < 0 {
            throw SystemError.lastOperationError ?? SystemError.other(errorNumber: errno)
        }
    }
}
