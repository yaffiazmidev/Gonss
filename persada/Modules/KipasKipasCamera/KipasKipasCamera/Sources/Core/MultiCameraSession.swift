import AVFoundation

final class MultiCameraSession: CameraSession {
    
    
    // MARK: Photo
    private let photoOutput = AVCapturePhotoOutput()
    private var imagePath: URL {
        return .temporaryImagePath
    }
    private var photoData: Data?
    
    // MARK: Video
    private let videoOutput = AVCaptureMovieFileOutput()
    private var audioInput: AVCaptureDeviceInput?
    private var videoPath: URL {
        return .temporaryVideoPath
    }
    
    private var currentOutput: AVCaptureOutput {
        switch options.captureMode {
        case .video:
            return videoOutput
        case .photo:
            return photoOutput
        }
    }
    
    override var options: CameraOptions {
        didSet {
            setFlashMode()
        }
    }
    
    override func createSession(completion: @escaping (CameraSetupResult) -> Void) {
        super.createSession(completion: completion)
        addOutput()
        addAudioInput()
    }
    
    private func addOutput() {
        // Photo
        session.sessionPreset = .high
        
        if session.canAddOutput(photoOutput) {
            photoOutput.maxPhotoQualityPrioritization = .quality
            #warning("[BEKA] Change this property with maxPhotoDimension")
            photoOutput.isHighResolutionCaptureEnabled = true
            session.addOutput(photoOutput)
        }
        
        // Video
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }
        
        if let connection = videoOutput.connection(with: .video) {
            if connection.isVideoStabilizationSupported {
                connection.preferredVideoStabilizationMode = .auto
            }
            if connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait // or .landscapeRight, .landscapeLeft, etc.
            }
        }
    }
    
    private func addAudioInput() {
        let audioDevice = AVCaptureDevice.default(for: .audio)!
        do {
            audioInput = try AVCaptureDeviceInput(device: audioDevice)
            
            if let input = audioInput, session.canAddInput(input) {
                session.addInput(input)
            }
        } catch {
            return
        }
    }
    
    private func capturePhoto() {
        guard let currentInput = currentVideoInput else { return }
        
        var photoSettings = AVCapturePhotoSettings()
        
        setMirrorEnabled()

        if photoOutput.availablePhotoCodecTypes.contains(.jpeg) {
            photoSettings = AVCapturePhotoSettings(
                format: [
                    AVVideoCodecKey: AVVideoCodecType.jpeg
                ])
        }
        
        if currentInput.device.isFlashAvailable {
            photoSettings.flashMode = options.flashMode
        }
        
        //photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.isHighResolutionPhotoEnabled = false
        
        if !photoSettings.__availablePreviewPhotoPixelFormatTypes.isEmpty {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoSettings.__availablePreviewPhotoPixelFormatTypes.first!]
        }
        
        photoSettings.photoQualityPrioritization = photoOutput.maxPhotoQualityPrioritization
        
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    private func recordVideo() {
        if videoOutput.isRecording {
            videoOutput.stopRecording()
            
        } else {
            
            setMirrorEnabled()
            
            let movieFileOutputConnection = videoOutput.connection(with: .video)
            let availableVideoCodecTypes = videoOutput.availableVideoCodecTypes
            
            if let connection = movieFileOutputConnection, availableVideoCodecTypes.contains(.hevc) {
                videoOutput.setOutputSettings([AVVideoCodecKey: AVVideoCodecType.hevc], for: connection)
            }
            
            let path = videoPath.path
            /*
             When you call the startRecording(to:recordingDelegate:) method on AVCaptureMovieFileOutput to start recording a movie,
             AVCaptureMovieFileOutput creates a temporary file to store the recorded video data.
             However, AVCaptureMovieFileOutput does not automatically delete this temporary file for you.
             It's the developer responsibilty to handle the management of temporary files generated during recording.
             Here we delete the temporary file.
             */
            if FileManager.default.fileExists(atPath: path) {
                do {
                    try FileManager.default.removeItem(atPath: path)
                } catch {
                    print("Could not remove file at url: \(videoPath)")
                }
            }
            
            videoOutput.startRecording(to: videoPath, recordingDelegate: self)
        }
    }
    
    override func toggleCapture() {
        switch options.captureMode {
        case .video:
            recordVideo()
        case .photo:
            capturePhoto()
        }
    }
    
    override func switchCamera() {
        // Prevent user from switching camera
        // when recording is running
        switch options.captureMode {
        case .video:
            guard videoOutput.isRecording == false else {
                return
            }
            super.switchCamera()
        case .photo:
            super.switchCamera()
        }
    }
    
    private func setMicrophoneEnabled(_ isEnabled: Bool) {
        if let audioConnection = videoOutput.connection(with: .audio) {
            audioConnection.isEnabled = isEnabled
        }
    }
    
    private func setMirrorEnabled() {
        guard let input = currentVideoInput else { return }
        let position = input.device.position
        session.beginConfiguration()
        if let connection = currentOutput.connection(with: .video),
            connection.isVideoMirroringSupported {
            connection.isVideoMirrored = position == .front
        }
        session.commitConfiguration()
    }
    
    private func setFlashMode(){
        guard let input = currentVideoInput , input.device.hasTorch else { return }
   
        var torchMode: AVCaptureDevice.TorchMode {
            switch options.flashMode {
            case .on: .on
            case .auto: .auto
            case .off: .off
            @unknown default: .off
            }
        }
       
        do {
            try input.device.lockForConfiguration()
            input.device.torchMode = torchMode
            input.device.unlockForConfiguration()
            
        } catch {
            print("[BEKA] error configuring torch mode")
        }
    }
    
    override func removeObservers() {
        setMicrophoneEnabled(false)
        
        if let input = audioInput {
            session.beginConfiguration()
            session.removeInput(input)
            session.removeInput(currentVideoInput)
            session.commitConfiguration()
            
            audioInput = nil
        }
        
        super.removeObservers()
    }
}

