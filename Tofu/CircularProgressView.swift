import UIKit

final class CircularProgressView: UIView {
  let maskLayer = CAShapeLayer()

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
    maskLayer.strokeEnd = 1
    imageView.layer.mask = maskLayer
    addSubview(backgroundImageView)
    addSubview(imageView)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func animateProgressToZeroFrom(from: CGFloat, duration: Double) {
    let animation = CABasicAnimation()
    animation.keyPath = "strokeEnd"
    animation.fromValue = min(max(from, 0), 1)
    animation.toValue = 0
    animation.duration = duration
    animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
    maskLayer.addAnimation(animation, forKey: "progress")
    maskLayer.strokeEnd = 0
  }
}
