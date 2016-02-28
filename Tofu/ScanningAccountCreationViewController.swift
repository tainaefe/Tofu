import UIKit
import AVFoundation

final class ScanningAccountCreationViewController: UIViewController,
AVCaptureMetadataOutputObjectsDelegate {
  @IBOutlet weak var allowCameraAccessView: UIView!
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

    if AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) == .Authorized {
      startScanning()
    } else {
      AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo) { granted in
        guard granted else { return }
        dispatch_async(dispatch_get_main_queue()) {
          self.startScanning()
        }
      }
    }
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    updateLayerFrameAndOrientation()
  }

  private func startScanning() {
    let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    if let input = try? AVCaptureDeviceInput(device: device) {
      allowCameraAccessView.hidden = true
      navigationItem.prompt = "Point your camera at a QR code to scan it."
      session.addInput(input)
      session.addOutput(output)
      output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
      output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
      layer = AVCaptureVideoPreviewLayer(session: session)
      layer!.videoGravity = AVLayerVideoGravityResizeAspectFill
      view.layer.addSublayer(layer!)
      updateLayerFrameAndOrientation()
      session.startRunning()
    }
  }

  private func updateLayerFrameAndOrientation() {
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
      delegate?.createAccount(account)
      presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
  }
}
