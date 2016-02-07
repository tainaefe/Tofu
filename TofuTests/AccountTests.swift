import XCTest
import CoreData
@testable import Tofu

private func inMemoryManagedObjectContext() -> NSManagedObjectContext {
  let model = NSManagedObjectModel.mergedModelFromBundles([NSBundle.mainBundle()])!
  let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
  try! coordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil,
    options: nil)
  let managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
  managedObjectContext.persistentStoreCoordinator = coordinator
  return managedObjectContext
}

class AccountTests: XCTestCase {
  func testInitWithURL() {
    let managedObjectContext = inMemoryManagedObjectContext()
    let date = NSDate(timeIntervalSince1970: 1234567890)
    var url = NSURL(
      string: "otpauth://totp/Example:alice@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Example")!
    var account = Account(url: url, insertIntoManagedObjectContext: managedObjectContext)
    XCTAssertEqual(account?.name, "alice@example.com")
    XCTAssertEqual(account?.issuer, "Example")
    XCTAssertEqual(account?.timeBased, true)
    var totp = TOTP(
      secret: NSData(base32EncodedString: "JBSWY3DPEHPK3PXP")!,
      algorithm: .SHA1,
      digits: 6,
      period: 30)
    XCTAssertEqual(account?.valueForDate(date), totp.valueForDate(date))
    url = NSURL(
      string: "otpauth://hotp/Example:alice@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Example&counter=0")!
    account = Account(url: url, insertIntoManagedObjectContext: managedObjectContext)
    XCTAssertEqual(account?.name, "alice@example.com")
    XCTAssertEqual(account?.issuer, "Example")
    XCTAssertEqual(account?.timeBased, false)
    var hotp = HOTP(
      secret: NSData(base32EncodedString: "JBSWY3DPEHPK3PXP")!,
      algorithm: .SHA1,
      digits: 6)
    XCTAssertEqual(account?.valueForDate(date), hotp.valueForCounter(0))
    url = NSURL(
      string: "otpauth://totp/alice@example.com?secret=JBSWY3DPEHPK3PXP")!
    account = Account(url: url, insertIntoManagedObjectContext: managedObjectContext)
    XCTAssertEqual(account?.name, "alice@example.com")
    url = NSURL(
      string: "otpauth://totp/Example%3Aalice@example.com?secret=JBSWY3DPEHPK3PXP")!
    account = Account(url: url, insertIntoManagedObjectContext: managedObjectContext)
    XCTAssertEqual(account?.name, "alice@example.com")
    url = NSURL(
      string: "otpauth://totp/Example:%20%20alice@example.com?secret=JBSWY3DPEHPK3PXP")!
    account = Account(url: url, insertIntoManagedObjectContext: managedObjectContext)
    XCTAssertEqual(account?.name, "alice@example.com")
    url = NSURL(
      string: "otpauth://totp/Example%3A%20%20alice@example.com?secret=JBSWY3DPEHPK3PXP")!
    account = Account(url: url, insertIntoManagedObjectContext: managedObjectContext)
    XCTAssertEqual(account?.name, "alice@example.com")
    url = NSURL(
      string: "otpauth://totp/example.com/alice?secret=JBSWY3DPEHPK3PXP")!
    account = Account(url: url, insertIntoManagedObjectContext: managedObjectContext)
    XCTAssertEqual(account?.name, "example.com/alice")
    url = NSURL(
      string: "otpauth://totp/Example:alice@example.com?secret=JBSWY3DPEHPK3PXP")!
    account = Account(url: url, insertIntoManagedObjectContext: managedObjectContext)
    XCTAssertEqual(account?.issuer, "Example")
    url = NSURL(
      string: "otpauth://totp/alice@example.com")!
    account = Account(url: url, insertIntoManagedObjectContext: managedObjectContext)
    XCTAssertNil(account)
    url = NSURL(
      string: "otpauth://totp/alice@example.com?secret=AAA")!
    account = Account(url: url, insertIntoManagedObjectContext: managedObjectContext)
    XCTAssertNil(account)
    url = NSURL(
      string: "otpauth://totp/alice@example.com?secret=JBSWY3DPEHPK3PXP&algorithm=SHA1")!
    account = Account(url: url, insertIntoManagedObjectContext: managedObjectContext)
    totp = TOTP(
      secret: NSData(base32EncodedString: "JBSWY3DPEHPK3PXP")!,
      algorithm: .SHA1,
      digits: 6,
      period: 30)
    XCTAssertEqual(account?.valueForDate(date), totp.valueForDate(date))
    url = NSURL(
      string: "otpauth://totp/alice@example.com?secret=JBSWY3DPEHPK3PXP&algorithm=SHA256")!
    account = Account(url: url, insertIntoManagedObjectContext: managedObjectContext)
    totp = TOTP(
      secret: NSData(base32EncodedString: "JBSWY3DPEHPK3PXP")!,
      algorithm: .SHA256,
      digits: 6,
      period: 30)
    XCTAssertEqual(account?.valueForDate(date), totp.valueForDate(date))
    url = NSURL(
      string: "otpauth://totp/alice@example.com?secret=JBSWY3DPEHPK3PXP&algorithm=SHA512")!
    account = Account(url: url, insertIntoManagedObjectContext: managedObjectContext)
    totp = TOTP(
      secret: NSData(base32EncodedString: "JBSWY3DPEHPK3PXP")!,
      algorithm: .SHA512,
      digits: 6,
      period: 30)
    XCTAssertEqual(account?.valueForDate(date), totp.valueForDate(date))
    url = NSURL(
      string: "otpauth://totp/alice@example.com?secret=JBSWY3DPEHPK3PXP&digits=6")!
    account = Account(url: url, insertIntoManagedObjectContext: managedObjectContext)
    totp = TOTP(
      secret: NSData(base32EncodedString: "JBSWY3DPEHPK3PXP")!,
      algorithm: .SHA1,
      digits: 6,
      period: 30)
    XCTAssertEqual(account?.valueForDate(date), totp.valueForDate(date))
    url = NSURL(
      string: "otpauth://totp/alice@example.com?secret=JBSWY3DPEHPK3PXP&digits=8")!
    account = Account(url: url, insertIntoManagedObjectContext: managedObjectContext)
    totp = TOTP(
      secret: NSData(base32EncodedString: "JBSWY3DPEHPK3PXP")!,
      algorithm: .SHA1,
      digits: 8,
      period: 30)
    XCTAssertEqual(account?.valueForDate(date), totp.valueForDate(date))
    url = NSURL(
      string: "otpauth://hotp/Example:alice@example.com?secret=JBSWY3DPEHPK3PXP")!
    account = Account(url: url, insertIntoManagedObjectContext: managedObjectContext)
    hotp = HOTP(
      secret: NSData(base32EncodedString: "JBSWY3DPEHPK3PXP")!,
      algorithm: .SHA1,
      digits: 6)
    XCTAssertEqual(account?.valueForDate(date), hotp.valueForCounter(0))
    url = NSURL(
      string: "otpauth://totp/alice@example.com?secret=JBSWY3DPEHPK3PXP&period=60")!
    account = Account(url: url, insertIntoManagedObjectContext: managedObjectContext)
    totp = TOTP(
      secret: NSData(base32EncodedString: "JBSWY3DPEHPK3PXP")!,
      algorithm: .SHA1,
      digits: 6,
      period: 60)
    XCTAssertEqual(account?.valueForDate(date), totp.valueForDate(date))
  }

