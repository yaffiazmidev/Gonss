import UIKit
import AVFoundation
import Photos

public enum KKCameraSessionResult {
    case success
    case notAuthorized
    case configurationFailed
}

public enum KKCameraType{
    case all
    case video
    case photo
}

public enum KKCameraPosition {
    case front
    case back
}

public final class KKCameraViewController: ContainerViewController {
    private let mainView: KKCameraView
    
    private let session = AVCaptureSession()
    private var sessionResult: KKCameraSessionResult = .success
    private let sessionQueue = DispatchQueue(label: "KKCameraViewController_SessionQueue")
    private var isSessionRunning = false
    private var keyValueObservations = [NSKeyValueObservation]()
    @objc dynamic var videoDeviceInput : AVCaptureDeviceInput!
    private var flashMode : AVCaptureDevice.FlashMode = .off
    private var selectedSemanticSegmentationMatteTypes = [AVSemanticSegmentationMatte.MatteType]()
    private let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera], mediaType: .video, position: .unspecified)
    private var backgroundRecordingID: UIBackgroundTaskIdentifier?
    
    private var movieFileOutput: AVCaptureMovieFileOutput?
    private let photoOutput = AVCapturePhotoOutput()
    private var inProgressPhotoCaptureDelegates = [Int64: PhotoCaptureProcessor]()
    private var photoQualityPrioritizationMode: AVCapturePhotoOutput.QualityPrioritization = .balanced
    private var inProgressLivePhotoCapturesCount = 0
    
    private let type: KKCameraType
    private let position: KKCameraPosition
    private let limitVideo = 180
    private var videoTimer : Timer = Timer()
    private var vTimer = -1
    private var images: [UIImage] = []
    private var isVideoSegment: Bool
    private var canPickFromGallery: Bool
    
    public var handleMediaSelected: ((KKMediaItem) -> Void)?
    
    public var showLiveStreamAnchor: (() -> Void)?
    
    lazy var windowOrientation: UIInterfaceOrientation = {
        return view.window?.windowScene?.interfaceOrientation ?? .unknown
    }()
    
    lazy var progressHud: CPKProgressHUD = {
        return CPKProgressHUD.progressHUD(style: .loading(text: nil))
    }()
    
    public init(type: KKCameraType = .all, canPickFromGallery: Bool = true, showLive: Bool = false, position: KKCameraPosition = .back){
        mainView = KKCameraView()
        self.type = type
        self.canPickFromGallery = canPickFromGallery
        self.position = position
        isVideoSegment = type == .video
        super.init(nibName: nil, bundle: nil)
        mainView.updateLive(show: showLive)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        super.loadView()
        self.view = mainView
        setupOnTap()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        KKLogFile.instance.log(label:"KKCameraViewController", message: "open")
        
        setupSession()
        switch(type){
        case .photo:
            fetchPhotos()
            handlePhotoSegment()
        case .video:
            handleVideoSegment()
        case .all:
            fetchPhotos()
            handlePhotoSegment()
        }
        mainView.segmentedStackView.isHidden = (type != .all)
        mainView.galleryImageView.isHidden = !canPickFromGallery
    }
    
    public override func viewWillAppear(_ animated: Bool) {
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
                    let changePrivacySetting = "Camera doesn't have permission to use the camera, please change privacy settings"
                    let message = NSLocalizedString(changePrivacySetting, comment: "Alert message when the user has denied access to the camera")
                    let alertController = UIAlertController(title: "Permission not Granted", message: message, preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: { _ in
                        self.dismiss(animated: true)
                    }))
                    
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"), style: .`default`, handler: { _ in
                        self.dismiss(animated: false) {
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                        }
                    }))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
                
            case .configurationFailed:
                DispatchQueue.main.async {
                    let alertMsg = "Alert message when something goes wrong during capture session configuration"
                    let message = NSLocalizedString("Unable to capture media", comment: alertMsg)
                    let alertController = UIAlertController(title: "Configuration Failed", message: message, preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
                                                            style: .cancel,
                                                            handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        sessionQueue.async {
            if self.sessionResult == .success {
                self.session.stopRunning()
                self.isSessionRunning = self.session.isRunning
                self.removeObservers()
            }
        }
        super.viewWillDisappear(animated)
    }
    
    public override var shouldAutorotate: Bool {
        // Disable autorotation of the interface when recording is in progress.
        if let movieFileOutput = movieFileOutput {
            return !movieFileOutput.isRecording
        }
        return true
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if let videoPreviewLayerConnection = mainView.previewView.previewLayer.connection {
            let deviceOrientation = UIDevice.current.orientation
            guard let newVideoOrientation = AVCaptureVideoOrientation(deviceOrientation: deviceOrientation),
                  deviceOrientation.isPortrait || deviceOrientation.isLandscape else {
                return
            }
            videoPreviewLayerConnection.videoOrientation = newVideoOrientation
        }
    }
}

