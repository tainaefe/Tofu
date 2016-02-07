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
    ]

    for (actual, expected) in tests {
      XCTAssertEqual(NSData(base32EncodedString: actual),
        expected.dataUsingEncoding(NSASCIIStringEncoding))
    }

    XCTAssertNil(NSData(base32EncodedString: "1"))
    XCTAssertNil(NSData(base32EncodedString: "MY=="))
    XCTAssertNil(NSData(base32EncodedString: "MY====="))
    XCTAssertNil(NSData(base32EncodedString: "MZXW6Y==="))
  }
}