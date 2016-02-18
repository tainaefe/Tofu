import Foundation

private func archivedDataWithAccount(account: Account) -> NSData {
  let data = NSMutableData()
  let coder = NSKeyedArchiver(forWritingWithMutableData: data)

  coder.encodeBool(account.password.timeBased, forKey: "timeBased")
  let algorithmIdentifier: Int32
  switch account.password.algorithm {
  case .SHA1: algorithmIdentifier = 0
  case .SHA256: algorithmIdentifier = 1
  case .SHA512: algorithmIdentifier = 2
  }
  coder.encodeInt32(algorithmIdentifier, forKey: "algorithm")
  coder.encodeInt32(Int32(account.password.digits), forKey: "digits")
  coder.encodeObject(account.password.secret, forKey: "secret")
  coder.encodeInt32(Int32(account.password.counter), forKey: "counter")
  coder.encodeInt32(Int32(account.password.period), forKey: "period")
  coder.encodeObject(account.name, forKey: "name")
  coder.encodeObject(account.issuer, forKey: "issuer")
  coder.finishEncoding()

  var version: UInt8 = 1
  let size = sizeofValue(version)
  let versionedData = NSMutableData(bytes: &version, length: size)
  versionedData.appendData(data)

  return versionedData
}

private func unarchiveAccountWithData(data: NSData) -> Account? {
  var version: UInt8 = 0
  let size = sizeofValue(version)
  data.getBytes(&version, length: size)
  guard version == 1 else { return nil }
  let subdata = data.subdataWithRange(NSRange(location: size, length: data.length - size))

  let coder = NSKeyedUnarchiver(forReadingWithData: subdata)

  guard let secret = coder.decodeObjectForKey("secret") as? NSData else { return nil }

  let password = Password()

  switch coder.decodeInt32ForKey("algorithm") {
  case 0: password.algorithm = .SHA1
  case 1: password.algorithm = .SHA256
  case 2: password.algorithm = .SHA512
  default: return nil
  }

  password.secret = secret
  password.digits = Int(coder.decodeInt32ForKey("digits"))
  password.timeBased = coder.decodeBoolForKey("timeBased")
  password.counter = Int(coder.decodeInt32ForKey("counter"))
  password.period = Int(coder.decodeInt32ForKey("period"))

  let account = Account()
  account.name = coder.decodeObjectForKey("name") as? String
  account.issuer = coder.decodeObjectForKey("issuer") as? String
  account.password = password
  return account
}

private func accountWithPersistentRef(persistentRef: NSData) -> Account? {
  let query = [
    kSecClass as String: kSecClassGenericPassword,
    kSecValuePersistentRef as String: persistentRef,
    kSecReturnData as String: kCFBooleanTrue,
  ]
  var result: AnyObject?
  let code = SecItemCopyMatching(query, &result)
  guard code == errSecSuccess,
    let data = result as? NSData,
    let account = unarchiveAccountWithData(data) else { return nil }
  account.persistentRef = persistentRef
  return account
}

final class Keychain {
  var accounts: [Account] {
    let query = [
      kSecClass as String: kSecClassGenericPassword,
      kSecReturnPersistentRef as String: kCFBooleanTrue,
      kSecMatchLimit as String: kSecMatchLimitAll,
    ]
    var result: AnyObject?
    let code = SecItemCopyMatching(query, &result)
    guard code == errSecSuccess, let persistentRefs = result as? [NSData] else { return [] }
    return persistentRefs.flatMap { accountWithPersistentRef($0) }
  }

  func insertAccount(account: Account) -> Bool {
    let query = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: NSProcessInfo().globallyUniqueString,
      kSecAttrDescription as String: account.description,
      kSecValueData as String: archivedDataWithAccount(account),
      kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked,
      kSecReturnPersistentRef as String: true,
    ]
    var result: AnyObject?
    guard SecItemAdd(query, &result) == errSecSuccess else { return false }
    account.persistentRef = (result as! NSData)
    return true
  }

  func updateAccount(account: Account) -> Bool {
    let query = [
      kSecClass as String: kSecClassGenericPassword,
      kSecValuePersistentRef as String: account.persistentRef!
    ]
    let attributes = [
      kSecAttrDescription as String: account.description,
      kSecValueData as String: archivedDataWithAccount(account),
      kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked,
    ]
    return SecItemUpdate(query, attributes) == errSecSuccess
  }

  func deleteAccount(account: Account) -> Bool {
    let query = [
      kSecClass as String: kSecClassGenericPassword,
      kSecValuePersistentRef as String: account.persistentRef!
    ]
    return SecItemDelete(query) == errSecSuccess
  }
}
