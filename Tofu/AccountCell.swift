import UIKit

private func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
  UIGraphicsBeginImageContext(size)
  color.setFill()
  UIRectFill(CGRectMake(0, 0, size.width, size.height))
  let image = UIGraphicsGetImageFromCurrentImageContext()
  UIGraphicsEndImageContext()
  return image;
}

final class AccountCell: UITableViewCell {
  @IBOutlet weak var valueLabel: UILabel!
  @IBOutlet weak var identifierLabel: UILabel!
  var delegate: AccountUpdateDelegate?
  private var value: String?
  private let button = UIButton(type: .Custom)
  private let progressView = CircularProgressView()

  var account: Account! {
    didSet {
      accessoryView = account.password.timeBased ? progressView : button
      identifierLabel.text = account.description
      updateWithDate(NSDate())
    }
  }

  override func awakeFromNib() {
    button.titleLabel?.font = UIFont.boldSystemFontOfSize(13)
    button.setTitle("NEXT", forState: .Normal)
    button.setTitleColor(tintColor, forState: .Normal)
    button.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
    button.setTitleColor(UIColor.whiteColor(), forState: .Selected)
    button.layer.borderColor = button.tintColor.CGColor
    button.layer.borderWidth = 1
    button.layer.cornerRadius = 4
    button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
    button.sizeToFit()
    let image = imageWithColor(tintColor, size: button.bounds.size)
    button.setBackgroundImage(image, forState: .Highlighted)
    button.setBackgroundImage(image, forState: .Selected)
    button.clipsToBounds = true
    button.addTarget(self, action: "didPressButton:", forControlEvents: .TouchUpInside)
  }

  func updateWithDate(date: NSDate) {
    progressView.progress = account.password.progressForDate(date)
    let newValue = account.password.valueForDate(date)
    if value != newValue {
      value = newValue
      let length = newValue.characters.count
      let prefix = String(newValue.characters.prefix(length / 2))
      let suffix = String(newValue.characters.suffix(length - length / 2))
      UIView.transitionWithView(valueLabel, duration: 0.2, options: .TransitionCrossDissolve,
        animations: { self.valueLabel.text = "\(prefix) \(suffix)" }, completion: nil)
    }
  }

  func didPressButton(sender: UIButton) {
    account.password.counter++
    delegate?.updateAccount(account)
  }
}
