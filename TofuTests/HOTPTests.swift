import XCTest
@testable import Tofu

class HOTPTests: XCTestCase {
  func testValueForCounter() {
    let secret = "12345678901234567890".dataUsingEncoding(NSASCIIStringEncoding)!
    let tests: [(UInt64, String, String, String)] = [
      (0, "755224", "875740", "125165"),
      (1, "287082", "247374", "342147"),
      (2, "359152", "254785", "730102"),
      (3, "969429", "496144", "778726"),
      (4, "338314", "480556", "937510"),
      (5, "254676", "697997", "848329"),
      (6, "287922", "191609", "266680"),
      (7, "162583", "579288", "588359"),
      (8, "399871", "895912", "039399"),
      (9, "520489", "184989", "643409"),
    ]
    let hotpSHA1 = HOTP(secret: secret, algorithm: .SHA1, digits: 6)
    let hotpSHA256 = HOTP(secret: secret, algorithm: .SHA256, digits: 6)
    let hotpSHA512 = HOTP(secret: secret, algorithm: .SHA512, digits: 6)

    for (counter, expSHA1, expSHA256, expSHA512) in tests {
      XCTAssertEqual(hotpSHA1.valueForCounter(counter), expSHA1)
      XCTAssertEqual(hotpSHA256.valueForCounter(counter), expSHA256)
      XCTAssertEqual(hotpSHA512.valueForCounter(counter), expSHA512)
    }
  }
}
