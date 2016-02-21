import UIKit

private let formatter: NSNumberFormatter = {
  let formatter = NSNumberFormatter()
  formatter.numberStyle = .NoStyle
  return formatter
}()

final class ManualAccountCreationViewController: UITableViewController, AlgorithmSelectionDelegate {
  @IBOutlet weak var doneItem: UIBarButtonItem!
  @IBOutlet weak var nameField: UITextField!
  @IBOutlet weak var issuerField: UITextField!
  @IBOutlet weak var secretField: UITextField!
  @IBOutlet weak var algorithmLabel: UILabel!
  @IBOutlet weak var eightDigitsSwitch: UISwitch!
  @IBOutlet weak var timeBasedSwitch: UISwitch!
  @IBOutlet weak var periodCounterCell: UITableViewCell!
  @IBOutlet weak var periodCounterLabel: UILabel!
  @IBOutlet weak var periodCounterField: UITextField!
  var delegate: AccountCreationDelegate?
  private var algorithm = Algorithm.SHA1
  private var periodString: String?
  private var counterString: String?
  private var period: Int? {
    guard periodCounterField.text?.characters.count > 0 else { return 30 }
    return formatter.numberFromString(periodCounterField.text!)?.integerValue
  }
  private var counter: Int? {
    guard periodCounterField.text?.characters.count > 0 else { return 0 }
    return formatter.numberFromString(periodCounterField.text!)?.integerValue
  }

  @IBAction func didPressCancel(sender: UIBarButtonItem) {
    presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
  }

  @IBAction func didPressDone(sender: UIBarButtonItem) {
    let password = Password()
    password.timeBased = timeBasedSwitch.on
    password.algorithm = algorithm
    password.digits = eightDigitsSwitch.on ? 8 : 6
    password.secret = NSData(base32EncodedString: secretField.text!)!

    if timeBasedSwitch.on {
      password.period = period!
    } else {
      password.counter = counter!
    }

    let account = Account()
    account.name = nameField.text
    account.issuer = issuerField.text
    account.password = password

    presentingViewController?.dismissViewControllerAnimated(true) {
      self.delegate?.createAccount(account)
    }
  }

  @IBAction func editingChangedForTextField(textField: UITextField) {
    validate()
  }

  @IBAction func valueChangedForTimeBasedSwitch() {
    if self.timeBasedSwitch.on {
      counterString = periodCounterField.text
    } else {
      periodString = periodCounterField.text
    }
    UIView.transitionWithView(periodCounterCell,
      duration: 0.2,
      options: .TransitionCrossDissolve,
      animations: {
        if self.timeBasedSwitch.on {
          self.periodCounterLabel.text = "Period"
          self.periodCounterField.placeholder = String(30)
          self.periodCounterField.text = self.periodString
        } else {
          self.periodCounterLabel.text = "Counter"
          self.periodCounterField.placeholder = String(0)
          self.periodCounterField.text = self.counterString
        }
      }, completion: { _ in
        self.validate()
    })
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    nameField.becomeFirstResponder()
    algorithmLabel.text = algorithm.name
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let algorithmsController = segue.destinationViewController as? AlgorithmsViewController {
      algorithmsController.algorithms = [.SHA1, .SHA256, .SHA512]
      algorithmsController.selected = algorithm
      algorithmsController.delegate = self
    }
  }

  private func validate() {
    doneItem.enabled = secretField.text?.characters.count > 0 &&
      NSData(base32EncodedString: secretField.text!) != nil &&
      (timeBasedSwitch.on ? period != nil : counter != nil)
  }

  // MARK: AlgorithmSelectionDelegate

  func selectAlgorithm(algorithm: Algorithm) {
    self.algorithm = algorithm
    algorithmLabel.text = algorithm.name
  }
}
