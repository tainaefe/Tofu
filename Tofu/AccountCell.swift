import UIKit

private func placeholderImageWithText(text: String) -> UIImage {
  let image = UIImage(named: "Placeholder")!
  UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
  image.drawAtPoint(CGPoint.zero)
  defer { UIGraphicsEndImageContext() }
  let paragraphStyle = NSMutableParagraphStyle()
  paragraphStyle.alignment = .Center
  let fontSize: CGFloat = 36
  let attributes = [
    NSFontAttributeName: UIFont.systemFontOfSize(fontSize, weight: UIFontWeightUltraLight),
    NSForegroundColorAttributeName: UIColor.lightGrayColor(),
    NSParagraphStyleAttributeName: paragraphStyle,
  ]
  let origin = CGPoint(x: 0, y: (image.size.height - fontSize) / 2 - 0.1 * fontSize)
  text.drawWithRect(CGRect(origin: origin, size: image.size), options: .UsesLineFragmentOrigin,
    attributes: attributes, context: nil)
  return UIGraphicsGetImageFromCurrentImageContext()
}

private func imageForAccount(account: Account) -> UIImage {
  switch account.issuer {
  case .Some("Bitbucket"): return UIImage(named: "Bitbucket")!
  case .Some("DigitalOcean"): return UIImage(named: "DigitalOcean")!
  case .Some("Dropbox"): return UIImage(named: "Dropbox")!
  case .Some("GitHub"): return UIImage(named: "GitHub")!
  case .Some("Google"): return UIImage(named: "Google")!
  case .Some("Heroku"): return UIImage(named: "Heroku")!
  case .Some("IFTTT"): return UIImage(named: "IFTTT")!
  case .Some("Stripe"): return UIImage(named: "Stripe")!
  default:
    let text = String(account.description.characters.first ?? "?").uppercaseString
    return placeholderImageWithText(text)
  }
}

private func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
  UIGraphicsBeginImageContext(size)
  color.setFill()
  UIRectFill(CGRectMake(0, 0, size.width, size.height))
  let image = UIGraphicsGetImageFromCurrentImageContext()
  UIGraphicsEndImageContext()
  return image;
}

final class AccountCell: UITableViewCell {
  @IBOutlet weak var accountImageView: UIImageView!
  @IBOutlet weak var valueLabel: UILabel!
  @IBOutlet weak var identifierLabel: UILabel!
  var delegate: AccountUpdateDelegate?
  private var value: String?
  private let button = UIButton(type: .Custom)
  private let progressView = CircularProgressView()

  var account: Account! {
    didSet {
      accountImageView.image = imageForAccount(account)
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
