import UIKit
import CoreData

final class AccountsController: UITableViewController, NSFetchedResultsControllerDelegate {
  @IBOutlet var emptyLabel: UILabel!
  var managedObjectContext: NSManagedObjectContext!
  private var fetchedResultsController: NSFetchedResultsController!
  private var userDidInitiateChanges = false

  @IBAction func didPressAdd(sender: UIBarButtonItem) {
    let alertController = UIAlertController(
      title: "Add Account",
      message: "Add an account by scanning a QR code or enter a secret manually.",
      preferredStyle: .ActionSheet)
    let scanQRCodeAction = UIAlertAction(title: "Scan QR Code", style: .Default) { _ in
      self.performSegueWithIdentifier("ScanSegue", sender: self)
    }
    let enterManuallyAction = UIAlertAction(title: "Enter Manually", style: .Default) { _ in
      self.performSegueWithIdentifier("ManualSegue", sender: self)
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
    alertController.addAction(scanQRCodeAction)
    alertController.addAction(enterManuallyAction)
    alertController.addAction(cancelAction)
    presentViewController(alertController, animated: true, completion: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    let request = NSFetchRequest(entityName: Account.entityName)
    request.sortDescriptors = [NSSortDescriptor(key: "position", ascending: true)]
    fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
      managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
    fetchedResultsController.delegate = self
    try! fetchedResultsController.performFetch()
    let timer = NSTimer(timeInterval: 1, target: self, selector: "update", userInfo: nil,
      repeats: true)
    NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
  }

  override func viewWillAppear(animated: Bool) {
    updateState()
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let navigationController = segue.destinationViewController as? UINavigationController {
      let controller = navigationController.viewControllers.first
        as! ManagedObjectContextSettable
      controller.managedObjectContext = managedObjectContext
    } else {
      let editAccountController = segue.destinationViewController as! EditAccountController
      let cell = sender as! AccountCell
      editAccountController.account = cell.account
    }
  }

  func update() {
    let now = NSDate()
    for cell in tableView.visibleCells as! [AccountCell] {
      cell.updateWithDate(now)
    }
  }

  private func updateState() {
    if fetchedResultsController.fetchedObjects?.count == 0 {
      setEditing(false, animated: true)
      tableView.backgroundView = emptyLabel
      tableView.separatorStyle = .None
      navigationItem.leftBarButtonItem = nil
    } else {
      tableView.backgroundView = nil
      tableView.separatorStyle = .SingleLine
      navigationItem.leftBarButtonItem = editButtonItem()
    }
  }

  // MARK: NSTableViewDataSource

  override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) ->
    Bool {
      return true
  }

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return fetchedResultsController.sections?.count ?? 0
  }

  override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath,
    toIndexPath destinationIndexPath: NSIndexPath) {
      let account = fetchedResultsController.objectAtIndexPath(sourceIndexPath) as! Account
      userDidInitiateChanges = true
      account.moveToPosition(Int64(destinationIndexPath.row))
      try! managedObjectContext.save()
      userDidInitiateChanges = false
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return fetchedResultsController.sections![section].numberOfObjects
  }

  override func tableView(tableView: UITableView,
    cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCellWithIdentifier("AccountCell")!
      configureCell(cell, indexPath: indexPath)
      return cell
  }

  override func tableView(
    tableView: UITableView,
    commitEditingStyle editingStyle: UITableViewCellEditingStyle,
    forRowAtIndexPath indexPath: NSIndexPath) {
      if editingStyle == .Delete {
        let alertController = UIAlertController(
          title: "Deleting This Account Will Not Turn Off Two-Factor Authentication",
          message: "Please make sure two-factor authentication is turned off in the issuer's sett" +
          "ings before deleting this account to prevent being locked out.",
          preferredStyle: .Alert)
        let deleteAccountAction = UIAlertAction(title: "Delete Account", style: .Destructive) { _ in
          let account = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Account
          self.userDidInitiateChanges = true
          account.delete()
          try! self.managedObjectContext.save()
          self.userDidInitiateChanges = false
          tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
          self.updateState()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(deleteAccountAction)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
      }
  }

  private func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
    let account = fetchedResultsController.objectAtIndexPath(indexPath) as! Account
    let cell = cell as! AccountCell
    cell.account = account
  }

  // MARK: NSTableViewDelegate

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    if let cell = tableView.cellForRowAtIndexPath(indexPath) as? AccountCell {
      performSegueWithIdentifier("EditAccountSegue", sender: cell)
    }
  }

  override func tableView(tableView: UITableView,
    shouldShowMenuForRowAtIndexPath indexPath: NSIndexPath) -> Bool {
      return true
  }

  override func tableView(tableView: UITableView, canPerformAction action: Selector,
    forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
      return action == Selector("copy:")
  }

  override func tableView(tableView: UITableView, performAction action: Selector,
    forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
      if action == Selector("copy:") {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! AccountCell
        UIPasteboard.generalPasteboard().string = cell.valueLabel.text?
          .stringByReplacingOccurrencesOfString(" ", withString: "")
      }
  }

  // MARK: NSFetchedResultsControllerDelegate

  func controllerWillChangeContent(controller: NSFetchedResultsController) {
    if userDidInitiateChanges { return }
    tableView.beginUpdates()
  }

  func controller(controller: NSFetchedResultsController,
    didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
    atIndex sectionIndex: Int,
    forChangeType type: NSFetchedResultsChangeType) {
      if userDidInitiateChanges { return }
      switch type {
      case .Insert:
        tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
      case .Delete:
        tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
      case .Move: break
      case .Update: break
      }
  }

  func controller(controller: NSFetchedResultsController,
    didChangeObject anObject: AnyObject,
    atIndexPath indexPath: NSIndexPath?,
    forChangeType type: NSFetchedResultsChangeType,
    newIndexPath: NSIndexPath?) {
      if userDidInitiateChanges { return }
      switch type {
      case .Insert: tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
      case .Delete: tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
      case .Update:
        guard let cell = tableView.cellForRowAtIndexPath(indexPath!) else { break }
        configureCell(cell, indexPath: indexPath!)
      case .Move:
        guard indexPath != newIndexPath else { break }
        tableView.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
      }
  }

  func controllerDidChangeContent(controller: NSFetchedResultsController) {
    if userDidInitiateChanges { return }
    tableView.endUpdates()
  }
}
