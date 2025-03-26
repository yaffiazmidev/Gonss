//
//  KKQRCameraViewController.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 27/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import KipasKipasShared

class KKQRCameraViewController: UIViewController {
    private let mainView: KKQRCameraView
    
    private let session = AVCaptureSession()
    private var sessionResult: KKCameraSessionResult = .success
    private let sessionQueue = DispatchQueue(label: "KKQRCameraViewController_SessionQueue")
    private var isSessionRunning = false
    private var keyValueObservations = [NSKeyValueObservation]()
    @objc dynamic var videoDeviceInput : AVCaptureDeviceInput!
    private var flashMode : AVCaptureDevice.FlashMode

    var handleWhenExtracted: ((KKQRItem) -> Void)?
    var handleWhenClose: (() -> Void)?

    lazy var windowOrientation: UIInterfaceOrientation = {
        return view.window?.windowScene?.interfaceOrientation ?? .unknown
    }()
    
    init(){
        mainView = KKQRCameraView()
        flashMode = .off
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        self.view = mainView
        setupOnTap()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSession()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sessionQueue.async {
            switch self.sessionResult {
            case .success:
                // Only setup observers and start the session if setup succeeded.
                self.session.startRunning()
                self.addObservers()
                self.isSessionRunning = self.session.isRunning
                
            case .notAuthorized:
                DispatchQueue.main.async {
                    let changePrivacySetting = "AVCam doesn't have permission to use the camera, please change privacy settings"
                    let message = NSLocalizedString(changePrivacySetting, comment: "Alert message when the user has denied access to the camera")
                    let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
                    
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"), style: .`default`, handler: { _ in
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                    }))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
                
            case .configurationFailed:
                DispatchQueue.main.async {
                    let alertMsg = "Alert message when something goes wrong during capture session configuration"
                    let message = NSLocalizedString("Unable to capture media", comment: alertMsg)
                    let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
                                                            style: .cancel,
                                                            handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mainView.addFocusLayer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        sessionQueue.async {
            if self.sessionResult == .success {
                self.session.stopRunning()
                self.isSessionRunning = self.session.isRunning
                self.removeObservers()
            }
        }
        
        super.viewWillDisappear(animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - OnTap Handler
fileprivate extension KKQRCameraViewController {
    private func setupOnTap(){
        mainView.closeView.onTap(action: handleClose)
        mainView.flashView.onTap(action: handleFlash)
        mainView.updateFlashButton(flashMode)
        mainView.pickFromGalleryLabel.onTap {
            self.openImagePicker()
        }
    }
    
    @objc private func handleClose(){
        self.dismiss(animated: true, completion: handleWhenClose)
    }
    
    @objc private func handleFlash(){
        switch flashMode {
        case .off:
            flashMode = .on
            enableFlash()
        default:
            flashMode = .off
            disableFlash()
        }
        
        mainView.updateFlashButton(flashMode)
    }
    
    private func enableFlash(){
        do{
            if (videoDeviceInput.device.hasTorch == true){
                try videoDeviceInput.device.lockForConfiguration()
                videoDeviceInput.device.torchMode = .on
                videoDeviceInput.device.unlockForConfiguration()
            }
        }catch{
            //DISABEL FLASH BUTTON HERE IF ERROR
            print("Device tourch Flash Error ");
        }
    }
    
    private func disableFlash(){
        do{
            if (videoDeviceInput.device.hasTorch == true){
                try videoDeviceInput.device.lockForConfiguration()
                videoDeviceInput.device.torchMode = .off
                videoDeviceInput.device.unlockForConfiguration()
            }
        }catch{
            //DISABLE FLASH BUTTON HERE IF ERROR
            print("Device tourch Flash Error ");
        }
    }
    
    private func openImagePicker(){
        self.session.stopRunning()
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        picker.sourceType = .photoLibrary
        if let mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) {
            picker.mediaTypes = mediaTypes
        }
        self.present(picker, animated: true)
    }
}

//MARK: - Camera
fileprivate extension KKQRCameraViewController {
    private func setupSession(){
        mainView.previewView.session = session
        mainView.previewView.previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if !granted {
                    self.sessionResult = .notAuthorized
                }
                self.sessionQueue.resume()
            })
            
        default:
            sessionResult = .notAuthorized
        }
        
        sessionQueue.async {
            self.configureSession()
        }
    }
    
