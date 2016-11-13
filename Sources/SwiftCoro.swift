//
//  SwiftCoro.swift
//  SwiftCoro
//
//  Created by Yuki Takei on 2016/11/13.
//
//

private let stack = Stack<Coroutine>()

private let _main = try! Coroutine()

private func coroutine(stackSize: UInt32 = 0, arg: UnsafeMutableRawPointer){
    do {
        let coroutine = try Coroutine(stackSize: stackSize, arg: arg) { ptr in
            ptr!.assumingMemoryBound(to: ((Void) -> Void).self).pointee()
            
            if let cur = stack.pop(), let next = stack.top {
                cur.transfer(next)
            }
            
            // USR2 signal should be sent from libcoro
            // TODO or terminate corotuine.
        }
        
        let current: Coroutine
        if let cur = stack.top {
            current = cur
        } else {
            current = _main
            stack.push(_main)
        }
        stack.push(coroutine)
        current.transfer(coroutine)
    } catch {
        fatalError("\(error)")
    }
}

public func co(_ task: @escaping (Void) -> Void){
    var _task = task
    coroutine(arg: &_task)
}

public func co(_ task: @autoclosure @escaping (Void) -> Void){
    var _task: (Void) -> Void = task
    coroutine(arg: &_task)
}