// MARK: - OnTap Handler
extension KKCameraViewController{
    private func setupOnTap(){
        mainView.closeView.onTap(action: handleClose)
        mainView.flashView.onTap(action: handleFlash)
        mainView.updateFlashButton(flashMode)
        mainView.videoSegmentView.onTap {
            self.handleVideoSegment()
        }
        mainView.photoSegmentView.onTap {
            self.handlePhotoSegment()
        }
        mainView.galleryImageView.onTap {
            self.handlePickGallery()
        }
        
        mainView.flipButton.addTarget(self, action: #selector(handleFlipCamera(_:)), for: .touchUpInside)
        
        mainView.liveStreamingSegmentView.onTap { [showLiveStreamAnchor] in
            showLiveStreamAnchor?()
        }
    }
    
    @objc private func handleClose(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func handleFlash(){
        switch flashMode {
        case .off:
            flashMode = .auto
        case .auto:
            flashMode = .on
        default:
            flashMode = .off
        }
        
        mainView.updateFlashButton(flashMode)
    }
    
    private func handleVideoSegment(){
        isVideoSegment = true
        handleSegmentChanged()
    }
    
    private func handlePhotoSegment(){
        isVideoSegment = false
        handleSegmentChanged()
    }
    
    private func handleSegmentChanged(){
        mainView.updateSegmentView(isVideoSegment)
        UIView.animate(withDuration: 0.25) {
            self.mainView.flashView.alpha = self.isVideoSegment ? 0 : 1
            self.mainView.shootButton.backgroundColor = self.isVideoSegment ? .red : .white
        }
        mainView.shootButton.removeTarget(self, action: nil, for: .allTouchEvents)
        if isVideoSegment{
            setVideo()
        }else{
            setPhoto()
        }
    }
    
    private func handlePickGallery(){
        var mediaTypes: [KKMediaItemType]
        switch(type){
        case .all:
            mediaTypes = [.photo, .video]
            break;
        case .photo:
            mediaTypes = [.photo]
            break;
        case .video:
            mediaTypes = [.video]
            break;
        }
        
        let picker = KKMediaPicker()
        picker.delegate = self
        picker.types = mediaTypes
        picker.show(in: self)
    }
    
    @IBAction private func capturePhoto(_ photoButton: UIButton) {
        /*
         Retrieve the video preview layer's video orientation on the main queue before
         entering the session queue. Do this to ensure that UI elements are accessed on
         the main thread and session configuration is done on the session queue.
         */
        let videoPreviewLayerOrientation = mainView.previewView.previewLayer.connection?.videoOrientation
        sessionQueue.async {
            if let photoOutputConnection = self.photoOutput.connection(with: .video) {
                photoOutputConnection.videoOrientation = videoPreviewLayerOrientation!
            }
            var photoSettings = AVCapturePhotoSettings()
            
            // Capture HEIF photos when supported. Enable auto-flash and high-resolution photos.
            if  self.photoOutput.availablePhotoCodecTypes.contains(.jpeg) {
                photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
            }
            
            if self.videoDeviceInput.device.isFlashAvailable {
                photoSettings.flashMode = self.flashMode
            }
            
            photoSettings.isHighResolutionPhotoEnabled = true
            if !photoSettings.__availablePreviewPhotoPixelFormatTypes.isEmpty {
                photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoSettings.__availablePreviewPhotoPixelFormatTypes.first!]
            }
            
            photoSettings.photoQualityPrioritization = self.photoQualityPrioritizationMode
            
            let photoCaptureProcessor = PhotoCaptureProcessor(with: photoSettings, willCapturePhotoAnimation: {
                // Flash the screen to signal that AVCam took a photo.
                DispatchQueue.main.async {
                    self.mainView.previewView.previewLayer.opacity = 0
                    UIView.animate(withDuration: 0.25) {
                        self.mainView.previewView.previewLayer.opacity = 1
                    }
                }
            }, livePhotoCaptureHandler: { capturing in
            }, completionHandler: { photoCaptureProcessor, dataImage in
                // When the capture is complete, remove a reference to the photo capture delegate so it can be deallocated.
                self.sessionQueue.async {
                    self.inProgressPhotoCaptureDelegates[photoCaptureProcessor.requestedPhotoSettings.uniqueID] = nil
                }
                
                guard let imageURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("TempImage.jpeg") else {
                    return
                }

                // save image to URL
                do {
									let oriendtedImage = UIImage(data: dataImage)?.fixedOrientation()
                     try oriendtedImage!.pngData()?.write(to: imageURL)
                } catch {
                    
                }
                
                DispatchQueue.main.async {
                    self.fetchPhotos()
                    self.handlePhotoUrlToPreview(url: imageURL)
                }
            }, photoProcessingHandler: { animate in
                // Animates a spinner while photo is processing
                //                DispatchQueue.main.async {
                //                    if animate {
                //                        self.spinner.hidesWhenStopped = true
                //                        self.spinner.center = CGPoint(x: self.previewView.frame.size.width / 2.0, y: self.previewView.frame.size.height / 2.0)
                //                        self.spinner.startAnimating()
                //                    } else {
                //                        self.spinner.stopAnimating()
                //                    }
                //                }
            }
            )
            
            // The photo output holds a weak reference to the photo capture delegate and stores it in an array to maintain a strong reference.
            self.inProgressPhotoCaptureDelegates[photoCaptureProcessor.requestedPhotoSettings.uniqueID] = photoCaptureProcessor
            self.photoOutput.capturePhoto(with: photoSettings, delegate: photoCaptureProcessor)
        }
    }
    
    @IBAction private func captureVideo(_ photoButton: UIButton) {
        guard let movieFileOutput = self.movieFileOutput else {
            return
        }
        
        let videoPreviewLayerOrientation = mainView.previewView.previewLayer.connection?.videoOrientation
        
        let isRecord = movieFileOutput.isRecording
        setRecord(isRecord)
        sessionQueue.async {
            if !isRecord {
                if UIDevice.current.isMultitaskingSupported {
                    self.backgroundRecordingID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
                }
                
                // Update the orientation on the movie file output video connection before recording.
                let movieFileOutputConnection = movieFileOutput.connection(with: .video)
                movieFileOutputConnection?.videoOrientation = videoPreviewLayerOrientation!
                
                let availableVideoCodecTypes = movieFileOutput.availableVideoCodecTypes
                
                if availableVideoCodecTypes.contains(.hevc) {
                    movieFileOutput.setOutputSettings([AVVideoCodecKey: AVVideoCodecType.hevc], for: movieFileOutputConnection!)
                }
                
                // Start recording video to a temporary file.
                let outputFileName = NSUUID().uuidString
                let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((outputFileName as NSString).appendingPathExtension("mp4")!)
                movieFileOutput.startRecording(to: URL(fileURLWithPath: outputFilePath), recordingDelegate: self)
            } else {
                movieFileOutput.stopRecording()
            }
        }
    }
    
    @IBAction private func handleFlipCamera(_ btn: UIButton) {
        let currentVideoDevice = videoDeviceInput.device
        let currentPosition = currentVideoDevice.position
        
        let position: KKCameraPosition
        
        switch currentPosition {
        case .unspecified, .front:
            position = .back
        case .back:
            position = .front
        @unknown default:
            print("Unknown capture position. Defaulting to back, dual-camera.")
            position = .back
        }
        
        setCameraPosition(with: position)
    }
}

// MARK: - Capture & Recorder
extension KKCameraViewController {
    private func setPhoto(){
        mainView.shootButton.addTarget(self, action: #selector(capturePhoto(_:)), for: .touchUpInside)
        sessionQueue.async {
            self.session.beginConfiguration()
            if let movieFileOutput = self.movieFileOutput{
                self.session.removeOutput(movieFileOutput)
            }
            self.session.sessionPreset = .iFrame1280x720
            
            self.movieFileOutput = nil
            
            if self.photoOutput.isLivePhotoCaptureSupported {
                self.photoOutput.isLivePhotoCaptureEnabled = true
            }
            if self.photoOutput.isDepthDataDeliverySupported {
                self.photoOutput.isDepthDataDeliveryEnabled = true
            }
            
            if self.photoOutput.isPortraitEffectsMatteDeliverySupported {
                self.photoOutput.isPortraitEffectsMatteDeliveryEnabled = true
            }
            
            if !self.photoOutput.availableSemanticSegmentationMatteTypes.isEmpty {
                self.photoOutput.enabledSemanticSegmentationMatteTypes = self.photoOutput.availableSemanticSegmentationMatteTypes
                self.selectedSemanticSegmentationMatteTypes = self.photoOutput.availableSemanticSegmentationMatteTypes
            }
            
            self.session.commitConfiguration()
        }
    }
    
    private func setVideo(){
        mainView.shootButton.addTarget(self, action: #selector(captureVideo(_:)), for: .touchUpInside)
        sessionQueue.async {
            let movieFileOutput = AVCaptureMovieFileOutput()
            movieFileOutput.movieFragmentInterval = .invalid
            if self.session.canAddOutput(movieFileOutput) {
                self.session.beginConfiguration()
                self.session.addOutput(movieFileOutput)
                self.session.sessionPreset = .high
                if let connection = movieFileOutput.connection(with: .video) {
                    if connection.isVideoStabilizationSupported {
                        connection.preferredVideoStabilizationMode = .auto
                    }
                }
                self.session.commitConfiguration()
                self.movieFileOutput = movieFileOutput
            }
        }
    }
    
    private func setRecord(_ isRecord: Bool){
        self.mainView.shootButton.backgroundColor = !isRecord ? .white : .red
        self.mainView.shootWidthAnchor.constant = !isRecord ? 36 : 54
        self.mainView.shootHeightAnchor.constant = !isRecord ? 36: 54
        
        UIView.animate(withDuration: 0.25) {
            self.mainView.shootButton.layer.cornerRadius = !isRecord ? 8 : 27
            self.mainView.timerView.alpha = !isRecord ? 1 : 0
            self.mainView.closeView.alpha = !isRecord ? 0 : 1
            self.mainView.flipButton.alpha = !isRecord ? 0 : 1
            self.mainView.segmentedStackView.alpha = !isRecord ? 0 : 1
            self.mainView.galleryImageView.alpha = !isRecord ? 0 : 1
            self.mainView.shootView.layer.borderWidth = !isRecord ? 4 : 2
            self.mainView.shootButton.layoutIfNeeded()
        }
        
        videoTimer.invalidate()
        if !isRecord{
            vTimer = -1
            videoTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            videoTimer.fire()
        }
    }
}

// MARK: - Observers & Session
extension KKCameraViewController {
    private func setupSession(){
        // Set up the video preview view.
        mainView.previewView.session = session
        mainView.previewView.previewLayer.videoGravity = AVLayerVideoGravity.resize
        /*
         Check the video authorization status. Video access is required and audio
         access is optional. If the user denies audio access, AVCam won't
         record audio during movie recording.
         */
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // The user has previously granted access to the camera.
            break
            
        case .notDetermined:
            /*
             The user has not yet been presented with the option to grant
             video access. Suspend the session queue to delay session
             setup until the access request has completed.
             
             Note that audio access will be implicitly requested when we
             create an AVCaptureDeviceInput for audio during session setup.
             */
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if !granted {
                    self.sessionResult = .notAuthorized
                }
                self.sessionQueue.resume()
            })
            
        default:
            // The user has previously denied access.
            sessionResult = .notAuthorized
        }
        