  func testIdentifier() {
    let managedObjectContext = inMemoryManagedObjectContext()
    let withIssuer = Account(name: "test@example.com",
      issuer: "Example",
      secret: NSData(),
      algorithm: .SHA1,
      digits: 6,
      timeBased: true,
      periodOrCounter: 30,
      insertIntoManagedObjectContext: managedObjectContext)
    let withoutIssuer = Account(name: "test@example.com",
      issuer: nil,
      secret: NSData(),
      algorithm: .SHA1,
      digits: 6,
      timeBased: true,
      periodOrCounter: 30,
      insertIntoManagedObjectContext: managedObjectContext)
    let withEmptyIssuer = Account(name: "test@example.com",
      issuer: "",
      secret: NSData(),
      algorithm: .SHA1,
      digits: 6,
      timeBased: true,
      periodOrCounter: 30,
      insertIntoManagedObjectContext: managedObjectContext)
    let withoutName = Account(name: nil,
      issuer: "Example",
      secret: NSData(),
      algorithm: .SHA1,
      digits: 6,
      timeBased: true,
      periodOrCounter: 30,
      insertIntoManagedObjectContext: managedObjectContext)
    let withEmptyName = Account(name: "",
      issuer: "Example",
      secret: NSData(),
      algorithm: .SHA1,
      digits: 6,
      timeBased: true,
      periodOrCounter: 30,
      insertIntoManagedObjectContext: managedObjectContext)
    let withNothing = Account(name: nil,
      issuer: nil,
      secret: NSData(),
      algorithm: .SHA1,
      digits: 6,
      timeBased: true,
      periodOrCounter: 30,
      insertIntoManagedObjectContext: managedObjectContext)
    let withBothEmpty = Account(name: "",
      issuer: "",
      secret: NSData(),
      algorithm: .SHA1,
      digits: 6,
      timeBased: true,
      periodOrCounter: 30,
      insertIntoManagedObjectContext: managedObjectContext)
    try! managedObjectContext.save()
    XCTAssertEqual(withIssuer.identifier, "Example (test@example.com)")
    XCTAssertEqual(withoutIssuer.identifier, "test@example.com")
    XCTAssertEqual(withEmptyIssuer.identifier, "test@example.com")
    XCTAssertEqual(withoutName.identifier, "Example")
    XCTAssertEqual(withEmptyName.identifier, "Example")
    XCTAssertEqual(withNothing.identifier, nil)
    XCTAssertEqual(withBothEmpty.identifier, "")
  }

