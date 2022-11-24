//
//  ZDScannerViewController.swift
//  ZDMediaPickerSDK
//
//  Created by lakshmi-12493 on 01/09/22.
//

import UIKit
import AVKit

protocol ZDScanFromPhotosProtocol {
    func didPopFromPhotos()
}


class ZDScannerViewController: UIViewController {

    @IBOutlet weak var scannerView: UIView!
    
    @IBOutlet weak var flash: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var qrFocusImage: UIImageView!
    
    @IBOutlet weak var uploadFromPhotos: UIButton!
        
    private var qrCodeImage: UIImage?
    private var didCaptureQR : Bool = false
    
    lazy var qrCodeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var captureSession : AVCaptureSession = {
        return AVCaptureSession()
    }()
    
    lazy var previewLayer : AVCaptureVideoPreviewLayer = {
      let layer = AVCaptureVideoPreviewLayer(session: captureSession)
        layer.frame = self.scannerView.layer.bounds
        layer.videoGravity = .resizeAspectFill
        return layer
    }()
    
    private lazy var blurEffectView: UIVisualEffectView = {
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurEffectView.frame = self.scannerView.layer.bounds
        blurEffectView.isHidden = true
        return blurEffectView
    }()
    
    private lazy var scannerOutputQueue : DispatchQueue = {
        return DispatchQueue(label: "qr_scanner")
    }()
    
    private lazy var videoInputQueue : DispatchQueue = {
        return DispatchQueue(label: "video_input")
    }()
    
    var localDelegate : ZDMediaPickerInternalProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSession()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.localDelegate = nil
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        selectionHaptic()
        dismissScanner(with: nil)
    }
    
    @IBAction func activateFlash(_ sender: Any) {
        enableFlash()
    }
    
    @IBAction func scanFromPhotos(_ sender: UIButton) {
        stopSession()
        if !didCaptureQR{
            self.localDelegate?.openPhotoLibrary(with: localDelegate , self)
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
        
    @objc func dismissScanner( with info : [AVMetadataObject]?) {
        /// Note : self.localDelegate becomes nil on dismissing while using MediaPicker alone(without platform)
        var delegate = self.localDelegate
        self.dismiss(animated: true) {
            if let info = info {
                delegate?.mediaPicker(didFinishScanning: info)
                delegate = nil
            }
            self.localDelegate = nil
        }
    }
    
    func configureSession() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        (captureSession.canAddInput(videoInput)) ? captureSession.addInput(videoInput) : handleScanError()

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: scannerOutputQueue)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            handleScanError()
        }
        let videoDataOutput = AVCaptureVideoDataOutput()
        if (captureSession.canAddOutput(videoDataOutput)) {
            captureSession.addOutput(videoDataOutput)
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            videoDataOutput.setSampleBufferDelegate(self, queue: videoInputQueue)
        } else {
            handleScanError()
        }

        scannerView.layer.addSublayer(previewLayer)
        scannerView.addSubview(qrCodeImageView)
        scannerView.addSubview(blurEffectView)
        startSession()
        bringAllSubViewsToFront()
    }
    
    func bringAllSubViewsToFront() {
        [blurEffectView, qrCodeImageView, qrFocusImage, flash, uploadFromPhotos, cancelButton].forEach { view in
            scannerView.bringSubviewToFront(view!)
        }
        qrFocusImage.center = scannerView.center
        qrCodeImageView.center = scannerView.center
    }
    
    func handleScanError() {
        self.localDelegate?.mediaPicker(didFail: .unableToScan)
        return
    }
    
    func handleFlashError() {
        self.localDelegate?.mediaPicker(didFail: .unableToFlash)
        return
    }
    
    func enableFlash() {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video),
                device.hasTorch
        else {
            handleFlashError()
            return
        }
        do {
            try device.lockForConfiguration()
            device.torchMode = (device.torchMode == .off) ? .on : .off
            selectionHaptic()
            device.unlockForConfiguration()
        } catch {
            handleFlashError()
        }
    }
    
    func selectionHaptic() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    func startSession() {
        scannerOutputQueue.async { [weak self] in
            if (self?.captureSession.isRunning == false) {
                self?.captureSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        scannerOutputQueue.async { [weak self] in
            if (self?.captureSession.isRunning == true) {
                self?.captureSession.stopRunning()
            }
        }
    }
    
}

extension ZDScannerViewController : ZDScanFromPhotosProtocol {
    func didPopFromPhotos() {
        self.startSession()
    }
}

extension ZDScannerViewController : AVCaptureMetadataOutputObjectsDelegate {
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let  metaObject = metadataObjects.first, let readableObject = previewLayer.transformedMetadataObject(for: metaObject) as? AVMetadataMachineReadableCodeObject, !didCaptureQR else { return }
        didCaptureQR = true
        DispatchQueue.main.async {
            self.moveImageViews(info: metadataObjects, corners: readableObject.corners)
        }
    }
    
    private func moveImageViews(info: [AVMetadataObject], corners: [CGPoint]) {
        assert(Thread.isMainThread)

        let path = UIBezierPath()
        path.move(to: corners[0])
        corners[1..<corners.count].forEach() {
            path.addLine(to: $0)
        }
        path.close()

        let aSide: CGFloat
        let bSide: CGFloat
        if corners[0].x < corners[1].x {
            aSide = corners[0].x - corners[1].x
            bSide = corners[1].y - corners[0].y
        } else {
            aSide = corners[2].y - corners[1].y
            bSide = corners[2].x - corners[1].x
        }
        let degrees = atan(aSide / bSide)

        var maxSide: CGFloat =  hypot(corners[3].x - corners[0].x, corners[3].y - corners[0].y)
        for (i, _) in corners.enumerated() {
            if i == 3 { break }
            let side = hypot(corners[i].x - corners[i+1].x, corners[i].y - corners[i+1].y)
            maxSide = side > maxSide ? side : maxSide
        }
        let focusImagePadding = 8.0
        maxSide += focusImagePadding * 2

        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            guard let self = self else { return }
            self.qrFocusImage.frame = path.bounds
            let center = self.qrFocusImage.center
            self.qrFocusImage.frame.size = CGSize(width: maxSide, height: maxSide)
            self.qrFocusImage.center = center
            self.qrFocusImage.transform = CGAffineTransform.identity.rotated(by: degrees)
            self.qrCodeImageView.frame = path.bounds
            self.qrCodeImageView.center = center
            }, completion: { [weak self] _ in
                guard let self = self else { return }
                self.qrCodeImageView.image = self.qrCodeImage
                self.blurEffectView.isHidden = false
                self.success(info: info)
        })
    }
    
    func success(info : [AVMetadataObject]) {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.dismissScanner(with: info)
        }
    }
}