        /*
         Setup the capture session.
         In general, it's not safe to mutate an AVCaptureSession or any of its
         inputs, outputs, or connections from multiple threads at the same time.
         
         Don't perform these tasks on the main queue because
         AVCaptureSession.startRunning() is a blocking call, which can
         take a long time. Dispatch session setup to the sessionQueue, so
         that the main queue isn't blocked, which keeps the UI responsive.
         */
        sessionQueue.async {
            self.configureSession()
        }
    }
    
    private func configureSession() {
        if sessionResult != .success {
            return
        }
        
        session.beginConfiguration()
        
        /*
         Do not create an AVCaptureMovieFileOutput when setting up the session because
         Live Photo is not supported when AVCaptureMovieFileOutput is added to the session.
         */
        session.sessionPreset = .photo
        
        // Add video input.
        do {
            var defaultVideoDevice: AVCaptureDevice?
            
            // Choose the back dual camera, if available, otherwise default to a wide angle camera.
            
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
                    /*
                     Dispatch video streaming to the main queue because AVCaptureVideoPreviewLayer is the backing layer for PreviewView.
                     You can manipulate UIView only on the main thread.
                     Note: As an exception to the above rule, it's not necessary to serialize video orientation changes
                     on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
                     
                     Use the window scene's orientation as the initial video orientation. Subsequent orientation changes are
                     handled by CameraViewController.viewWillTransition(to:with:).
                     */
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
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            photoOutput.isHighResolutionCaptureEnabled = true
            photoOutput.isPortraitEffectsMatteDeliveryEnabled = photoOutput.isPortraitEffectsMatteDeliverySupported
            photoOutput.enabledSemanticSegmentationMatteTypes = photoOutput.availableSemanticSegmentationMatteTypes
            selectedSemanticSegmentationMatteTypes = photoOutput.availableSemanticSegmentationMatteTypes
            photoOutput.maxPhotoQualityPrioritization = .balanced
            photoQualityPrioritizationMode = .balanced
            
        } else {
            print("Could not add photo output to the session")
            sessionResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        session.commitConfiguration()
        setCameraPosition(with: position)
    }
    
    private func addObservers() {
        let keyValueObservation = session.observe(\.isRunning, options: .new) { _, change in
        }
        
        keyValueObservations.append(keyValueObservation)
        
        let systemPressureStateObservation = observe(\.videoDeviceInput.device.systemPressureState, options: .new) { _, change in
            guard let systemPressureState = change.newValue else { return }
            self.setRecommendedFrameRateRangeForPressureState(systemPressureState: systemPressureState)
        }
        keyValueObservations.append(systemPressureStateObservation)
        
        NotificationCenter.default.addObserver(self, selector: #selector(subjectAreaDidChange), name: .AVCaptureDeviceSubjectAreaDidChange, object: videoDeviceInput.device)
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
    
    @objc func subjectAreaDidChange(notification: NSNotification) {
        //        let devicePoint = CGPoint(x: 0.5, y: 0.5)
        //        focus(with: .continuousAutoFocus, exposureMode: .continuousAutoExposure, at: devicePoint, monitorSubjectAreaChange: false)
    }
    
    /// - Tag: HandleRuntimeError
    @objc func sessionRuntimeError(notification: NSNotification) {
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else { return }
        
        print("Capture session runtime error: \(error)")
        // If media services were reset, and the last start succeeded, restart the session.
        if error.code == .mediaServicesWereReset {
            sessionQueue.async {
                if self.isSessionRunning {
                    self.session.startRunning()
                    self.isSessionRunning = self.session.isRunning
                } else {
                    DispatchQueue.main.async {
                        //                        self.resumeButton.isHidden = false
                    }
                }
            }
        } else {
            //            resumeButton.isHidden = false
        }
    }
    
    /// - Tag: HandleInterruption
    @objc
    func sessionWasInterrupted(notification: NSNotification) {
        /*
         In some scenarios you want to enable the user to resume the session.
         For example, if music playback is initiated from Control Center while
         using AVCam, then the user can let AVCam resume
         the session running, which will stop music playback. Note that stopping
         music playback in Control Center will not automatically resume the session.
         Also note that it's not always possible to resume, see `resumeInterruptedSession(_:)`.
         */
        if let userInfoValue = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?,
           let reasonIntegerValue = userInfoValue.integerValue,
           let reason = AVCaptureSession.InterruptionReason(rawValue: reasonIntegerValue) {
            print("Capture session was interrupted with reason \(reason)")
            
            var showResumeButton = false
            if reason == .audioDeviceInUseByAnotherClient || reason == .videoDeviceInUseByAnotherClient {
                showResumeButton = true
            } else if reason == .videoDeviceNotAvailableWithMultipleForegroundApps {
                // Fade-in a label to inform the user that the camera is unavailable.
                //                cameraUnavailableLabel.alpha = 0
                //                cameraUnavailableLabel.isHidden = false
                UIView.animate(withDuration: 0.25) {
                    //                    self.cameraUnavailableLabel.alpha = 1
                }
            } else if reason == .videoDeviceNotAvailableDueToSystemPressure {
                print("Session stopped running due to shutdown system pressure level.")
            }
            if showResumeButton {
                setRecord(true)
            }
        }
    }
    
    @objc
    func sessionInterruptionEnded(notification: NSNotification) {
        print("Capture session interruption ended")
    }
    
    private func setRecommendedFrameRateRangeForPressureState(systemPressureState: AVCaptureDevice.SystemPressureState) {
        let pressureLevel = systemPressureState.level
        if pressureLevel == .serious || pressureLevel == .critical {
            if self.movieFileOutput == nil || self.movieFileOutput?.isRecording == false {
                do {
                    try self.videoDeviceInput.device.lockForConfiguration()
                    print("WARNING: Reached elevated system pressure level: \(pressureLevel). Throttling frame rate.")
                    self.videoDeviceInput.device.activeVideoMinFrameDuration = CMTime(value: 1, timescale: 20)
                    self.videoDeviceInput.device.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: 15)
                    self.videoDeviceInput.device.unlockForConfiguration()
                } catch {
                    print("Could not lock device for configuration: \(error)")
                }
            }
        } else if pressureLevel == .shutdown {
            print("Session stopped running due to shutdown system pressure level.")
        }
    }
}

// MARK: - AV Delegate
extension KKCameraViewController: AVCaptureFileOutputRecordingDelegate{
    public func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        // Note: Because we use a unique file path for each recording, a new recording won't overwrite a recording mid-save.
        func cleanup() {
            let path = outputFileURL.path
            if FileManager.default.fileExists(atPath: path) {
                do {
                    try FileManager.default.removeItem(atPath: path)
                } catch {
                    print("Could not remove file at url: \(outputFileURL)")
                }
            }
            
            if let currentBackgroundRecordingID = backgroundRecordingID {
                backgroundRecordingID = UIBackgroundTaskIdentifier.invalid
                
                if currentBackgroundRecordingID != UIBackgroundTaskIdentifier.invalid {
                    UIApplication.shared.endBackgroundTask(currentBackgroundRecordingID)
                }
            }
        }
        
        var success = true
        
        if error != nil {
            success = (((error! as NSError).userInfo[AVErrorRecordingSuccessfullyFinishedKey] as AnyObject).boolValue) ?? false
            setRecord(true)
        }
        
        if success {
            // Check the authorization status.
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    // Save the movie file to the photo library and cleanup.
                    PHPhotoLibrary.shared().performChanges({
                        let options = PHAssetResourceCreationOptions()
                        options.shouldMoveFile = true
                        let creationRequest = PHAssetCreationRequest.forAsset()
                        creationRequest.addResource(with: .video, fileURL: outputFileURL, options: options)
                    }, completionHandler: { success, error in
                        if !success {
                            print("AVCam couldn't save the movie to your photo library: \(String(describing: error))")
                        }
                        else{
                            KKLogFile.instance.log(label:"KKCameraViewController", message: "fileOutput")

                            let fetchOptions = PHFetchOptions()
                            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                            let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions).lastObject
                            let options = PHVideoRequestOptions()
                            options.version = .original
                            PHImageManager().requestAVAsset(forVideo: fetchResult!, options: nil, resultHandler: { (avurlAsset, audioMix, dict) in
                                let asset = avurlAsset as! AVURLAsset
                                self.handleVideoUrlToPreview(url: asset.url)
                            })
                        }
                        cleanup()
                    }
                    )
                } else {
                    cleanup()
                }
            }
        } else {
            cleanup()
        }
        
        fetchPhotos()
    }
}