  func testValueForDate() {
    let managedObjectContext = inMemoryManagedObjectContext()
    let secret = "12345678901234567890".dataUsingEncoding(NSASCIIStringEncoding)!
    let date = NSDate(timeIntervalSince1970: 1111111111)
    let timeBased = Account(name: "test@example.com",
      issuer: "Example",
      secret: secret,
      algorithm: .SHA256,
      digits: 8,
      timeBased: true,
      periodOrCounter: 30,
      insertIntoManagedObjectContext: managedObjectContext)
    let counterBased = Account(name: "test@example.com",
      issuer: "Example",
      secret: secret,
      algorithm: .SHA512,
      digits: 6,
      timeBased: false,
      periodOrCounter: 4,
      insertIntoManagedObjectContext: managedObjectContext)
    XCTAssertEqual(timeBased.valueForDate(date), "74584430")
    XCTAssertEqual(counterBased.valueForDate(date), "937510")
  }

  func testProgressForDate() {
    let managedObjectContext = inMemoryManagedObjectContext()
    let secret = "12345678901234567890".dataUsingEncoding(NSASCIIStringEncoding)!
    let timeBased = Account(name: "test@example.com",
      issuer: "Example",
      secret: secret,
      algorithm: .SHA256,
      digits: 8,
      timeBased: true,
      periodOrCounter: 30,
      insertIntoManagedObjectContext: managedObjectContext)
    let counterBased = Account(name: "test@example.com",
      issuer: "Example",
      secret: secret,
      algorithm: .SHA512,
      digits: 6,
      timeBased: false,
      periodOrCounter: 4,
      insertIntoManagedObjectContext: managedObjectContext)
    var date = NSDate(timeIntervalSince1970: 0)
    XCTAssertEqual(timeBased.progressForDate(date), 1)
    XCTAssertEqual(counterBased.progressForDate(date), 1)
    date = NSDate(timeIntervalSince1970: 15)
    XCTAssertEqual(timeBased.progressForDate(date), 0.5)
    XCTAssertEqual(counterBased.progressForDate(date), 1)
    date = NSDate(timeIntervalSince1970: 22.5)
    XCTAssertEqual(timeBased.progressForDate(date), 0.25)
    XCTAssertEqual(counterBased.progressForDate(date), 1)
    date = NSDate(timeIntervalSince1970: 30)
    XCTAssertEqual(timeBased.progressForDate(date), 1)
    XCTAssertEqual(counterBased.progressForDate(date), 1)
  }

