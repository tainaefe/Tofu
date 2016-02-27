import UIKit

final class CircularProgressView: UIView {
  var progress: Double = 0 {
    didSet { maskLayer.strokeEnd = min(max(CGFloat(progress), 0), 1) }
  }
  private let maskLayer = CAShapeLayer()

  init() {
    let backgroundImage = UIImage(named: "CircularProgressViewBorderThin")!
    let backgroundImageView = UIImageView(image: backgroundImage)
    let image = UIImage(named: "CircularProgressViewBorderThick")!
    let imageView = UIImageView(image: image)
    super.init(frame: backgroundImageView.frame)
    let x = frame.size.width / 2
    let y = frame.size.height / 2
    let radius = max(x, y)
    let path = CGPathCreateMutable()
    CGPathMoveToPoint(path, nil, x, y - radius / 2)
    CGPathAddArc(path, nil, x, y, radius / 2, -CGFloat(M_PI) / 2, 3 * CGFloat(M_PI) / 2, false)
    maskLayer.fillColor = UIColor.clearColor().CGColor
    maskLayer.strokeColor = UIColor.blackColor().CGColor
    maskLayer.lineWidth = radius
    maskLayer.path = path
    maskLayer.strokeEnd = CGFloat(progress)
    imageView.layer.mask = maskLayer
    addSubview(backgroundImageView)
    addSubview(imageView)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
