import Foundation
import AVFoundation
import Photos

final class CameraVideoSession: CameraSession {
    
    private let output = AVCaptureMovieFileOutput()
    
    private var audioInput: AVCaptureDeviceInput?
    
    private lazy var temporaryFilePath: URL = URL.temporaryVideoPath
    
    override init(session: AVCaptureSession, options: CameraOptions = CameraOptions()) {
        super.init(session: session, options: options)
        self.options.captureMode = .video
    }
    
    override func createSession(completion: @escaping (CameraSetupResult) -> Void) {
        super.createSession(completion: completion)
        addAudioInput()
        addOutput()
    }
    
    override func toggleCapture() {
        if output.isRecording {
            output.stopRecording()
            
        } else {
        
            let movieFileOutputConnection = output.connection(with: .video)
            let availableVideoCodecTypes = output.availableVideoCodecTypes
            
            if let connection = movieFileOutputConnection, availableVideoCodecTypes.contains(.hevc) {
                output.setOutputSettings([AVVideoCodecKey: AVVideoCodecType.hevc], for: connection)
            }
            
            let path = temporaryFilePath.path
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
                    print("Could not remove file at url: \(temporaryFilePath)")
                }
            }
            
            output.startRecording(to: temporaryFilePath, recordingDelegate: self)
        }
    }
    
    /// Adding audio input because it's a video session
    private func addAudioInput() {
        do {
            let audioDevice = AVCaptureDevice.default(for: .audio)!
            let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
            
            audioInput = audioDeviceInput
            
            if session.canAddInput(audioDeviceInput) {
                session.addInput(audioDeviceInput)
            }
            
        } catch {
            #warning("[BEKA] `addAudioInput()` audio error not handled")
            return
        }
    }
    
    override func switchCamera() {
        // Prevent user from switching camera
        // when recording is running
        guard output.isRecording == false else {
            return
        }
        super.switchCamera()
    }
    
    private func addOutput() {
        if session.canAddOutput(output) {
            session.sessionPreset = .high
            session.addOutput(output)
        }
                
        if let connection = output.connection(with: .video) {
            if connection.isVideoStabilizationSupported {
                connection.preferredVideoStabilizationMode = .auto
            }
        }
    }
    
    private func setMicrophoneEnabled(_ isEnabled: Bool) {
        if let audioConnection = output.connection(with: .audio) {
            audioConnection.isEnabled = isEnabled
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

// MARK: AVCaptureFileOutputRecordingDelegate
extension CameraVideoSession: AVCaptureFileOutputRecordingDelegate {
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
