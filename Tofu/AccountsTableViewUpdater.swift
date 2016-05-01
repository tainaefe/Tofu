import UIKit

final class AccountsTableViewUpdater: NSObject {
  var tableView: UITableView

  init(tableView: UITableView) {
    self.tableView = tableView
  }

  func startUpdating() {
    let timer = NSTimer(timeInterval: 1, target: self, selector: #selector(updateCells),
                        userInfo: nil, repeats: true)
    NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
  }

  func updateCells() {
    let now = NSDate()
    for cell in tableView.visibleCells {
      let accountCell = cell as! AccountCell
      accountCell.updateWithDate(now)
    }
  }
}