// MARK: AVCapturePhotoCaptureDelegate
extension MultiCameraSession: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings
    ) {
        delegates.invokeForEachDelegate { [weak self] delegate in
            guard let self = self else { return }
            delegate.cameraSession(self, onStartCapturingWith: .photo)
        }
    }
    
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        guard error == nil else { return }
        
        photoData = photo.fileDataRepresentation()
    }
    
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings,
        error: Error?
    ) {
        guard error == nil else { return }
        
        let path = imagePath.path
        
        if FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.removeItem(atPath: path)
            } catch {
                print("Could not remove file at url: \(path)")
            }
        }
        
        if let photoData = photoData {
            do {
                let url = try photoData.writeToTemporaryImagePath()
                delegates.invokeForEachDelegate { [weak self] delegate in
                    guard let self = self else { return }
                    delegate.cameraSession(self, mode: .photo, onFinishedCapturingWith: url)
                }
            } catch {
                print("[BEKA] error", #function, error)
            }
        }
    }
}

// MARK: AVCaptureFileOutputRecordingDelegate
extension MultiCameraSession: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(
        _ output: AVCaptureFileOutput,
        didStartRecordingTo fileURL: URL,
        from connections: [AVCaptureConnection]
    ) {
        guard output.isRecording else { return }
        delegates.invokeForEachDelegate { [weak self] delegate in
            guard let self = self else { return }
            delegate.cameraSession(self, onStartCapturingWith: .video)
        }
    }
    
    func fileOutput(
        _ output: AVCaptureFileOutput,
        didFinishRecordingTo outputFileURL: URL,
        from connections: [AVCaptureConnection],
        error: Error?
    ) {
        delegates.invokeForEachDelegate { [weak self] delegate in
            guard let self = self else { return }
            delegate.cameraSession(self, mode: .video, onFinishedCapturingWith: outputFileURL)
        }
    }
}
