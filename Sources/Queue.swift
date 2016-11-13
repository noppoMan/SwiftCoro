//
//  Queue.swift
//  SwiftCoro
//
//  Created by Yuki Takei on 2016/11/13.
//
//

public class QueueNode<T> {
    public let value: T
    public var next: QueueNode?
    
    public init(_ newvalue: T) {
        self.value = newvalue
    }
}

public class Queue<T> {
    
    public typealias Element = T
    
    public private(set) var count = 0
    
    public private(set) var front: QueueNode<Element>?
    
    public private(set) var back: QueueNode<Element>?
    
    public init () {
        back = nil
        front = back
    }
    
    public func push (_ value: Element) {
        let node = QueueNode<T>(value)
        if let back = self.back {
            back.next = node
        } else {
            front = node
        }
        back = node
        count+=1
    }
    
    /// Return and remove the item at the front of the queue.
    @discardableResult
    public func pop () -> Element? {
        if let newhead = front?.next {
            front = newhead
            count-=1
            return newhead.value
        } else {
            return nil
        }
    }
    
    public func isEmpty() -> Bool {
        return front === back
    }
}
