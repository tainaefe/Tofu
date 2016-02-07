import UIKit
import CoreData

final class AddAccountController: UITableViewController, ManagedObjectContextSettable,
AlgorithmsControllerDelegate {
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
  var managedObjectContext: NSManagedObjectContext!
  private var algorithm = HOTPAlgorithm.SHA1
  private var periodString: String?
  private var counterString: String?
  private let formatter: NSNumberFormatter = {
    let formatter = NSNumberFormatter()
    formatter.numberStyle = .NoStyle
    return formatter
  }()
  private var periodOrCounter: Int64? {
    guard periodCounterField.text?.characters.count > 0 else {
      if timeBasedSwitch.on {
        return 30
      }
      return 0
    }
    return formatter.numberFromString(periodCounterField.text!)?.longLongValue
  }

  @IBAction func didPressCancel(sender: UIBarButtonItem) {
    presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
  }

  @IBAction func didPressDone(sender: UIBarButtonItem) {
    _ = Account(name: nameField.text,
      issuer: issuerField.text,
      secret: NSData(base32EncodedString: secretField.text!)!,
      algorithm: algorithm,
      digits: eightDigitsSwitch.on ? 8 : 6,
      timeBased: timeBasedSwitch.on,
      periodOrCounter: periodOrCounter!,
      insertIntoManagedObjectContext: managedObjectContext)
    try! managedObjectContext.save()
    presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
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
    if let algorithmsController = segue.destinationViewController as? AlgorithmsController {
      algorithmsController.algorithms = [.SHA1, .SHA256, .SHA512]
      algorithmsController.selected = algorithm
      algorithmsController.delegate = self
    }
  }

  func didSelectAlgorithm(algorithm: HOTPAlgorithm) {
    self.algorithm = algorithm
    algorithmLabel.text = algorithm.name
  }

  private func validate() {
    doneItem.enabled = secretField.text?.characters.count > 0 &&
      NSData(base32EncodedString: secretField.text!) != nil && periodOrCounter != nil
  }
}
