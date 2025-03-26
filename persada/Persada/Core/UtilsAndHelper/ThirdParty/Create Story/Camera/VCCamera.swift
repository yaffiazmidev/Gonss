////
////  VCCamera.swift
////  AppVideo
////
////  Created by Icon+ Gaenael on 10/02/21.
////
//
//import UIKit
//import AVFoundation
//import Photos
//
//class VCCamera: UIViewController, AVCaptureFileOutputRecordingDelegate {
//	private let vwPreview  = PreviewCameraView()
//	//MARK::Component View Header
//	private let btnClose   = UIButton(type: .system)
//	private let btnFlash   = UIButton(type: .system)
//	private let vwTimer    = UIView()
//	private let lblTimer   = UILabel()
//	//MARK::Component View Footer
//	private let btnChange  = UIButton(type: .system)
//	private let viewShoot  = UIView()
//	private let btnShoot   = UIButton(type: .system)
//	private let imgGallery = UIImageView()
//	private let sgmControl = UISegmentedControl()
//	//MARK::Variable
//	private var setupResult: SessionSetupResult = .success
//	@objc dynamic var videoDeviceInput : AVCaptureDeviceInput!
//	private var keyValueObservations = [NSKeyValueObservation]()
//	private var isFlash : AVCaptureDevice.FlashMode = .auto
//	//MARK::Session
//	var windowOrientation: UIInterfaceOrientation {
//		return view.window?.windowScene?.interfaceOrientation ?? .unknown
//	}
//	private let sessionQueue = DispatchQueue(label: "session queue")
//	private let session = AVCaptureSession()
//	private var isSessionRunning = false
//	private var selectedSemanticSegmentationMatteTypes = [AVSemanticSegmentationMatte.MatteType]()
//	private let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera], mediaType: .video, position: .unspecified)
//	private var backgroundRecordingID: UIBackgroundTaskIdentifier?
//	//MARK::Enum
//	private enum SessionSetupResult {
//		case success
//		case notAuthorized
//		case configurationFailed
//	}
//	// MARK: Capturing Photos
//	private var movieFileOutput: AVCaptureMovieFileOutput?
//	private let photoOutput = AVCapturePhotoOutput()
//	private var inProgressPhotoCaptureDelegates = [Int64: PhotoCaptureProcessor]()
//	private var photoQualityPrioritizationMode: AVCapturePhotoOutput.QualityPrioritization = .balanced
//	private var inProgressLivePhotoCapturesCount = 0
//
//	private var hConsShoot = NSLayoutConstraint()
//	private var wConsShoot = NSLayoutConstraint()
//	private let limitVideo = 30
//	private var videoTimer : Timer = Timer()
//	private var vTimer = -1
//	private var images:[UIImage] = []
//    private var isVideoView = false
//
//    var actionUploadSuccess : (Product? ,UIImage?, Data?) -> () = { _, _, _ in }
//
//    private let hud = CPKProgressHUD.progressHUD(style: .loading(text: nil))
//
//	var product : Product?
//
//	override func viewDidLoad() {
//		super.viewDidLoad()
//		setupView()
//		setupSession()
//		fetchPhotos()
//	}
//
//	override func viewWillAppear(_ animated: Bool) {
//		super.viewWillAppear(animated)
//		sessionQueue.async {
//			switch self.setupResult {
//			case .success:
//				// Only setup observers and start the session if setup succeeded.
//				self.session.startRunning()
//				self.addObservers()
//				self.isSessionRunning = self.session.isRunning
//
//			case .notAuthorized:
//				DispatchQueue.main.async {
//					let changePrivacySetting = "AVCam doesn't have permission to use the camera, please change privacy settings"
//					let message = NSLocalizedString(changePrivacySetting, comment: "Alert message when the user has denied access to the camera")
//					let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
//
//					alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
//																									style: .cancel,
//																									handler: nil))
//
//					alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"),
//																									style: .`default`,
//																									handler: { _ in
//																										UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!,
//																																							options: [:],
//																																							completionHandler: nil)
//																									}))
//
//					self.present(alertController, animated: true, completion: nil)
//				}
//
//			case .configurationFailed:
//				DispatchQueue.main.async {
//					let alertMsg = "Alert message when something goes wrong during capture session configuration"
//					let message = NSLocalizedString("Unable to capture media", comment: alertMsg)
//					let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
//
//					alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
//																									style: .cancel,
//																									handler: nil))
//
//					self.present(alertController, animated: true, completion: nil)
//				}
//			}
//		}
//	}
//
//	override func viewWillDisappear(_ animated: Bool) {
//		sessionQueue.async {
//			if self.setupResult == .success {
//				self.session.stopRunning()
//				self.isSessionRunning = self.session.isRunning
//				self.removeObservers()
//			}
//		}
//		super.viewWillDisappear(animated)
//	}
//
//	override var shouldAutorotate: Bool {
//		// Disable autorotation of the interface when recording is in progress.
//		if let movieFileOutput = movieFileOutput {
//			return !movieFileOutput.isRecording
//		}
//		return true
//	}
//
//	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//		return .all
//	}
//
//	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//		super.viewWillTransition(to: size, with: coordinator)
//		if let videoPreviewLayerConnection = vwPreview.videoPreviewLayer.connection {
//			let deviceOrientation = UIDevice.current.orientation
//			guard let newVideoOrientation = AVCaptureVideoOrientation(deviceOrientation: deviceOrientation),
//						deviceOrientation.isPortrait || deviceOrientation.isLandscape else {
//				return
//			}
//			videoPreviewLayerConnection.videoOrientation = newVideoOrientation
//		}
//	}
//}
//
//extension VCCamera{
//	private func setupSession(){
//		// Set up the video preview view.
//
//		vwPreview.session = session
//		vwPreview.videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
//		/*
//		Check the video authorization status. Video access is required and audio
//		access is optional. If the user denies audio access, AVCam won't
//		record audio during movie recording.
//		*/
//		switch AVCaptureDevice.authorizationStatus(for: .video) {
//		case .authorized:
//			// The user has previously granted access to the camera.
//			break
//
//		case .notDetermined:
//			/*
//			The user has not yet been presented with the option to grant
//			video access. Suspend the session queue to delay session
//			setup until the access request has completed.
//
//			Note that audio access will be implicitly requested when we
//			create an AVCaptureDeviceInput for audio during session setup.
//			*/
//			sessionQueue.suspend()
//			AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
//				if !granted {
//					self.setupResult = .notAuthorized
//				}
//				self.sessionQueue.resume()
//			})
//
//		default:
//			// The user has previously denied access.
//			setupResult = .notAuthorized
//		}
//
//		/*
//		Setup the capture session.
//		In general, it's not safe to mutate an AVCaptureSession or any of its
//		inputs, outputs, or connections from multiple threads at the same time.
//
//		Don't perform these tasks on the main queue because
//		AVCaptureSession.startRunning() is a blocking call, which can
//		take a long time. Dispatch session setup to the sessionQueue, so
//		that the main queue isn't blocked, which keeps the UI responsive.
//		*/
//		sessionQueue.async {
//			self.configureSession()
//		}
//	}
//
//	private func configureSession() {
//		if setupResult != .success {
//			return
//		}
//
//		session.beginConfiguration()
//
//		/*
//		Do not create an AVCaptureMovieFileOutput when setting up the session because
//		Live Photo is not supported when AVCaptureMovieFileOutput is added to the session.
//		*/
//		session.sessionPreset = .photo
//
//		// Add video input.
//		do {
//			var defaultVideoDevice: AVCaptureDevice?
//
//			// Choose the back dual camera, if available, otherwise default to a wide angle camera.
//
//			if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
//				// If a rear dual camera is not available, default to the rear wide angle camera.
//				defaultVideoDevice = backCameraDevice
//			} else if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
//				// If the rear wide angle camera isn't available, default to the front wide angle camera.
//				defaultVideoDevice = frontCameraDevice
//			}
//			guard let videoDevice = defaultVideoDevice else {
//				print("Default video device is unavailable.")
//				setupResult = .configurationFailed
//				session.commitConfiguration()
//				return
//			}
//			let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
//
//			if session.canAddInput(videoDeviceInput) {
//				session.addInput(videoDeviceInput)
//				self.videoDeviceInput = videoDeviceInput
//
//				DispatchQueue.main.async {
//					/*
//					Dispatch video streaming to the main queue because AVCaptureVideoPreviewLayer is the backing layer for PreviewView.
//					You can manipulate UIView only on the main thread.
//					Note: As an exception to the above rule, it's not necessary to serialize video orientation changes
//					on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
//
//					Use the window scene's orientation as the initial video orientation. Subsequent orientation changes are
//					handled by CameraViewController.viewWillTransition(to:with:).
//					*/
//					var initialVideoOrientation: AVCaptureVideoOrientation = .portrait
//					if self.windowOrientation != .unknown {
//						if let videoOrientation = AVCaptureVideoOrientation(interfaceOrientation: self.windowOrientation) {
//							initialVideoOrientation = videoOrientation
//						}
//					}
//
//					self.vwPreview.videoPreviewLayer.connection?.videoOrientation = initialVideoOrientation
//				}
//			} else {
//				print("Couldn't add video device input to the session.")
//				setupResult = .configurationFailed
//				session.commitConfiguration()
//				return
//			}
//		} catch {
//			print("Couldn't create video device input: \(error)")
//			setupResult = .configurationFailed
//			session.commitConfiguration()
//			return
//		}
//
//		// Add an audio input device.
//		do {
//			let audioDevice = AVCaptureDevice.default(for: .audio)
//			let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice!)
//
//			if session.canAddInput(audioDeviceInput) {
//				session.addInput(audioDeviceInput)
//			} else {
//				print("Could not add audio device input to the session")
//			}
//		} catch {
//			print("Could not create audio device input: \(error)")
//		}
//
//		// Add the photo output.
//		if session.canAddOutput(photoOutput) {
//			session.addOutput(photoOutput)
//			photoOutput.isHighResolutionCaptureEnabled = true
//			photoOutput.isPortraitEffectsMatteDeliveryEnabled = photoOutput.isPortraitEffectsMatteDeliverySupported
//			photoOutput.enabledSemanticSegmentationMatteTypes = photoOutput.availableSemanticSegmentationMatteTypes
//			selectedSemanticSegmentationMatteTypes = photoOutput.availableSemanticSegmentationMatteTypes
//			photoOutput.maxPhotoQualityPrioritization = .balanced
//			photoQualityPrioritizationMode = .balanced
//
//		} else {
//			print("Could not add photo output to the session")
//			setupResult = .configurationFailed
//			session.commitConfiguration()
//			return
//		}
//
//		session.commitConfiguration()
//	}
//
//	private func addObservers() {
//		let keyValueObservation = session.observe(\.isRunning, options: .new) { _, change in
//		}
//
//		keyValueObservations.append(keyValueObservation)
//
//		let systemPressureStateObservation = observe(\.videoDeviceInput.device.systemPressureState, options: .new) { _, change in
//			guard let systemPressureState = change.newValue else { return }
//			self.setRecommendedFrameRateRangeForPressureState(systemPressureState: systemPressureState)
//		}
//		keyValueObservations.append(systemPressureStateObservation)
//
//		NotificationCenter.default.addObserver(self,
//																					 selector: #selector(subjectAreaDidChange),
//																					 name: .AVCaptureDeviceSubjectAreaDidChange,
//																					 object: videoDeviceInput.device)
//		NotificationCenter.default.addObserver(self,
//																					 selector: #selector(sessionRuntimeError),
//																					 name: .AVCaptureSessionRuntimeError,
//																					 object: session)
//		NotificationCenter.default.addObserver(self,
//																					 selector: #selector(sessionWasInterrupted),
//																					 name: .AVCaptureSessionWasInterrupted,
//																					 object: session)
//		NotificationCenter.default.addObserver(self,
//																					 selector: #selector(sessionInterruptionEnded),
//																					 name: .AVCaptureSessionInterruptionEnded,
//																					 object: session)
//	}
//
//	private func removeObservers() {
//		NotificationCenter.default.removeObserver(self)
//
//		for keyValueObservation in keyValueObservations {
//			keyValueObservation.invalidate()
//		}
//		keyValueObservations.removeAll()
//	}
//
//	@objc func subjectAreaDidChange(notification: NSNotification) {
//		//        let devicePoint = CGPoint(x: 0.5, y: 0.5)
//		//        focus(with: .continuousAutoFocus, exposureMode: .continuousAutoExposure, at: devicePoint, monitorSubjectAreaChange: false)
//	}
//
//	/// - Tag: HandleRuntimeError
//	@objc func sessionRuntimeError(notification: NSNotification) {
//		guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else { return }
//
//		print("Capture session runtime error: \(error)")
//		// If media services were reset, and the last start succeeded, restart the session.
//		if error.code == .mediaServicesWereReset {
//			sessionQueue.async {
//				if self.isSessionRunning {
//					self.session.startRunning()
//					self.isSessionRunning = self.session.isRunning
//				} else {
//					DispatchQueue.main.async {
//						//                        self.resumeButton.isHidden = false
//					}
//				}
//			}
//		} else {
//			//            resumeButton.isHidden = false
//		}
//	}
//
//	private func setRecommendedFrameRateRangeForPressureState(systemPressureState: AVCaptureDevice.SystemPressureState) {
//		/*
//		The frame rates used here are only for demonstration purposes.
//		Your frame rate throttling may be different depending on your app's camera configuration.
//		*/
//		let pressureLevel = systemPressureState.level
//		if pressureLevel == .serious || pressureLevel == .critical {
//			if self.movieFileOutput == nil || self.movieFileOutput?.isRecording == false {
//				do {
//					try self.videoDeviceInput.device.lockForConfiguration()
//					print("WARNING: Reached elevated system pressure level: \(pressureLevel). Throttling frame rate.")
//					self.videoDeviceInput.device.activeVideoMinFrameDuration = CMTime(value: 1, timescale: 20)
//					self.videoDeviceInput.device.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: 15)
//					self.videoDeviceInput.device.unlockForConfiguration()
//				} catch {
//					print("Could not lock device for configuration: \(error)")
//				}
//			}
//		} else if pressureLevel == .shutdown {
//			print("Session stopped running due to shutdown system pressure level.")
//		}
//	}
//
//	/// - Tag: HandleInterruption
//	@objc
//	func sessionWasInterrupted(notification: NSNotification) {
//		/*
//		In some scenarios you want to enable the user to resume the session.
//		For example, if music playback is initiated from Control Center while
//		using AVCam, then the user can let AVCam resume
//		the session running, which will stop music playback. Note that stopping
//		music playback in Control Center will not automatically resume the session.
//		Also note that it's not always possible to resume, see `resumeInterruptedSession(_:)`.
//		*/
//		if let userInfoValue = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?,
//			 let reasonIntegerValue = userInfoValue.integerValue,
//			 let reason = AVCaptureSession.InterruptionReason(rawValue: reasonIntegerValue) {
//			print("Capture session was interrupted with reason \(reason)")
//
//			var showResumeButton = false
//			if reason == .audioDeviceInUseByAnotherClient || reason == .videoDeviceInUseByAnotherClient {
//				showResumeButton = true
//			} else if reason == .videoDeviceNotAvailableWithMultipleForegroundApps {
//				// Fade-in a label to inform the user that the camera is unavailable.
//				//                cameraUnavailableLabel.alpha = 0
//				//                cameraUnavailableLabel.isHidden = false
//				UIView.animate(withDuration: 0.25) {
//					//                    self.cameraUnavailableLabel.alpha = 1
//				}
//			} else if reason == .videoDeviceNotAvailableDueToSystemPressure {
//				print("Session stopped running due to shutdown system pressure level.")
//			}
//			if showResumeButton {
//				setRecord(true)
//			}
//		}
//	}
//
//	@objc
//	func sessionInterruptionEnded(notification: NSNotification) {
//		print("Capture session interruption ended")
//	}
//
//	func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
//		// Note: Because we use a unique file path for each recording, a new recording won't overwrite a recording mid-save.
//		func cleanup() {
//			let path = outputFileURL.path
//			if FileManager.default.fileExists(atPath: path) {
//				do {
//					try FileManager.default.removeItem(atPath: path)
//				} catch {
//					print("Could not remove file at url: \(outputFileURL)")
//				}
//			}
//
//			if let currentBackgroundRecordingID = backgroundRecordingID {
//				backgroundRecordingID = UIBackgroundTaskIdentifier.invalid
//
//				if currentBackgroundRecordingID != UIBackgroundTaskIdentifier.invalid {
//					UIApplication.shared.endBackgroundTask(currentBackgroundRecordingID)
//				}
//			}
//		}
//
//		var success = true
//
//		if error != nil {
//			success = (((error! as NSError).userInfo[AVErrorRecordingSuccessfullyFinishedKey] as AnyObject).boolValue) ?? false
//			setRecord(true)
//		}
//
//		if success {
//			// Check the authorization status.
//			PHPhotoLibrary.requestAuthorization { status in
//				if status == .authorized {
//					// Save the movie file to the photo library and cleanup.
//					PHPhotoLibrary.shared().performChanges({
//						let options = PHAssetResourceCreationOptions()
//						options.shouldMoveFile = true
//						let creationRequest = PHAssetCreationRequest.forAsset()
//						creationRequest.addResource(with: .video, fileURL: outputFileURL, options: options)
//					}, completionHandler: { success, error in
//						if !success {
//							print("AVCam couldn't save the movie to your photo library: \(String(describing: error))")
//						}
//						else{
//							let fetchOptions = PHFetchOptions()
//							fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
//							let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions).lastObject
//							PHImageManager().requestAVAsset(forVideo: fetchResult!, options: nil, resultHandler: { (avurlAsset, audioMix, dict) in
//								let asset = avurlAsset as! AVURLAsset
//                                self.getVideo(asset)
//							})
//						}
//						cleanup()
//					}
//					)
//				} else {
//					cleanup()
//				}
//			}
//		} else {
//			cleanup()
//		}
//
//		fetchPhotos()
//	}
//
//    func getVideo(_ asset: AVURLAsset){
//
//        /*
//        do {
//            let videoData = try Data(contentsOf: (newObj.url))
//            DispatchQueue.main.async {
//                self.toPreview(videoData, path: newObj.url.absoluteString)
//            }
//        } catch  {
//            print("exception catch at block - while uploading video")
//        }
//        */
//
//        DispatchQueue.main.async {
//            self.hud.show(in: self.view)
//        }
//
//        do {
//            let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".mov")
//            self.compressVideo(inputURL: asset.url , outputURL: compressedURL) { (exportSession) in
//                guard let session = exportSession else {
//                    return
//                }
//                switch session.status {
//                case .unknown:
//                    break
//                case .waiting:
//                    break
//                case .exporting:
//                    break
//                case .completed:
//                    do {
//                    let compressedData = try  Data.init(contentsOf: compressedURL)
//                        DispatchQueue.main.async {
//                            self.toPreview(compressedData, path: compressedURL.absoluteString)
//                        }
//                    }
//                    catch{
//                        return
//                    }
//
//                case .failed:
//                    break
//                case .cancelled:
//                    break
//                @unknown default:
//                    break
//                }
//            }
//        }
//    }
//
//    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
//        let urlAsset = AVURLAsset(url: inputURL, options: nil)
//        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) else {
//            DispatchQueue.main.async {
//                self.hud.dismiss()
//            }
//            handler(nil)
//            return
//        }
//        exportSession.outputURL = outputURL
//        exportSession.outputFileType = AVFileType.mp4
//        exportSession.shouldOptimizeForNetworkUse = true
//        exportSession.exportAsynchronously { () -> Void in
//            DispatchQueue.main.async {
//                self.hud.dismiss()
//            }
//            handler(exportSession)
//        }
//    }
//}
//
//extension VCCamera{
//
//	private func setupView(){
//		self.view.backgroundColor = .black
//		setupPriviewCamera()
//		setupViewHeader()
//		setupViewFooter()
//	}
//
//	private func setupPriviewCamera(){
//		self.view.addSubview(vwPreview)
//		vwPreview.translatesAutoresizingMaskIntoConstraints = false
//		NSLayoutConstraint.activate([
//			vwPreview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//			vwPreview.topAnchor.constraint(equalTo: view.topAnchor),
//			vwPreview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//			vwPreview.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//		])
//	}
//
//	private func setupViewHeader(){
//		vwTimer.backgroundColor = .red
//		vwTimer.layer.cornerRadius = 4
//		vwTimer.translatesAutoresizingMaskIntoConstraints = false
//		vwTimer.alpha = 0
//		lblTimer.translatesAutoresizingMaskIntoConstraints = false
//		lblTimer.font = .systemFont(ofSize: 17, weight: .semibold)
//		lblTimer.textColor = .white
//		self.view.addSubview(vwTimer)
//		vwTimer.addSubview(lblTimer)
//
//		btnFlash.translatesAutoresizingMaskIntoConstraints = false
//		btnFlash.addTarget(self, action: #selector(actionFlash), for: .touchUpInside)
//		setupFlash()
//
//		btnClose.addTarget(self, action: #selector(actionClose), for: .touchUpInside)
//		btnClose.setImage(UIImage(systemName: "xmark"), for: .normal)
//		btnClose.tintColor = .white
//		btnClose.translatesAutoresizingMaskIntoConstraints = false
//
//		self.view.addSubview(btnFlash)
//		self.view.addSubview(btnClose)
//
//		NSLayoutConstraint.activate([
//			vwTimer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//			vwTimer.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
//			lblTimer.leadingAnchor.constraint(equalTo: vwTimer.leadingAnchor, constant: 4),
//			lblTimer.topAnchor.constraint(equalTo: vwTimer.topAnchor, constant: 4),
//			lblTimer.bottomAnchor.constraint(equalTo: vwTimer.bottomAnchor, constant: -4),
//			lblTimer.trailingAnchor.constraint(equalTo: vwTimer.trailingAnchor, constant: -4),
//			btnFlash.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            btnFlash.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
//			btnFlash.widthAnchor.constraint(equalToConstant: 32),
//			btnFlash.heightAnchor.constraint(equalToConstant: 32),
//			btnClose.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
//            btnClose.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
//			btnClose.widthAnchor.constraint(equalToConstant: 32),
//			btnClose.heightAnchor.constraint(equalToConstant: 32)
//		])
//	}
//
//	private func setupViewFooter(){
//		sgmControl.insertSegment(withTitle: "Photo", at: 0, animated: false)
//		sgmControl.insertSegment(withTitle: "Video", at: 1, animated: false)
//		sgmControl.selectedSegmentIndex = 0
//		sgmControl.selectedSegmentTintColor = .systemBlue
//		sgmControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
//		sgmControl.translatesAutoresizingMaskIntoConstraints = false
//		sgmControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
//		self.view.addSubview(sgmControl)
//
//		viewShoot.backgroundColor = .clear
//		viewShoot.layer.cornerRadius = 30
//		viewShoot.layer.borderWidth = 2
//		viewShoot.layer.borderColor = UIColor.white.cgColor
//		viewShoot.addSubview(btnShoot)
//		viewShoot.translatesAutoresizingMaskIntoConstraints = false
//
//		btnChange.setImage(UIImage(named: .get(.iconCameraChange)), for: .normal)
//		btnChange.tintColor = .white
//		btnChange.addTarget(self, action: #selector(changeCamera(_:)), for: .touchUpInside)
//
//		btnShoot.backgroundColor = .white
//		btnShoot.layer.cornerRadius = 25
//		btnShoot.translatesAutoresizingMaskIntoConstraints = false
//		btnShoot.addTarget(self, action: #selector(capturePhoto(_:)), for: .touchUpInside)
//
//		imgGallery.backgroundColor = .gray
//		imgGallery.layer.borderWidth = 1
//		imgGallery.layer.borderColor = UIColor.white.cgColor
//		imgGallery.layer.cornerRadius = 4
//		imgGallery.translatesAutoresizingMaskIntoConstraints = false
//		imgGallery.contentMode = .scaleAspectFill
//		imgGallery.clipsToBounds = true
//		imgGallery.isUserInteractionEnabled = true
//		let tap = UITapGestureRecognizer(target: self, action: #selector(toImagePicker))
//		imgGallery.addGestureRecognizer(tap)
//
//		let hStack = UIStackView(arrangedSubviews: [btnChange, viewShoot, imgGallery])
//		hStack.axis = .horizontal
//		hStack.spacing = 72
//		hStack.alignment = .center
//		view.addSubview(hStack)
//		hStack.translatesAutoresizingMaskIntoConstraints = false
//
//		hConsShoot = btnShoot.heightAnchor.constraint(equalToConstant: 50)
//		wConsShoot = btnShoot.widthAnchor.constraint(equalToConstant: 50)
//		NSLayoutConstraint.activate([
//			hStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//			hStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32),
//			viewShoot.heightAnchor.constraint(equalToConstant: 60),
//			viewShoot.widthAnchor.constraint(equalToConstant: 60),
//			btnShoot.centerXAnchor.constraint(equalTo: viewShoot.centerXAnchor),
//			btnShoot.centerYAnchor.constraint(equalTo: viewShoot.centerYAnchor),
//			hConsShoot,
//			wConsShoot,
//			imgGallery.widthAnchor.constraint(equalToConstant: 40),
//			imgGallery.heightAnchor.constraint(equalToConstant: 40),
//			btnChange.widthAnchor.constraint(equalToConstant: 32),
//			btnChange.heightAnchor.constraint(equalToConstant: 32),
//			sgmControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//			sgmControl.bottomAnchor.constraint(equalTo: hStack.topAnchor, constant: -16)
//		])
//	}
//
//	private func setupFlash(){
//		var image = ""
//		var color = UIColor.white
//
//		switch isFlash {
//		case .on:
//			image = "bolt.fill"
//			color = .yellow
//		case .off:
//			image = "bolt.slash"
//			color = .white
//		default:
//			image = "bolt.badge.a"
//			color = .white
//		}
//
//		btnFlash.setImage(UIImage(systemName: image), for: .normal)
//		btnFlash.tintColor = color
//	}
//
//}
//
//extension VCCamera{
//
//	@IBAction private func changeCamera(_ btn: UIButton) {
//		sessionQueue.async {
//			let currentVideoDevice = self.videoDeviceInput.device
//			let currentPosition = currentVideoDevice.position
//
//			let preferredPosition: AVCaptureDevice.Position
//			let preferredDeviceType: AVCaptureDevice.DeviceType
//
//			switch currentPosition {
//			case .unspecified, .front:
//				preferredPosition = .back
//				preferredDeviceType = .builtInDualCamera
//
//			case .back:
//				preferredPosition = .front
//				preferredDeviceType = .builtInTrueDepthCamera
//
//			@unknown default:
//				print("Unknown capture position. Defaulting to back, dual-camera.")
//				preferredPosition = .back
//				preferredDeviceType = .builtInDualCamera
//			}
//			let devices = self.videoDeviceDiscoverySession.devices
//			var newVideoDevice: AVCaptureDevice? = nil
//
//			// First, seek a device with both the preferred position and device type. Otherwise, seek a device with only the preferred position.
//			if let device = devices.first(where: { $0.position == preferredPosition && $0.deviceType == preferredDeviceType }) {
//				newVideoDevice = device
//			} else if let device = devices.first(where: { $0.position == preferredPosition }) {
//				newVideoDevice = device
//			}
//
//			if let videoDevice = newVideoDevice {
//				do {
//					let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
//
//					self.session.beginConfiguration()
//
//					// Remove the existing device input first, because AVCaptureSession doesn't support
//					// simultaneous use of the rear and front cameras.
//					self.session.removeInput(self.videoDeviceInput)
//
//					if self.session.canAddInput(videoDeviceInput) {
//						NotificationCenter.default.removeObserver(self, name: .AVCaptureDeviceSubjectAreaDidChange, object: currentVideoDevice)
//						NotificationCenter.default.addObserver(self, selector: #selector(self.subjectAreaDidChange), name: .AVCaptureDeviceSubjectAreaDidChange, object: videoDeviceInput.device)
//
//						self.session.addInput(videoDeviceInput)
//						self.videoDeviceInput = videoDeviceInput
//					} else {
//						self.session.addInput(self.videoDeviceInput)
//					}
//					if let connection = self.movieFileOutput?.connection(with: .video) {
//						if connection.isVideoStabilizationSupported {
//							connection.preferredVideoStabilizationMode = .auto
//						}
//					}
//
//					/*
//					Set Live Photo capture and depth data delivery if it's supported. When changing cameras, the
//					`livePhotoCaptureEnabled` and `depthDataDeliveryEnabled` properties of the AVCapturePhotoOutput
//					get set to false when a video device is disconnected from the session. After the new video device is
//					added to the session, re-enable them on the AVCapturePhotoOutput, if supported.
//					*/
//					self.photoOutput.isLivePhotoCaptureEnabled = self.photoOutput.isLivePhotoCaptureSupported
//					self.photoOutput.isDepthDataDeliveryEnabled = self.photoOutput.isDepthDataDeliverySupported
//					self.photoOutput.isPortraitEffectsMatteDeliveryEnabled = self.photoOutput.isPortraitEffectsMatteDeliverySupported
//					self.photoOutput.enabledSemanticSegmentationMatteTypes = self.photoOutput.availableSemanticSegmentationMatteTypes
//					self.selectedSemanticSegmentationMatteTypes = self.photoOutput.availableSemanticSegmentationMatteTypes
//					self.photoOutput.maxPhotoQualityPrioritization = .balanced
//
//					self.session.commitConfiguration()
//				} catch {
//					print("Error occurred while creating video device input: \(error)")
//				}
//			}
//		}
//
//		self.btnFlash.isHidden = (videoDeviceInput.device.position == .back)
//	}
//
//	@IBAction private func capturePhoto(_ photoButton: UIButton) {
//		/*
//		Retrieve the video preview layer's video orientation on the main queue before
//		entering the session queue. Do this to ensure that UI elements are accessed on
//		the main thread and session configuration is done on the session queue.
//		*/
//		let videoPreviewLayerOrientation = vwPreview.videoPreviewLayer.connection?.videoOrientation
//		sessionQueue.async {
//			if let photoOutputConnection = self.photoOutput.connection(with: .video) {
//				photoOutputConnection.videoOrientation = videoPreviewLayerOrientation!
//			}
//			var photoSettings = AVCapturePhotoSettings()
//
//			// Capture HEIF photos when supported. Enable auto-flash and high-resolution photos.
//			if  self.photoOutput.availablePhotoCodecTypes.contains(.hevc) {
//				photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
//			}
//
//			if self.videoDeviceInput.device.isFlashAvailable {
//				photoSettings.flashMode = self.isFlash
//			}
//
//			photoSettings.isHighResolutionPhotoEnabled = true
//			if !photoSettings.__availablePreviewPhotoPixelFormatTypes.isEmpty {
//				photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoSettings.__availablePreviewPhotoPixelFormatTypes.first!]
//			}
//
//			photoSettings.photoQualityPrioritization = self.photoQualityPrioritizationMode
//
//			let photoCaptureProcessor = PhotoCaptureProcessor(with: photoSettings, willCapturePhotoAnimation: {
//				// Flash the screen to signal that AVCam took a photo.
//				DispatchQueue.main.async {
//					self.vwPreview.videoPreviewLayer.opacity = 0
//					UIView.animate(withDuration: 0.25) {
//						self.vwPreview.videoPreviewLayer.opacity = 1
//					}
//				}
//			}, livePhotoCaptureHandler: { capturing in
//			}, completionHandler: { photoCaptureProcessor, dataImage in
//				// When the capture is complete, remove a reference to the photo capture delegate so it can be deallocated.
//				self.sessionQueue.async {
//					self.inProgressPhotoCaptureDelegates[photoCaptureProcessor.requestedPhotoSettings.uniqueID] = nil
//				}
//
//				DispatchQueue.main.async {
//					self.fetchPhotos()
//					self.toPreview(dataImage, path: nil)
//				}
//			}, photoProcessingHandler: { animate in
//				// Animates a spinner while photo is processing
//				//                DispatchQueue.main.async {
//				//                    if animate {
//				//                        self.spinner.hidesWhenStopped = true
//				//                        self.spinner.center = CGPoint(x: self.previewView.frame.size.width / 2.0, y: self.previewView.frame.size.height / 2.0)
//				//                        self.spinner.startAnimating()
//				//                    } else {
//				//                        self.spinner.stopAnimating()
//				//                    }
//				//                }
//			}
//			)
//
//			// The photo output holds a weak reference to the photo capture delegate and stores it in an array to maintain a strong reference.
//			self.inProgressPhotoCaptureDelegates[photoCaptureProcessor.requestedPhotoSettings.uniqueID] = photoCaptureProcessor
//			self.photoOutput.capturePhoto(with: photoSettings, delegate: photoCaptureProcessor)
//		}
//	}
//
//	@IBAction private func captureVideo(_ photoButton: UIButton) {
//		guard let movieFileOutput = self.movieFileOutput else {
//			return
//		}
//
//		let videoPreviewLayerOrientation = vwPreview.videoPreviewLayer.connection?.videoOrientation
//
//		let isRecord = movieFileOutput.isRecording
//		setRecord(isRecord)
//		sessionQueue.async {
//			if !isRecord {
//				if UIDevice.current.isMultitaskingSupported {
//					self.backgroundRecordingID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
//				}
//
//				// Update the orientation on the movie file output video connection before recording.
//				let movieFileOutputConnection = movieFileOutput.connection(with: .video)
//				movieFileOutputConnection?.videoOrientation = videoPreviewLayerOrientation!
//
//				let availableVideoCodecTypes = movieFileOutput.availableVideoCodecTypes
//
//				if availableVideoCodecTypes.contains(.hevc) {
//					movieFileOutput.setOutputSettings([AVVideoCodecKey: AVVideoCodecType.hevc], for: movieFileOutputConnection!)
//				}
//
//				// Start recording video to a temporary file.
//				let outputFileName = NSUUID().uuidString
//				let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((outputFileName as NSString).appendingPathExtension("mp4")!)
//				movieFileOutput.startRecording(to: URL(fileURLWithPath: outputFilePath), recordingDelegate: self)
//			} else {
//				movieFileOutput.stopRecording()
//			}
//		}
//	}
//
//}
//
//extension VCCamera{
//
//	@objc private func actionClose(){
//		self.dismiss(animated: true, completion: nil)
//	}
//
//	@objc private func actionFlash(){
//		switch isFlash {
//		case .off:
//			isFlash = .auto
//		case .auto:
//			isFlash = .on
//		default:
//			isFlash = .off
//		}
//
//		setupFlash()
//	}
//
//	@objc private func segmentedControlValueChanged(segment: UISegmentedControl) {
//		let indexS = segment.selectedSegmentIndex
//		UIView.animate(withDuration: 0.25) {
//			self.btnFlash.alpha = (indexS == 1) ? 0 : 1
//			self.btnShoot.backgroundColor = (indexS == 1) ? .red : .white
////			self.imgGallery.alpha = (indexS == 1) ? 0 : 1
//		}
//		btnShoot.removeTarget(self, action: nil, for: .allTouchEvents)
//		switch indexS {
//		case 0:
//            isVideoView = false
//			setPhoto()
//		default:
//			setVideo()
//            isVideoView = true
//		}
//	}
//
//	private func setPhoto(){
//		btnShoot.addTarget(self, action: #selector(capturePhoto(_:)), for: .touchUpInside)
//		sessionQueue.async {
//			self.session.beginConfiguration()
//			self.session.removeOutput(self.movieFileOutput!)
//			self.session.sessionPreset = .photo
//
//			self.movieFileOutput = nil
//
//			if self.photoOutput.isLivePhotoCaptureSupported {
//				self.photoOutput.isLivePhotoCaptureEnabled = true
//			}
//			if self.photoOutput.isDepthDataDeliverySupported {
//				self.photoOutput.isDepthDataDeliveryEnabled = true
//			}
//
//			if self.photoOutput.isPortraitEffectsMatteDeliverySupported {
//				self.photoOutput.isPortraitEffectsMatteDeliveryEnabled = true
//			}
//
//			if !self.photoOutput.availableSemanticSegmentationMatteTypes.isEmpty {
//				self.photoOutput.enabledSemanticSegmentationMatteTypes = self.photoOutput.availableSemanticSegmentationMatteTypes
//				self.selectedSemanticSegmentationMatteTypes = self.photoOutput.availableSemanticSegmentationMatteTypes
//			}
//
//			self.session.commitConfiguration()
//		}
//	}
//
//	private func setVideo(){
//		btnShoot.addTarget(self, action: #selector(captureVideo(_:)), for: .touchUpInside)
//		sessionQueue.async {
//			let movieFileOutput = AVCaptureMovieFileOutput()
//			movieFileOutput.movieFragmentInterval = CMTime(seconds: Double(self.limitVideo), preferredTimescale: 600)
//			if self.session.canAddOutput(movieFileOutput) {
//				self.session.beginConfiguration()
//				self.session.addOutput(movieFileOutput)
//				self.session.sessionPreset = .high
//				if let connection = movieFileOutput.connection(with: .video) {
//					if connection.isVideoStabilizationSupported {
//						connection.preferredVideoStabilizationMode = .auto
//					}
//				}
//				self.session.commitConfiguration()
//				self.movieFileOutput = movieFileOutput
//			}
//		}
//	}
//
//	private func setRecord(_ isRecord: Bool){
//		self.btnShoot.backgroundColor = !isRecord ? .white : .red
//		wConsShoot.constant = !isRecord ? 32 : 50
//		hConsShoot.constant = !isRecord ? 32 : 50
//
//		UIView.animate(withDuration: 0.25) {
//			self.btnShoot.layer.cornerRadius = !isRecord ? 8 : 25
//			self.vwTimer.alpha = !isRecord ? 1 : 0
//			self.btnClose.alpha = !isRecord ? 0 : 1
//			self.btnChange.alpha = !isRecord ? 0 : 1
//			self.sgmControl.alpha = !isRecord ? 0 : 1
//			self.imgGallery.alpha = !isRecord ? 0 : 1
//			self.viewShoot.layer.borderWidth = !isRecord ? 4 : 2
//			self.btnShoot.layoutIfNeeded()
//		}
//
//		videoTimer.invalidate()
//		if !isRecord{
//			vTimer = -1
//			videoTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
//			videoTimer.fire()
//		}
//	}
//
//	@objc private func updateTimer(){
//		vTimer += 1
//		var str = "0\(vTimer)"
//		if vTimer > 9 {
//			str = "\(vTimer)"
//		}
//		lblTimer.text = "00:\(str)"
//	}
//
//	private func toPreview(_ dataImage: Data?, path: String?){
//		let vc = VCPreviewFotoVideo()
//        vc.actionDismiss = { product, image, data in
//			self.dismiss(animated: true) {
//                self.actionUploadSuccess(product, image, data)
//			}
//		}
//
//		if let p = self.product {
//			vc.product = p
//		}
//
//        if let data = dataImage {
//            vc.image = UIImage(data: data)
//        }
//
//        if let d = path {
//            vc.path = d
//            vc.data = dataImage
//        }
//
//        if let d = dataImage{
//            vc.image = UIImage(data: d)
//        }
//
//		vc.modalPresentationStyle = .fullScreen
//		vc.modalTransitionStyle  = .crossDissolve
//		self.present(vc, animated: true, completion: nil)
//	}
//}
//
//extension AVCaptureVideoOrientation {
//	init?(deviceOrientation: UIDeviceOrientation) {
//		switch deviceOrientation {
//		case .portrait: self = .portrait
//		case .portraitUpsideDown: self = .portraitUpsideDown
//		case .landscapeLeft: self = .landscapeRight
//		case .landscapeRight: self = .landscapeLeft
//		default: return nil
//		}
//	}
//
//	init?(interfaceOrientation: UIInterfaceOrientation) {
//		switch interfaceOrientation {
//		case .portrait: self = .portrait
//		case .portraitUpsideDown: self = .portraitUpsideDown
//		case .landscapeLeft: self = .landscapeLeft
//		case .landscapeRight: self = .landscapeRight
//		default: return nil
//		}
//	}
//}
//
//extension AVCaptureDevice.DiscoverySession {
//	var uniqueDevicePositionsCount: Int {
//
//		var uniqueDevicePositions = [AVCaptureDevice.Position]()
//
//		for device in devices where !uniqueDevicePositions.contains(device.position) {
//			uniqueDevicePositions.append(device.position)
//		}
//
//		return uniqueDevicePositions.count
//	}
//}
//
//extension VCCamera{
//	private func fetchPhotos () {
//		images = []
//		// Sort the images by descending creation date and fetch the first 3
//		let fetchOptions = PHFetchOptions()
//		fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
//		fetchOptions.fetchLimit = 1
//
//		// Fetch the image assets
//		let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
//
//		// If the fetch result isn't empty,
//		// proceed with the image request
//		if fetchResult.count > 0 {
//			let totalImageCountNeeded = 1 // <-- The number of images to fetch
//			fetchPhotoAtIndex(0, totalImageCountNeeded, fetchResult)
//			self.imgGallery.image = self.images.first
//		}
//	}
//
//	private func fetchPhotoAtIndex(_ index:Int, _ totalImageCountNeeded: Int, _ fetchResult: PHFetchResult<PHAsset>) {
//
//		// Note that if the request is not set to synchronous
//		// the requestImageForAsset will return both the image
//		// and thumbnail; by setting synchronous to true it
//		// will return just the thumbnail
//		let requestOptions = PHImageRequestOptions()
//		requestOptions.isSynchronous = true
//
//		// Perform the image request
//		PHImageManager.default().requestImage(for: fetchResult.object(at: index) as PHAsset, targetSize: view.frame.size, contentMode: PHImageContentMode.aspectFill, options: requestOptions, resultHandler: { (image, info) in
//			if let image = image {
//				// Add the returned image to your array
//				self.images += [image]
//			}
//			// If you haven't already reached the first
//			// index of the fetch result and if you haven't
//			// already stored all of the images you need,
//			// perform the fetch request again with an
//			// incremented index
//			if index + 1 < fetchResult.count && self.images.count < totalImageCountNeeded {
//				self.fetchPhotoAtIndex(index + 1, totalImageCountNeeded, fetchResult)
//			} else {
//				// Else you have completed creating your array
//			}
//		})
//	}
//}
//
//extension VCCamera: UIImagePickerControllerDelegate & UINavigationControllerDelegate{
//	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//		dismiss(animated: true, completion: nil)
//	}
//
//	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//		if let image = info[.originalImage] as? UIImage {
//			dismiss(animated: true) {
//				self.toPreview(image.jpegData(compressionQuality: 1), path: nil)
//			}
//		}
//
//        if let url = info[.mediaURL] as? URL {
//            dismiss(animated: true) {
//                let asset = AVURLAsset(url: url)
//                self.getVideo(asset)
//            }
//        }
//	}
//
//	@objc private func toImagePicker(){
//		let pickerController        = UIImagePickerController()
//		pickerController.sourceType = .photoLibrary
//		pickerController.delegate   = self
//        pickerController.mediaTypes = [ !isVideoView ? "public.image" : "public.movie"]
//        pickerController.modalPresentationStyle = .overFullScreen
//		self.present(pickerController, animated: true, completion: nil)
//	}
//}
