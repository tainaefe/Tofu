import UIKit

final class CircularProgressView: UIView {
  let maskLayer = CAShapeLayer()

  var progress: Float = 1 { didSet { updateMaskLayerPath() } }

  init() {
    let backgroundImage = UIImage(named: "CircularProgressViewBorderThin")!
    let backgroundImageView = UIImageView(image: backgroundImage)
    let image = UIImage(named: "CircularProgressViewBorderThick")!
    let imageView = UIImageView(image: image)
    super.init(frame: backgroundImageView.frame)
    addSubview(backgroundImageView)
    addSubview(imageView)
    imageView.layer.mask = maskLayer
    updateMaskLayerPath()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func updateMaskLayerPath() {
    let clampedProgress = min(1, max(0, progress))
    let path = CGPathCreateMutable()
    let x = frame.size.width / 2
    let y = frame.size.height / 2
    let radius = max(x, y)
    let startAngle = 1.5 * CGFloat(M_PI)
    let endAngle = startAngle + CGFloat(clampedProgress) * 2 * CGFloat(M_PI)
    CGPathAddArc(path, nil, x, y, radius, startAngle, endAngle, false)
    CGPathAddLineToPoint(path, nil, x, y)
    maskLayer.path = path
  }
}
