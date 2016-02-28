import XCTest
@testable import Tofu

class NSDataTests: XCTestCase {
  func testInitBase32EncodedString() {
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
      XCTAssertEqual(NSData(base32EncodedString: actual),
        expected.dataUsingEncoding(NSASCIIStringEncoding))
    }

    XCTAssertNil(NSData(base32EncodedString: "1")) // Invalid character
    XCTAssertNil(NSData(base32EncodedString: "A")) // Invalid length
    XCTAssertNil(NSData(base32EncodedString: "AAA"))
    XCTAssertNil(NSData(base32EncodedString: "AAAAAA"))
    XCTAssertNil(NSData(base32EncodedString: "MY==")) // Invalid padding
    XCTAssertNil(NSData(base32EncodedString: "MY====="))
    XCTAssertNil(NSData(base32EncodedString: "MZXW6Y==="))
  }
}