extension ZDScannerViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        connection.videoOrientation = .portrait
        guard let qrCodeImage = getImageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        self.qrCodeImage = qrCodeImage
    }

    private func getImageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
        let scale = UIScreen.main.scale
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
        guard let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else { return nil }
        guard let cgImage = context.makeImage() else { return nil }

        let image = UIImage(cgImage: cgImage, scale: scale, orientation: .up)
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)

        return readQRCode(image)
    }

    private func readQRCode(_ image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        guard let features = detector?.features(in: ciImage) else { return nil }
        guard let feature = features.first as? CIQRCodeFeature else { return nil }

        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -ciImage.extent.size.height)
        let path = UIBezierPath()
        path.move(to: feature.topLeft.applying(transform))
        path.addLine(to: feature.topRight.applying(transform))
        path.addLine(to: feature.bottomRight.applying(transform))
        path.addLine(to: feature.bottomLeft.applying(transform))
        path.close()
        return image.crop(path)
    }
}

private extension UIImage {
    func crop(_ path: UIBezierPath) -> UIImage? {
        let rect = CGRect(origin: CGPoint(), size: CGSize(width: size.width * scale, height: size.height * scale))
        UIGraphicsBeginImageContextWithOptions(rect.size, false, scale)

        UIColor.clear.setFill()
        UIRectFill(rect)
        path.addClip()
        draw(in: rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let croppedImage = image?.cgImage?.cropping(to: CGRect(x: path.bounds.origin.x * scale, y: path.bounds.origin.y * scale, width: path.bounds.size.width * scale, height: path.bounds.size.height * scale)) else { return nil }
        return UIImage(cgImage: croppedImage, scale: scale, orientation: imageOrientation)
    }
}
