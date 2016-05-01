import UIKit

final class AccountSearchResultsViewController: UITableViewController, AccountUpdateDelegate {
  @IBOutlet var emptyView: UIView!
  var accounts: [Account]! {
    didSet {
      tableView.reloadData()
      tableView.backgroundView = accounts.count == 0 ? emptyView : nil
      tableView.separatorStyle = accounts.count == 0 ? .None : .SingleLine
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    let updater = AccountsTableViewUpdater(tableView: tableView)
    updater.startUpdating()
  }

  // MARK: UITableViewDataSource

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
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

  // MARK: UITableViewDelegate

  override func tableView(tableView: UITableView,
    shouldShowMenuForRowAtIndexPath indexPath: NSIndexPath) -> Bool {
      return true
  }

  override func tableView(tableView: UITableView, canPerformAction action: Selector,
    forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
      return action == #selector(copy(_:))
  }

  override func tableView(tableView: UITableView, performAction action: Selector,
    forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
      if action == #selector(copy(_:)) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! AccountCell
        UIPasteboard.generalPasteboard().string = cell.valueLabel.text?
          .stringByReplacingOccurrencesOfString(" ", withString: "")
      }
  }

  // MARK: AccountUpdateDelegate

  func updateAccount(account: Account) {
    (presentingViewController as! AccountUpdateDelegate).updateAccount(account)
    let row = accounts.indexOf { $0 === account }!
    let indexPath = NSIndexPath(forRow: row, inSection: 0)
    guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? AccountCell else { return }
    cell.updateWithDate(NSDate())
  }
}
