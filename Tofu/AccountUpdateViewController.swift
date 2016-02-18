import UIKit

final class AccountUpdateViewController: UITableViewController {
  @IBOutlet weak var nameField: UITextField!
  @IBOutlet weak var issuerField: UITextField!
  var delegate: AccountUpdateDelegate?
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
    delegate?.updateAccount(account)
  }
}
