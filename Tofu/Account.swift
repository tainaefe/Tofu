import Foundation

final class Account {
  var persistentRef: NSData?
  var name: String?
  var issuer: String?
  var password = Password()

  convenience init?(url: NSURL) {
    guard let label = url.path?.stringByTrimmingCharactersInSet(
      NSCharacterSet(charactersInString: "/")),
      host = url.host where host == "hotp" || host == "totp"
      else { return nil }
    let labelComponents = label.characters.split { $0 == ":" }.map(String.init)
    guard labelComponents.count > 0,
      let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false),
      queryItems = components.queryItems where queryItems.count > 0 else { return nil }

    self.init()

    name = labelComponents.last?.stringByTrimmingCharactersInSet(
      NSCharacterSet.whitespaceCharacterSet())
    issuer = labelComponents.count > 1 ? labelComponents.first : nil
    password.timeBased = host == "totp"
    for queryItem in queryItems {
      switch queryItem.name {
      case "secret":
        guard let secretString = queryItem.value,
          let secret = NSData(base32EncodedString: secretString) else { break }
        password.secret = secret
      case "algorithm":
        switch queryItem.value {
        case .Some("SHA256"): password.algorithm = .SHA256
        case .Some("SHA512"): password.algorithm = .SHA512
        default: break
        }
      case "digits":
        guard let string = queryItem.value, digits = Int(string) else { break }
        password.digits = digits
      case "issuer": issuer = queryItem.value
      case "counter":
        guard let string = queryItem.value, counter = Int(string) else { break }
        password.counter = counter
      case "period":
        guard let string = queryItem.value, period = Int(string) else { break }
        password.period = period
      default: break
      }
    }
    if password.secret.length == 0 { return nil }
  }

  var description: String {
    guard let issuer = issuer where issuer.characters.count > 0 else { return name ?? "" }
    guard let name = name where name.characters.count > 0 else { return issuer }
    return "\(issuer) (\(name))"
  }
}