    private func configureSession() {
        if sessionResult != .success {
            return
        }
        
        session.beginConfiguration()
        
        session.sessionPreset = .photo
        
        do {
            var defaultVideoDevice: AVCaptureDevice?
            
            if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                // If a rear dual camera is not available, default to the rear wide angle camera.
                defaultVideoDevice = backCameraDevice
            } else if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                // If the rear wide angle camera isn't available, default to the front wide angle camera.
                defaultVideoDevice = frontCameraDevice
            }
            guard let videoDevice = defaultVideoDevice else {
                print("Default video device is unavailable.")
                sessionResult = .configurationFailed
                session.commitConfiguration()
                return
            }
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                
                DispatchQueue.main.async {
                    var initialVideoOrientation: AVCaptureVideoOrientation = .portrait
                    if self.windowOrientation != .unknown {
                        if let videoOrientation = AVCaptureVideoOrientation(interfaceOrientation: self.windowOrientation) {
                            initialVideoOrientation = videoOrientation
                        }
                    }
                    
                    self.mainView.previewView.previewLayer.connection?.videoOrientation = initialVideoOrientation
                }
            } else {
                print("Couldn't add video device input to the session.")
                sessionResult = .configurationFailed
                session.commitConfiguration()
                return
            }
        } catch {
            print("Couldn't create video device input: \(error)")
            sessionResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        // Add an audio input device.
        do {
            let audioDevice = AVCaptureDevice.default(for: .audio)
            let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice!)
            
            if session.canAddInput(audioDeviceInput) {
                session.addInput(audioDeviceInput)
            } else {
                print("Could not add audio device input to the session")
            }
        } catch {
            print("Could not create audio device input: \(error)")
        }
        
        // Add the photo output.
        let metadataOutput = AVCaptureMetadataOutput()
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            print("Could not add photo output to the session")
            sessionResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        session.commitConfiguration()
    }
}

// MARK: - UIImagePickerControllerDelegate
extension KKQRCameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        self.session.startRunning()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.session.startRunning()
        guard let img = info[.originalImage] as? UIImage else { return }
        
        self.dismiss(animated: true, completion: {
            self.readImage(img)
        })
    }
}

// MARK: - Capture delegate
extension KKQRCameraViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        session.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
    }
}

// MARK: - Observer
extension KKQRCameraViewController{
    private func addObservers() {
        let keyValueObservation = session.observe(\.isRunning, options: .new) { _, change in
        }
        keyValueObservations.append(keyValueObservation)
        let systemPressureStateObservation = observe(\.videoDeviceInput.device.systemPressureState, options: .new) { _, _ in
        }
        keyValueObservations.append(systemPressureStateObservation)
        
        NotificationCenter.default.addObserver(self, selector: #selector(sessionRuntimeError), name: .AVCaptureSessionRuntimeError, object: session)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionWasInterrupted), name: .AVCaptureSessionWasInterrupted, object: session)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionInterruptionEnded), name: .AVCaptureSessionInterruptionEnded, object: session)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
        
        for keyValueObservation in keyValueObservations {
            keyValueObservation.invalidate()
        }
        keyValueObservations.removeAll()
    }
    
    @objc func sessionRuntimeError(notification: NSNotification) {
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else { return }
        
        // If media services were reset, and the last start succeeded, restart the session.
        if error.code == .mediaServicesWereReset {
            sessionQueue.async {
                if self.isSessionRunning {
                    self.session.startRunning()
                    self.isSessionRunning = self.session.isRunning
                    
                }
            }
        }
    }
    
    @objc
    func sessionWasInterrupted(notification: NSNotification) {
        if let userInfoValue = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?,
           let reasonIntegerValue = userInfoValue.integerValue,
           let reason = AVCaptureSession.InterruptionReason(rawValue: reasonIntegerValue) {
            if reason == .videoDeviceNotAvailableInBackground {
                disableFlash()
            }
        }
    }
    
    @objc
    func sessionInterruptionEnded(notification: NSNotification) {
        if flashMode == .on {
            enableFlash()
            return
        }
        
        disableFlash()
    }
}

// MARK: - QR Handler
extension KKQRCameraViewController {
    
    private func readImage(_ img: UIImage){
        let result = KKQRHelper.decode(img)
        handleQRResult(result)
    }
    
    private func found(code: String) {
        let result = KKQRHelper.parseUrl(code)
        handleQRResult(result)
    }

    private func handleQRResult(_ result: KKQRHelper.Result) {
        switch result {
        case let .success(result):
            self.handleWhenExtracted?(result)
            self.dismiss(animated: true)
        case let .failure(error):
            showQRErrorDialog(error)
        }
    }

    private func showQRErrorDialog(_ error: KKQRError){
        let alert = UIAlertController(title: .get(.qrRecogFailTitle), message: nil, preferredStyle: .alert)

        switch error {
        case .failedRecognize:
            alert.message = .get(.qrNotFound)
        case .urlNotValid, .typeNotValid:
            alert.message = .get(.qrUrlNotValid)
        }

        alert.addAction(UIAlertAction(title: .get(.close), style: .cancel, handler: { action in
            if !self.session.isRunning{
                self.session.startRunning()
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
