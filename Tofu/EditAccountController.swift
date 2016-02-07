import UIKit
import CoreData

final class EditAccountController: UITableViewController {
  @IBOutlet weak var nameField: UITextField!
  @IBOutlet weak var issuerField: UITextField!
  var account: Account!

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    nameField.text = account.name
    issuerField.text = account.issuer
  }

  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    account.name = nameField.text
    account.issuer = issuerField.text
    try! account.managedObjectContext?.save()
  }
}
