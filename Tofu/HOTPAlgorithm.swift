enum HOTPAlgorithm: Int16 {
  case SHA1 = 0
  case SHA256 = 1
  case SHA512 = 2

  var name: String {
    switch self {
    case .SHA1: return "SHA1"
    case .SHA256: return "SHA256"
    case .SHA512: return "SHA512"
    }
  }
}
