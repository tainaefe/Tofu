import UIKit

private let persistentRefsKey = "persistentRefs"
private let accountSearchResultsViewControllerIdentifier = "AccountSearchResultsViewController"

final class AccountsViewController: UITableViewController, UISearchResultsUpdating,
AccountCreationDelegate, AccountUpdateDelegate {
  @IBOutlet var emptyLabel: UILabel!
  private let keychain = Keychain()
  private let userDefaults = NSUserDefaults.standardUserDefaults()
  private var accounts: [Account]!
  private var searchController: UISearchController!

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

    accounts = keychain.accounts
    let persistentRefs = userDefaults.arrayForKey(persistentRefsKey) as? [NSData] ?? []
    accounts.sortInPlace { a, b in
      persistentRefs.indexOf(a.persistentRef!) < persistentRefs.indexOf(b.persistentRef!)
    }
    persistAccountOrder()

    updateEditing()

    let searchResultsController = storyboard?.instantiateViewControllerWithIdentifier(
      accountSearchResultsViewControllerIdentifier) as! AccountSearchResultsViewController
    searchController = UISearchController(searchResultsController: searchResultsController)
    searchController.searchResultsUpdater = self
    tableView.tableHeaderView = searchController.searchBar

    let updater = AccountsTableViewUpdater(tableView: tableView)
    updater.startUpdating()
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let navigationController = segue.destinationViewController as? UINavigationController {
      if let manualAccountCreationViewController = navigationController.topViewController
        as? ManualAccountCreationViewController {
          manualAccountCreationViewController.delegate = self
      } else {
        let scanningAccountCreationViewController = navigationController.topViewController
          as! ScanningAccountCreationViewController
        scanningAccountCreationViewController.delegate = self
      }
    } else {
      let accountUpdateViewController = segue.destinationViewController
        as! AccountUpdateViewController
      let cell = sender as! AccountCell
      accountUpdateViewController.delegate = self
      accountUpdateViewController.account = cell.account
    }
  }

  private func persistAccountOrder() {
    let persistentRefs = accounts.map { $0.persistentRef! }
    userDefaults.setObject(persistentRefs, forKey: persistentRefsKey)
  }

  private func updateEditing() {
    if accounts.count == 0 {
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

  // MARK: UITableViewDataSource

  override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) ->
    Bool {
      return true
  }

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath,
    toIndexPath destinationIndexPath: NSIndexPath) {
      accounts.insert(accounts.removeAtIndex(sourceIndexPath.row),
        atIndex: destinationIndexPath.row)
      persistAccountOrder()
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return accounts.count
  }

  override func tableView(tableView: UITableView,
    cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCellWithIdentifier("AccountCell",
        forIndexPath: indexPath) as! AccountCell
      cell.account = accounts[indexPath.row]
      cell.delegate = self
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
          preferredStyle: .ActionSheet)

        let deleteAccountAction = UIAlertAction(title: "Delete Account", style: .Destructive) { _ in
          self.deleteAccountForRowAtIndexPath(indexPath)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)

        alertController.addAction(deleteAccountAction)
        alertController.addAction(cancelAction)

        presentViewController(alertController, animated: true, completion: nil)
      }
  }

  private func deleteAccountForRowAtIndexPath(indexPath: NSIndexPath) {
    let account = self.accounts[indexPath.row]
    guard self.keychain.deleteAccount(account) else {
      presentTryAgainAlertWithTitle(
        "Could Not Delete Account",
        message: "An error occurred when deleting the account from the keychain.") {
          self.deleteAccountForRowAtIndexPath(indexPath)
      }
      return
    }
    accounts.removeAtIndex(indexPath.row)
    persistAccountOrder()
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    updateEditing()
  }

  // MARK: UITableViewDelegate

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

  // MARK: UISearchResultsUpdating

  func updateSearchResultsForSearchController(searchController: UISearchController) {
    let accountSearchResultsViewController = searchController.searchResultsController
      as! AccountSearchResultsViewController
    accountSearchResultsViewController.accounts = accounts.filter {
      guard let string = searchController.searchBar.text else { return false }
      return $0.description.rangeOfString(string, options: .CaseInsensitiveSearch, range: nil,
        locale: nil) != nil
    }
  }

  // MARK: AccountCreationDelegate

  func createAccount(account: Account) {
    guard keychain.insertAccount(account) else {
      presentTryAgainAlertWithTitle(
        "Could Not Create Account",
        message: "An error occurred when inserting the account into the keychain.") {
          self.createAccount(account)
      }
      return
    }
    accounts.append(account)
    persistAccountOrder()
    let lastRow = accounts.count - 1
    let indexPaths = [NSIndexPath(forRow: lastRow, inSection: 0)]
    tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
    updateEditing()
  }

  // MARK: AccountUpdateDelegate

  func updateAccount(account: Account) {
    guard keychain.updateAccount(account) else {
      presentTryAgainAlertWithTitle(
        "Could Not Update Account",
        message: "An error occurred when persisting the account updates to the keychain.") {
          self.updateAccount(account)
      }
      return
    }
    let row = accounts.indexOf { $0 === account }!
    let indexPath = NSIndexPath(forRow: row, inSection: 0)
    guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? AccountCell else { return }
    cell.updateWithDate(NSDate())
  }

  private func presentTryAgainAlertWithTitle(title: String, message: String, handler: () -> Void) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)

    let tryAgainAccountAction = UIAlertAction(title: "Try again", style: .Default) { _ in
      handler()
    }

    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)

    alertController.addAction(tryAgainAccountAction)
    alertController.addAction(cancelAction)

    presentViewController(alertController, animated: true, completion: nil)
  }
}
