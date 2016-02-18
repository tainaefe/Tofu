import Foundation

enum Algorithm {
  case SHA1
  case SHA256
  case SHA512

  var name: String {
    switch self {
    case .SHA1: return "SHA1"
    case .SHA256: return "SHA256"
    case .SHA512: return "SHA512"
    }
  }

  var digestLength: Int {
    switch self {
    case .SHA1: return Int(CC_SHA1_DIGEST_LENGTH)
    case .SHA256: return Int(CC_SHA256_DIGEST_LENGTH)
    case .SHA512: return Int(CC_SHA512_DIGEST_LENGTH)
    }
  }

  var hmacAlgorithm: CCHmacAlgorithm {
    switch self {
    case .SHA1: return CCHmacAlgorithm(kCCHmacAlgSHA1)
    case .SHA256: return CCHmacAlgorithm(kCCHmacAlgSHA256)
    case .SHA512: return CCHmacAlgorithm(kCCHmacAlgSHA512)
    }
  }
}
