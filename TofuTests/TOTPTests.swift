import XCTest
@testable import Tofu

class TOTPTests: XCTestCase {
  func testValueForDate() {
    let secret = "12345678901234567890".dataUsingEncoding(NSASCIIStringEncoding)!
    let tests = [
      (NSDate(timeIntervalSince1970: 59), "94287082", "32247374", "69342147"),
      (NSDate(timeIntervalSince1970: 1111111109), "07081804", "34756375", "63049338"),
      (NSDate(timeIntervalSince1970: 1111111111), "14050471", "74584430", "54380122"),
      (NSDate(timeIntervalSince1970: 1234567890), "89005924", "42829826", "76671578"),
      (NSDate(timeIntervalSince1970: 2000000000), "69279037", "78428693", "56464532"),
      (NSDate(timeIntervalSince1970: 20000000000), "65353130", "24142410", "69481994"),
    ]
    let totpSHA1 = TOTP(secret: secret, algorithm: .SHA1, digits: 8, period: 30)
    let totpSHA256 = TOTP(secret: secret, algorithm: .SHA256, digits: 8, period: 30)
    let totpSHA512 = TOTP(secret: secret, algorithm: .SHA512, digits: 8, period: 30)

    for (date, expSHA1, expSHA256, expSHA512) in tests {
      XCTAssertEqual(totpSHA1.valueForDate(date), expSHA1)
      XCTAssertEqual(totpSHA256.valueForDate(date), expSHA256)
      XCTAssertEqual(totpSHA512.valueForDate(date), expSHA512)
    }
  }
}