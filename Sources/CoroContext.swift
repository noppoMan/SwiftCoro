//
//  CoroContext.swift
//  SwiftColo
//
//  Created by Yuki Takei on 2016/11/16.
//
//

import CLibcoro

public struct CoroContext {
    var context: coro_context
    
    init() {
        self.context = coro_context()
    }
}
