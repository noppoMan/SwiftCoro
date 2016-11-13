import XCTest
@testable import SwiftCoro

class SwiftCoroTests: XCTestCase {

    static var allTests : [(String, (SwiftCoroTests) -> () throws -> Void)] {
        return [
            ("testMain", testMain),
        ]
    }
    
    func testMain() {
        var array = [Int]()
        
        co {
            co {
                co {
                    co {
                        array.append(1)
                    }
                    array.append(2)
                }
                array.append(3)
            }
            array.append(4)
        }
        
        co {
            array.append(5)
        }
        
        XCTAssertEqual(array, [1, 2, 3, 4, 5])
    }
}
