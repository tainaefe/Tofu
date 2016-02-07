import UIKit
import CoreData

private func managedObjectContext() -> NSManagedObjectContext {
  let documentsURL = NSFileManager.defaultManager()
    .URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
  let url = documentsURL.URLByAppendingPathComponent("Tofu.sqlite")
  let model = NSManagedObjectModel.mergedModelFromBundles([NSBundle.mainBundle()])!
  let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
  try! coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url,
    options: nil)
  let managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
  managedObjectContext.persistentStoreCoordinator = coordinator
  return managedObjectContext
}

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
      let navigationController = window?.rootViewController as! UINavigationController
      let rootViewController = navigationController.viewControllers.first as! AccountsController
      rootViewController.managedObjectContext = managedObjectContext()
      return true
  }
}
