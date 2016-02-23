import UIKit

final class AccountSearchResultsViewController: UITableViewController {
  @IBOutlet var emptyLabel: UILabel!
  var accounts: [Account]! {
    didSet {
      tableView.reloadData()
      tableView.backgroundView = accounts.count == 0 ? emptyLabel : nil
      tableView.separatorStyle = accounts.count == 0 ? .None : .SingleLine
    }
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
      return cell
  }

  // MARK: UITableViewDelegate

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
}
