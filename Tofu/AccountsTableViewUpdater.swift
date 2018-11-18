import UIKit

class AccountsTableViewUpdater: NSObject {
    var tableView: UITableView
    
    init(tableView: UITableView) {
        self.tableView = tableView
    }
    
    func startUpdating() {
        let timer = Timer(timeInterval: 1, target: self, selector: #selector(updateCells),
                          userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
    }
    
    @objc func updateCells() {
        let now = Date()
        for cell in tableView.visibleCells {
            let accountCell = cell as! AccountCell
            accountCell.updateWithDate(now)
        }
    }
}
