import UIKit
import AVFoundation
import CoreData

final class ScanController: UIViewController, ManagedObjectContextSettable,
AVCaptureMetadataOutputObjectsDelegate {
  @IBOutlet weak var allowCameraAccessLabel: UILabel!
  var managedObjectContext: NSManagedObjectContext!
  private var session = AVCaptureSession()
  private var layer: AVCaptureVideoPreviewLayer?
  private var didCapture = false

  @IBAction func didPressCancel(sender: UIBarButtonItem) {
    presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    if let input = try? AVCaptureDeviceInput(device: device) {
      session.addInput(input)
      let output = AVCaptureMetadataOutput()
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
      guard !didCapture && metadataObjects.count > 0,
        let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject
        where metadataObject.type == AVMetadataObjectTypeQRCode,
        let url = NSURL(string: metadataObject.stringValue) else { return }
      didCapture = true
      _ = Account(url: url, insertIntoManagedObjectContext: managedObjectContext)
      try! managedObjectContext.save()
      presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
  }
}
