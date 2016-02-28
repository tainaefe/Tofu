import UIKit
import AVFoundation

final class ScanningAccountCreationViewController: UIViewController,
AVCaptureMetadataOutputObjectsDelegate {
  @IBOutlet weak var allowCameraAccessLabel: UILabel!
  var delegate: AccountCreationDelegate?
  private var session = AVCaptureSession()
  private let output = AVCaptureMetadataOutput()
  private var layer: AVCaptureVideoPreviewLayer?

  @IBAction func didPressCancel(sender: UIBarButtonItem) {
    output.setMetadataObjectsDelegate(nil, queue: nil)
    presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    if let input = try? AVCaptureDeviceInput(device: device) {
      session.addInput(input)
      session.addOutput(output)
      output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
      output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
      layer = AVCaptureVideoPreviewLayer(session: session)
      layer!.videoGravity = AVLayerVideoGravityResizeAspectFill
      view.layer.addSublayer(layer!)
      session.startRunning()
    } else {
      allowCameraAccessLabel.hidden = false
    }
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    layer?.frame = view.layer.bounds
    switch UIDevice.currentDevice().orientation {
    case .LandscapeLeft:
      layer?.connection.videoOrientation = .LandscapeRight
    case .LandscapeRight:
      layer?.connection.videoOrientation = .LandscapeLeft
    default:
      layer?.connection.videoOrientation = .Portrait
    }
  }

  // MARK: AVCaptureMetadataOutputObjectsDelegate

  func captureOutput(
    captureOutput: AVCaptureOutput!,
    didOutputMetadataObjects metadataObjects: [AnyObject]!,
    fromConnection connection: AVCaptureConnection!) {
      guard metadataObjects.count > 0,
        let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject
        where metadataObject.type == AVMetadataObjectTypeQRCode,
        let url = NSURL(string: metadataObject.stringValue),
        let account = Account(url: url) else { return }
      output.setMetadataObjectsDelegate(nil, queue: nil)
      presentingViewController?.dismissViewControllerAnimated(true) {
        self.delegate?.createAccount(account)
      }
  }
}
