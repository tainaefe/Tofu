import XCTest
@testable import Tofu

class DataTests: XCTestCase {
    func testInitBase32Encoded() {
        let tests = [
            ("", ""),
            ("MY======", "f"),
            ("MZXQ====", "fo"),
            ("MZXW6===", "foo"),
            ("MZXW6YQ=", "foob"),
            ("MZXW6YTB", "fooba"),
            ("MZXW6YTBOI======", "foobar"),
            ("MY", "f"),
            ("MZXQ", "fo"),
            ("MZXW6", "foo"),
            ("MZXW6YQ", "foob"),
            ("MZXW6YTB", "fooba"),
            ("MZXW6YTBOI", "foobar"),
            ("mzxw6ytboi", "foobar"),
            ]
        
        for (actual, expected) in tests {
            XCTAssertEqual(Data(base32Encoded: actual),
                           expected.data(using: String.Encoding.ascii))
        }
        
        XCTAssertNil(Data(base32Encoded: "1")) // Invalid character
        XCTAssertNil(Data(base32Encoded: "A")) // Invalid length
        XCTAssertNil(Data(base32Encoded: "AAA"))
        XCTAssertNil(Data(base32Encoded: "AAAAAA"))
        XCTAssertNil(Data(base32Encoded: "MY==")) // Invalid padding
        XCTAssertNil(Data(base32Encoded: "MY====="))
        XCTAssertNil(Data(base32Encoded: "MZXW6Y==="))
    }
}
