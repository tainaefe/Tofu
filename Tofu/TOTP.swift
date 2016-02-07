import Foundation

struct TOTP {
  let secret: NSData
  let algorithm: HOTPAlgorithm
  let digits: Int
  let period: UInt64

  func valueForDate(date: NSDate) -> String {
    let hotp = HOTP(secret: secret, algorithm: algorithm, digits: digits)
    return hotp.valueForCounter(UInt64(date.timeIntervalSince1970) / period)
  }
}