// MARK: - For get image from gallery
extension KKCameraViewController{
    private func fetchPhotos () {
        images = []
        // Sort the images by descending creation date and fetch the first 3
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        fetchOptions.fetchLimit = 1
        
        // Fetch the image assets
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
        
        // If the fetch result isn't empty,
        // proceed with the image request
        if fetchResult.count > 0 {
            let totalImageCountNeeded = 1 // <-- The number of images to fetch
            fetchPhotoAtIndex(0, totalImageCountNeeded, fetchResult)
            self.mainView.galleryImageView.image = self.images.first
        }
    }
    
    private func fetchPhotoAtIndex(_ index:Int, _ totalImageCountNeeded: Int, _ fetchResult: PHFetchResult<PHAsset>) {
        
        // Note that if the request is not set to synchronous
        // the requestImageForAsset will return both the image
        // and thumbnail; by setting synchronous to true it
        // will return just the thumbnail
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        // Perform the image request
        PHImageManager.default().requestImage(for: fetchResult.object(at: index) as PHAsset, targetSize: view.frame.size, contentMode: PHImageContentMode.aspectFill, options: requestOptions, resultHandler: { (image, info) in
            if let image = image {
                // Add the returned image to your array
                self.images += [image]
            }
            // If you haven't already reached the first
            // index of the fetch result and if you haven't
            // already stored all of the images you need,
            // perform the fetch request again with an
            // incremented index
            if index + 1 < fetchResult.count && self.images.count < totalImageCountNeeded {
                self.fetchPhotoAtIndex(index + 1, totalImageCountNeeded, fetchResult)
            } else {
                // Else you have completed creating your array
            }
        })
    }
}

