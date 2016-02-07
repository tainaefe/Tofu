import Foundation

private let itemClass = kSecClass as String
private let genericPassword = kSecClassGenericPassword as String
private let accountAttribute = kSecAttrAccount as String
private let dataAttribute = kSecValueData as String
private let itemAccessibility = kSecAttrAccessible as String
private let whenUnlockedThisDeviceOnly = kSecAttrAccessibleWhenUnlockedThisDeviceOnly as String
private let returnData = kSecReturnData as String
private let matchLimit = kSecMatchLimit as String
private let encoding = NSUnicodeStringEncoding

struct Keychain {
  func set(value: NSData, forKey key: String) {
    let query = [
      itemClass: genericPassword,
      accountAttribute: key,
      dataAttribute: value,
      itemAccessibility: whenUnlockedThisDeviceOnly,
    ]
    SecItemAdd(query as CFDictionaryRef, nil)
  }

  func get(key: String) -> NSData? {
    let query = [
      itemClass: genericPassword,
      accountAttribute: key,
      returnData: kCFBooleanTrue,
      matchLimit: kSecMatchLimitOne,
    ]
    var returnedData: AnyObject?
    let result = withUnsafeMutablePointer(&returnedData) {
      SecItemCopyMatching(query, UnsafeMutablePointer($0))
    }
    if result == noErr, let data = returnedData as? NSData {
      return data
    }
    return nil
  }

  func delete(key: String) {
    let query = [
      itemClass: genericPassword,
      accountAttribute: key,
    ]
    SecItemDelete(query)
  }
}
