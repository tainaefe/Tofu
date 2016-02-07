import CoreData

private let keychain = Keychain()

final class Account: NSManagedObject {
  static let entityName = String(Account)
  @NSManaged var name: String?
  @NSManaged var issuer: String?
  @NSManaged private(set) var position: Int64
  @NSManaged private var keychainKey: String
  @NSManaged private var digits: Int16
  @NSManaged private var algorithmValue: Int16
  @NSManaged private(set) var timeBased: Bool
  @NSManaged private var periodOrCounter: Int64

  var identifier: String? {
    guard let issuer = issuer where issuer.characters.count > 0 else { return name }
    guard let name = name where name.characters.count > 0 else { return issuer }
    return "\(issuer) (\(name))"
  }

  private var algorithm: HOTPAlgorithm {
    return HOTPAlgorithm(rawValue: algorithmValue)!
  }

  convenience init(
    name: String?,
    issuer: String?,
    secret: NSData,
    algorithm: HOTPAlgorithm,
    digits: Int16,
    timeBased: Bool,
    periodOrCounter: Int64,
    insertIntoManagedObjectContext managedObjectContext: NSManagedObjectContext) {
      let fetchRequest = NSFetchRequest(entityName: Account.entityName)
      var error: NSError? = nil
      let count = managedObjectContext.countForFetchRequest(fetchRequest, error: &error)
      guard error == nil else { fatalError() }
      let entity = NSEntityDescription.entityForName(Account.entityName,
        inManagedObjectContext: managedObjectContext)!
      self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
      self.name = name
      self.issuer = issuer
      position = Int64(count)
      self.digits = digits
      algorithmValue = algorithm.rawValue
      self.timeBased = timeBased
      self.periodOrCounter = periodOrCounter
      keychainKey = NSProcessInfo().globallyUniqueString
      keychain.set(secret, forKey: keychainKey)
  }

  convenience init?(url: NSURL,
    insertIntoManagedObjectContext managedObjectContext: NSManagedObjectContext) {
      guard let label = url.path?.stringByTrimmingCharactersInSet(
        NSCharacterSet(charactersInString: "/")),
        host = url.host where host == "hotp" || host == "totp"
        else { return nil }
      let labelComponents = label.characters.split { $0 == ":" }.map(String.init)
      guard labelComponents.count > 0,
        let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false),
        queryItems = components.queryItems where queryItems.count > 0
        else { return nil }

      let name = labelComponents.last?.stringByTrimmingCharactersInSet(
        NSCharacterSet.whitespaceCharacterSet())
      var issuer = labelComponents.count > 1 ? labelComponents.first : nil
      var secret: NSData?
      var algorithm = HOTPAlgorithm.SHA1
      var digits: Int16 = 6
      let timeBased = host == "totp"
      var periodOrCounter: Int64 = timeBased ? 30 : 0
      for queryItem in queryItems {
        switch queryItem.name {
        case "secret":
          guard let secretString = queryItem.value else { break }
          secret = NSData(base32EncodedString: secretString)
        case "algorithm":
          switch queryItem.value {
          case .Some("SHA256"): algorithm = .SHA256
          case .Some("SHA512"): algorithm = .SHA512
          default: break
          }
        case "digits":
          guard let string = queryItem.value, int16 = Int16(string) else { break }
          digits = int16
        case "issuer": issuer = queryItem.value
        case "counter": fallthrough
        case "period":
          guard let string = queryItem.value, int64 = Int64(string) else { break }
          periodOrCounter = int64
        default: break
        }
      }
      if secret == nil { return nil }
      self.init(name: name,
        issuer: issuer,
        secret: secret!,
        algorithm: algorithm,
        digits: digits,
        timeBased: timeBased,
        periodOrCounter: periodOrCounter,
        insertIntoManagedObjectContext: managedObjectContext)
  }

  func valueForDate(date: NSDate) -> String {
    if timeBased {
      return TOTP(
        secret: keychain.get(keychainKey)!,
        algorithm: algorithm,
        digits: Int(digits),
        period: UInt64(periodOrCounter)).valueForDate(date)
    }
    return HOTP(
      secret: keychain.get(keychainKey)!,
      algorithm: algorithm,
      digits: Int(digits)).valueForCounter(UInt64(periodOrCounter))
  }

  func progressForDate(date: NSDate) -> Float {
    guard timeBased else { return 1 }
    let remainder = date.timeIntervalSince1970 % Double(periodOrCounter)
    return 1 - Float(remainder) / Float(periodOrCounter)
  }

  func incrementCounter() {
    if !timeBased {
      periodOrCounter++
    }
  }

  func moveToPosition(position: Int64) {
    let fetchRequest = NSFetchRequest(entityName: Account.entityName)
    let movingDown = position > self.position
    fetchRequest.predicate = movingDown ?
      NSPredicate(format: "position > %d AND position <= %d", self.position, position) :
      NSPredicate(format: "position < %d AND position >= %d", self.position, position)
    let accounts = try! managedObjectContext?.executeFetchRequest(fetchRequest) as! [Account]
    for account in accounts {
      account.position += movingDown ? -1 : 1
    }
    self.position = position
  }

  func delete() {
    let fetchRequest = NSFetchRequest(entityName: Account.entityName)
    fetchRequest.predicate = NSPredicate(format: "position > %d", self.position)
    let accounts = try! managedObjectContext?.executeFetchRequest(fetchRequest) as! [Account]
    for account in accounts {
      account.position--
    }
    keychain.delete(keychainKey)
    managedObjectContext?.deleteObject(self)
  }
}
