import XCTest
@testable import SwiftCoro

class SwiftCoroTests: XCTestCase {

    static var allTests : [(String, (SwiftCoroTests) -> () throws -> Void)] {
        return [
            ("testMain", testMain),
        ]
    }
    
    func testMain() {
        let _main = try! Coroutine()
        
        var i = 0
        
        let coro3 = try! Coroutine { c in
            i+=1
            XCTAssertEqual(i, 4)
            c.transfer(_main)
            i+=1
            XCTAssertEqual(i, 8)
            c.transfer(_main)
        }
        
        let coro2 = try! Coroutine { c in
            i+=1
            XCTAssertEqual(i, 3)
            c.transfer(coro3)
            i+=1
            XCTAssertEqual(i, 7)
            c.transfer(coro3)
        }
        
        let coro1 = try! Coroutine { c in
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
