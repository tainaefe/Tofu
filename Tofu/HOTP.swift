import Foundation

struct HOTP {
  let secret: NSData
  let algorithm: HOTPAlgorithm
  let digits: Int

  func valueForCounter(counter: UInt64) -> String {
    var input = counter.bigEndian
    let length = hmacLength()
    let digest = UnsafeMutablePointer<UInt8>.alloc(length)
    defer { digest.destroy() }
    CCHmac(hmacAlgorithm(), secret.bytes, secret.length, &input, sizeof(UInt64), digest)
    let bytes = UnsafePointer<UInt8>(digest)
    let offset = bytes[length - 1] & 0x0f
    let number = UInt32(bigEndian: UnsafePointer<UInt32>(bytes + Int(offset)).memory) & 0x7fffffff
    return String(format: "%0\(digits)d", number % UInt32(pow(10, Float(digits))))
  }

  private func hmacLength() -> Int {
    switch algorithm {
    case .SHA1: return Int(CC_SHA1_DIGEST_LENGTH)
    case .SHA256: return Int(CC_SHA256_DIGEST_LENGTH)
    case .SHA512: return Int(CC_SHA512_DIGEST_LENGTH)
    }
  }

  private func hmacAlgorithm() -> CCHmacAlgorithm {
    switch algorithm {
    case .SHA1: return CCHmacAlgorithm(kCCHmacAlgSHA1)
    case .SHA256: return CCHmacAlgorithm(kCCHmacAlgSHA256)
    case .SHA512: return CCHmacAlgorithm(kCCHmacAlgSHA512)
    }
  }
}
