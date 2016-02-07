import UIKit

class AlgorithmsController: UITableViewController {
  var algorithms = [HOTPAlgorithm]()
  var selected: HOTPAlgorithm!
  var delegate: AlgorithmsControllerDelegate?

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1;
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return algorithms.count
  }

  override func tableView(tableView: UITableView,
    cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCellWithIdentifier("AlgorithmCell")!
      let algorithm = algorithms[indexPath.row]
      cell.textLabel?.text = algorithm.name
      cell.accessoryType = selected == algorithm ? .Checkmark : .None
      return cell
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    let previouslySelectedCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: algorithms.indexOf(selected)!, inSection: 0))!
    previouslySelectedCell.accessoryType = .None
    let selectedCell = tableView.cellForRowAtIndexPath(indexPath)!
    selectedCell.accessoryType = .Checkmark
    selected = algorithms[indexPath.row]
    delegate?.didSelectAlgorithm(selected)
  }
}