extension KKCameraViewController: KKMediaPickerDelegate {
    public func didPermissionRejected() {
        KKMediaPicker.showAlertForAskPhotoPermisson(in: self)
    }
    
    public func didLoading(isLoading: Bool) {
        KKLogFile.instance.log(label:"KKCameraViewController", message: "didLoading")

        if isLoading {
            DispatchQueue.main.async {
                self.progressHud.show(in: self.view)
            }
        } else {
            DispatchQueue.main.async {
                self.progressHud.dismiss()
            }
        }
    }
    
    public func didSelectMedia(media item: KKMediaItem) {
        KKLogFile.instance.log(label:"KKCameraViewController", message: "didSelectMedia")

        DispatchQueue.main.async {
            self.toPreview(with: item)
        }
    }
    
    public func displayError(message: String) {
        
    }

}

// MARK: - Picker Media Handler
private extension KKCameraViewController {
    private func handlePhotoUrlToPreview(url: URL) {
        if let item = KKMediaHelper.instance.photo(url: url) {
            toPreview(with: item)
        }
    }
    
    private func handleVideoUrlToPreview(url: URL) {
        DispatchQueue.main.async {
            self.progressHud.show(in: self.view)
        }
        
        KKMediaHelper.instance.video(url: url) { [weak self] (item, message) in
            guard let self = self, let item = item else {
                if let message = message {
                    self?.showToast(with: message)
                }
                self?.progressHud.dismiss()
                return
            }
            DispatchQueue.main.async {
                self.progressHud.dismiss()
                self.toPreview(with: item)
            }
        }
    }
}

