import XCTest
@testable import SwiftCoro

class SwiftCoroTests: XCTestCase {

    static var allTests : [(String, (SwiftCoroTests) -> () throws -> Void)] {
        return [
            ("testCoro", testCoro),
        ]
    }
    
    func testCoroutine(){
        let co1 = Coroutine<Int> { yield in
            yield(1)
            yield(2)
            yield(3)
            
            // nested coroutine
            let co2 = Coroutine<Int> { yield in
                yield(1)
                yield(2)
                yield(3)
            }
            XCTAssertEqual(Coroutine<Int>.resume(co2), 1)
            XCTAssertEqual(Coroutine<Int>.resume(co2), 2)
            XCTAssertEqual(Coroutine<Int>.resume(co2), 3)
        }
        
        XCTAssertEqual(Coroutine<Int>.resume(co1), 1)
        XCTAssertEqual(Coroutine<Int>.resume(co1), 2)
        XCTAssertEqual(Coroutine<Int>.resume(co1), 3)
    }
    
    func testCoro() {
        let _main = try! Coro()
        
        var i = 0
        
        let coro3 = try! Coro { c in
            i+=1
            XCTAssertEqual(i, 4)
            c.transfer(_main)
            i+=1
            XCTAssertEqual(i, 8)
            c.transfer(_main)
        }
        
        let coro2 = try! Coro { c in
            i+=1
            XCTAssertEqual(i, 3)
            c.transfer(coro3)
            i+=1
            XCTAssertEqual(i, 7)
            c.transfer(coro3)
        }
        
        let coro1 = try! Coro { c in
            i+=1
            XCTAssertEqual(i, 2)
            c.transfer(coro2)
            i+=1
            XCTAssertEqual(i, 6)
            c.transfer(coro2)
        }
        
        i+=1
        _main.transfer(coro1)
        i+=1
        XCTAssertEqual(i, 5)
        _main.transfer(coro1)
    }
}
