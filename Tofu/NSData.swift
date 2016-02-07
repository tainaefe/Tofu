import Foundation

extension NSData {
  convenience init?(base32EncodedString string: String) {
    let table: [UInt8] = [
      255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
      255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
      255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
      255, 255, 26, 27, 28, 29, 30, 31, 255, 255, 255, 255, 255, 255, 255, 255,
      255, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14,
      15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 255, 255, 255, 255, 255,
      255, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14,
      15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 255, 255, 255, 255, 255,
      255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
      255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
      255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
      255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
      255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
      255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
      255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
      255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    ]

    let length = string.unicodeScalars.count
    guard length > 0 else {
      self.init()
      return
    }

    let padding: Int
    if string.hasSuffix("======") {
      padding = 6
    } else if string.hasSuffix("====") {
      padding = 4
    } else if string.hasSuffix("===") {
      padding = 3
    } else if string.hasSuffix("=") {
      padding = 1
    } else {
      padding = 0
    }

    var remaining = length - padding

    let index = string.unicodeScalars.indexOf { $0.value > 255 || table[Int($0.value)] > 31 }
    if let invalidIndex = index where
      string.unicodeScalars.startIndex.distanceTo(invalidIndex) != remaining { return nil }

    let additional: Int
    switch remaining % 8 {
    case 0: additional = 0
    case 2: additional = 1
    case 4: additional = 2
    case 5: additional = 3
    case 7: additional = 4
    default: return nil
    }

    let size = remaining / 8 * 5 + additional
    let bytes = Array<UInt8>(count: size, repeatedValue: 0)
    var decoded = UnsafeMutablePointer<UInt8>(bytes)

    string.nulTerminatedUTF8.withUnsafeBufferPointer { data in
      var encoded = data.baseAddress
      var a, b, c, d, e, f, g, h: UInt8

      while remaining >= 8 {
        a = table[Int(encoded[0])]
        b = table[Int(encoded[1])]
        c = table[Int(encoded[2])]
        d = table[Int(encoded[3])]
        e = table[Int(encoded[4])]
        f = table[Int(encoded[5])]
        g = table[Int(encoded[6])]
        h = table[Int(encoded[7])]
        decoded[0] = a << 3 | b >> 2
        decoded[1] = b << 6 | c << 1 | d >> 4
        decoded[2] = d << 4 | e >> 1
        decoded[3] = e << 7 | f << 2 | g >> 3
        decoded[4] = g << 5 | h
        remaining -= 8
        decoded = decoded.advancedBy(5)
        encoded = encoded.advancedBy(8)
      }

      (a, b, c, d, e, f, g) = (0, 0, 0, 0, 0, 0, 0)
      switch remaining {
      case 7:
        g = table[Int(encoded[6])]
        f = table[Int(encoded[5])]
        decoded[4] = g << 5
        fallthrough
      case 5:
        e = table[Int(encoded[4])]
        decoded[3] = e << 7 | f << 2 | g >> 3
        fallthrough
      case 4:
        d = table[Int(encoded[3])]
        c = table[Int(encoded[2])]
        decoded[2] = d << 4 | e >> 1
        fallthrough
      case 2:
        b = table[Int(encoded[1])]
        a = table[Int(encoded[0])]
        decoded[1] = b << 6 | c << 1 | d >> 4
        decoded[0] = a << 3 | b >> 2
      default: break
      }
    }

    self.init(bytes: bytes, length: size)
  }
}