//MARK: - Helper
private extension KKCameraViewController {
    @objc private func updateTimer(){
        vTimer += 1
        let time = secondsToMinutesSeconds(seconds: vTimer)
        let timeString = makeTimeString(minutes: time.minutes, seconds: time.seconds)
        mainView.timerLabel.text = timeString
    }
    
    private func secondsToMinutesSeconds(seconds: Int) -> (minutes: Int, seconds: Int)
    {
        let minutes = ((seconds % 3600) / 60)
        let seconds = ((seconds % 3600) % 60)
        return (minutes, seconds)
    }
    
    private func makeTimeString(minutes: Int, seconds : Int) -> String {
        var timeString = ""
        timeString += String(format: "%02d", minutes)
        timeString += " : "
        timeString += String(format: "%02d", seconds)
        return timeString
    }
    
    private func toPreview(with item: KKMediaItem){
        KKLogFile.instance.log(label:"KKCameraController", message: "toPreview")
        
        let vc = KKCameraPreviewViewController(item: item)
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle  = .crossDissolve
        self.present(vc, animated: true, completion: nil)
        vc.handleDoneTapped = { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true){
                self.handleMediaSelected?(item)
            }
        }
    }
    
    private func setCameraPosition(with position: KKCameraPosition) {
        sessionQueue.async {
            let currentVideoDevice = self.videoDeviceInput.device
            let currentPosition = currentVideoDevice.position
            
            let preferredPosition: AVCaptureDevice.Position
            let preferredDeviceType: AVCaptureDevice.DeviceType
            
            switch position {
            case .front:
                preferredPosition = .front
                preferredDeviceType = .builtInTrueDepthCamera
            case .back:
                preferredPosition = .back
                preferredDeviceType = .builtInWideAngleCamera
            }
            
            guard currentPosition != preferredPosition else { return }
            
            let devices = self.videoDeviceDiscoverySession.devices
            var newVideoDevice: AVCaptureDevice? = nil
            
            // First, seek a device with both the preferred position and device type. Otherwise, seek a device with only the preferred position.
            if let device = devices.first(where: { $0.position == preferredPosition && $0.deviceType == preferredDeviceType }) {
                newVideoDevice = device
            } else if let device = devices.first(where: { $0.position == preferredPosition }) {
                newVideoDevice = device
            }
            
            if let videoDevice = newVideoDevice {
                do {
                    let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                    
                    self.session.beginConfiguration()
                    
                    // Remove the existing device input first, because AVCaptureSession doesn't support
                    // simultaneous use of the rear and front cameras.
                    self.session.removeInput(self.videoDeviceInput)
                    
                    if self.session.canAddInput(videoDeviceInput) {
                        NotificationCenter.default.removeObserver(self, name: .AVCaptureDeviceSubjectAreaDidChange, object: currentVideoDevice)
                        NotificationCenter.default.addObserver(self, selector: #selector(self.subjectAreaDidChange), name: .AVCaptureDeviceSubjectAreaDidChange, object: videoDeviceInput.device)
                        
                        self.session.addInput(videoDeviceInput)
                        self.videoDeviceInput = videoDeviceInput
                    } else {
                        self.session.addInput(self.videoDeviceInput)
                    }
                    if let connection = self.movieFileOutput?.connection(with: .video) {
                        if connection.isVideoStabilizationSupported {
                            connection.preferredVideoStabilizationMode = .auto
                        }
                    }
                    
                    /*
                     Set Live Photo capture and depth data delivery if it's supported. When changing cameras, the
                     `livePhotoCaptureEnabled` and `depthDataDeliveryEnabled` properties of the AVCapturePhotoOutput
                     get set to false when a video device is disconnected from the session. After the new video device is
                     added to the session, re-enable them on the AVCapturePhotoOutput, if supported.
                     */
                    self.photoOutput.isLivePhotoCaptureEnabled = self.photoOutput.isLivePhotoCaptureSupported
                    self.photoOutput.isDepthDataDeliveryEnabled = self.photoOutput.isDepthDataDeliverySupported
                    self.photoOutput.isPortraitEffectsMatteDeliveryEnabled = self.photoOutput.isPortraitEffectsMatteDeliverySupported
                    self.photoOutput.enabledSemanticSegmentationMatteTypes = self.photoOutput.availableSemanticSegmentationMatteTypes
                    self.selectedSemanticSegmentationMatteTypes = self.photoOutput.availableSemanticSegmentationMatteTypes
                    self.photoOutput.maxPhotoQualityPrioritization = .balanced
                    
                    DispatchQueue.main.async {
                        let blurView = UIVisualEffectView(frame: self.mainView.previewView.bounds)
                        blurView.effect = UIBlurEffect(style: .light)
                        blurView.layer.cornerRadius = 20
                        blurView.clipsToBounds = true
                        self.mainView.previewView.addSubview(blurView)
                        
                        UIView.transition(with: self.mainView.previewView, duration: 0.6, options: .transitionFlipFromRight, animations: nil) { (finished) -> Void in
                            blurView.removeFromSuperview()
                        }
                    }
                    
                    self.session.commitConfiguration()
                } catch {
                    print("Error occurred while creating video device input: \(error)")
                }
            }
        }
         
        DispatchQueue.main.async {
            self.mainView.flashView.isHidden = (self.videoDeviceInput.device.position == .back)
        }
    }
}

extension AVCaptureVideoOrientation {
    public init?(deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeRight
        case .landscapeRight: self = .landscapeLeft
        default: return nil
        }
    }
    
    public init?(interfaceOrientation: UIInterfaceOrientation) {
        switch interfaceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeLeft
        case .landscapeRight: self = .landscapeRight
        default: return nil
        }
    }
}
