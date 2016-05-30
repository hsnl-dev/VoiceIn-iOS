import UIKit
import AVFoundation
import SwiftyJSON
import SwiftOverlays

class QRCodeReaderViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePickerController = UIImagePickerController()
    
    @IBOutlet weak var messageLabel:UILabel!
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    @IBOutlet weak var selectFromGalaryButton: UIBarButtonItem!
    
    // MARK: Added to support different barcodes
    let supportedBarCodes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeUPCECode, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeAztecCode]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
        // as the media type parameter.
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        do {
            // MARK: Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // MAKR: Initialize the captureSession object.
            captureSession = AVCaptureSession()
            // MARK: Set the input device on the capture session.
            captureSession?.addInput(input)
            
            // MARK: Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // MARK: Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            
            // MARK: Detect all the supported bar code
            captureMetadataOutput.metadataObjectTypes = supportedBarCodes
            
            // MARK: Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // MARK: Start video capture
            captureSession?.startRunning()
            // MARK: Move the message label to the top view
            view.bringSubviewToFront(messageLabel)
            
            // MARK: Initialize QR Code Frame to highlight the QR code
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.greenColor().CGColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubviewToFront(qrCodeFrameView)
            }
            
        } catch {
            // MARK: If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        captureSession?.startRunning()
    }
    
    override func viewDidDisappear(animated: Bool) {
        captureSession?.stopRunning()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // MARK: Dispose of any resources that can be recreated.
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        // MARK: Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRectZero
            messageLabel.text = "- 請掃描 VoiceIn QRCode -"
            return
        }
        
        // MARK: Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        // Here we use filter method to check if the type of metadataObj is supported
        // Instead of hardcoding the AVMetadataObjectTypeQRCode, we check if the type
        // can be found in the array of supported bar codes.
        if supportedBarCodes.contains(metadataObj.type) {
            //        if metadataObj.type == AVMetadataObjectTypeQRCode {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                if let superview = self.view.superview {
                    SwiftOverlays.removeAllOverlaysFromView(superview)
                }
                
                let qrCodeArr = metadataObj.stringValue.componentsSeparatedByString("=")
                
                if qrCodeArr.count == 2 {
                    messageLabel.text = qrCodeArr[1]
                    if messageLabel.text == UserPref.getUserPrefByKey("qrCodeUuid") {
                        SwiftOverlays.showTextOverlay(self.view.superview!, text: "這是你自己的 QR Code 喔!")
                    } else {
                        self.performSegueWithIdentifier("isQRCodeReadSeque", sender: nil)
                    }
                } else {
                    SwiftOverlays.showTextOverlay(self.view.superview!, text: "無效的 QR Code 喔!")
                }

                captureSession?.stopRunning()
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "isQRCodeReadSeque" {
            // TODO: Send Data.
            if let providerInformationViewController = segue.destinationViewController as? ProviderInformationViewController {
                providerInformationViewController.qrCodeUuid = messageLabel.text
                
                if let superview = self.view.superview {
                    SwiftOverlays.removeAllOverlaysFromView(superview)
                }
            }
        }
    }
    
    @IBAction func imagePickerButtonClicked(sender: UIBarButtonItem!) {
        debugPrint("imagePickerButtonClicked: ")
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = false
        imagePickerController.sourceType = .PhotoLibrary
        
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let detector: CIDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])
            let ciImage: CIImage = CIImage(image: pickedImage)!
            
            if let superview = self.view.superview {
                SwiftOverlays.removeAllOverlaysFromView(superview)
            }
            
            var qrCodeLink = ""
            
            let features = detector.featuresInImage(ciImage)
            
            for feature in features as! [CIQRCodeFeature] {
                qrCodeLink += feature.messageString
            }
            
            dismissViewControllerAnimated(true, completion: nil)

            if qrCodeLink == "" {
                SwiftOverlays.showTextOverlay(self.view.superview!, text: "請選擇含有 VoiceIn QR Code 之圖片!")
            }else{
                let qrCodeArr = qrCodeLink.componentsSeparatedByString("=")
                debugPrint(qrCodeArr)
                if qrCodeArr.count == 2 {
                    messageLabel.text = qrCodeArr[1]
                    if messageLabel.text == UserPref.getUserPrefByKey("qrCodeUuid") {
                        SwiftOverlays.showTextOverlay(self.view.superview!, text: "這是你自己的 QR Code 喔!")
                    } else {
                        self.performSegueWithIdentifier("isQRCodeReadSeque", sender: nil)
                    }
                } else {
                    SwiftOverlays.showTextOverlay(self.view.superview!, text: "無效的 QR Code 喔!")
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func unwindToQrCodeReader(segue: UIStoryboardSegue) {
        
    }
    
}