  func testIncrementCounter() {
    let managedObjectContext = inMemoryManagedObjectContext()
    let secret = "12345678901234567890".dataUsingEncoding(NSASCIIStringEncoding)!
    let date = NSDate(timeIntervalSince1970: 1111111111)
    let timeBased = Account(name: "test@example.com",
      issuer: "Example",
      secret: secret,
      algorithm: .SHA256,
      digits: 8,
      timeBased: true,
      periodOrCounter: 30,
      insertIntoManagedObjectContext: managedObjectContext)
    let counterBased = Account(name: "test@example.com",
      issuer: "Example",
      secret: secret,
      algorithm: .SHA512,
      digits: 6,
      timeBased: false,
      periodOrCounter: 4,
      insertIntoManagedObjectContext: managedObjectContext)
    XCTAssertEqual(timeBased.valueForDate(date), "74584430")
    XCTAssertEqual(counterBased.valueForDate(date), "937510")
    timeBased.incrementCounter()
    counterBased.incrementCounter()
    XCTAssertEqual(timeBased.valueForDate(date), "74584430")
    XCTAssertEqual(counterBased.valueForDate(date), "848329")
  }

  func testMoveToPosition() {
    let managedObjectContext = inMemoryManagedObjectContext()
    let firstAccount = accountInsertedIntoManagedObjectContext(managedObjectContext)
    let secondAccount = accountInsertedIntoManagedObjectContext(managedObjectContext)
    let thirdAccount = accountInsertedIntoManagedObjectContext(managedObjectContext)
    XCTAssertEqual(firstAccount.position, 0)
    XCTAssertEqual(secondAccount.position, 1)
    XCTAssertEqual(thirdAccount.position, 2)
    thirdAccount.moveToPosition(1)
    XCTAssertEqual(firstAccount.position, 0)
    XCTAssertEqual(thirdAccount.position, 1)
    XCTAssertEqual(secondAccount.position, 2)
    firstAccount.moveToPosition(1)
    XCTAssertEqual(thirdAccount.position, 0)
    XCTAssertEqual(firstAccount.position, 1)
    XCTAssertEqual(secondAccount.position, 2)
    secondAccount.moveToPosition(0)
    XCTAssertEqual(secondAccount.position, 0)
    XCTAssertEqual(thirdAccount.position, 1)
    XCTAssertEqual(firstAccount.position, 2)
    secondAccount.moveToPosition(2)
    XCTAssertEqual(thirdAccount.position, 0)
    XCTAssertEqual(firstAccount.position, 1)
    XCTAssertEqual(secondAccount.position, 2)
    firstAccount.moveToPosition(2)
    XCTAssertEqual(thirdAccount.position, 0)
    XCTAssertEqual(secondAccount.position, 1)
    XCTAssertEqual(firstAccount.position, 2)
    secondAccount.moveToPosition(0)
    XCTAssertEqual(secondAccount.position, 0)
    XCTAssertEqual(thirdAccount.position, 1)
    XCTAssertEqual(firstAccount.position, 2)
  }

  func testDelete() {
    let managedObjectContext = inMemoryManagedObjectContext()
    let firstAccount = accountInsertedIntoManagedObjectContext(managedObjectContext)
    let secondAccount = accountInsertedIntoManagedObjectContext(managedObjectContext)
    let thirdAccount = accountInsertedIntoManagedObjectContext(managedObjectContext)
    XCTAssertEqual(firstAccount.position, 0)
    XCTAssertEqual(secondAccount.position, 1)
    XCTAssertEqual(thirdAccount.position, 2)
    secondAccount.delete()
    XCTAssertEqual(firstAccount.position, 0)
    XCTAssertEqual(thirdAccount.position, 1)
  }

  private func accountInsertedIntoManagedObjectContext(
    managedObjectContext: NSManagedObjectContext) -> Account {
      let secret = "12345678901234567890".dataUsingEncoding(NSASCIIStringEncoding)!
      return Account(name: "test@example.com",
        issuer: "Example",
        secret: secret,
        algorithm: .SHA256,
        digits: 8,
        timeBased: true,
        periodOrCounter: 30,
        insertIntoManagedObjectContext: managedObjectContext)
  }
}
