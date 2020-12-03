import XCTest
@testable import Tofu

class DataTests: XCTestCase {
    func testInitBase32Encoded() {
        let examples: [(encoded: String, decoded: String)] = [
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
        
        for example in examples {
            let actual = Data(base32Encoded: example.encoded)
            let expected = example.decoded.data(using: .ascii)

            XCTAssertEqual(actual, expected)
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
