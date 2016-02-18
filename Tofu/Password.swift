import Foundation

final class Password {
  var algorithm: Algorithm = .SHA1
  var counter = 0
  var digits = 6
  var period = 30
  var secret = NSData()
  var timeBased = false

  func valueForDate(date: NSDate) -> String {
    let counter = timeBased ? Int(date.timeIntervalSince1970) / period : self.counter
    var input = counter.bigEndian
    let digest = UnsafeMutablePointer<UInt8>.alloc(algorithm.digestLength)
    defer { digest.destroy() }
    CCHmac(algorithm.hmacAlgorithm, secret.bytes, secret.length, &input, sizeof(UInt64), digest)
    let bytes = UnsafePointer<UInt8>(digest)
    let offset = bytes[algorithm.digestLength - 1] & 0x0f
    let number = UInt32(bigEndian: UnsafePointer<UInt32>(bytes + Int(offset)).memory) & 0x7fffffff
    return String(format: "%0\(digits)d", number % UInt32(pow(10, Float(digits))))
  }

  func progressForDate(date: NSDate) -> Float {
    let remainder = date.timeIntervalSince1970 % Double(period)
    return 1 - Float(remainder) / Float(period)
  }
}
