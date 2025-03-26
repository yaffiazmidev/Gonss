import UIKit
import AVFoundation
import KipasKipasShared
import KipasKipasCamera

final class StoryVideoExporter {
    
    enum StoryVideoExportError: Error {
        case assetFailure
        case exportSessionError
    }
    
    
    static func getVideoOrientation(asset: AVAsset) -> Bool {
        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            return false
        }
        
        let size = videoTrack.naturalSize
        let transform = videoTrack.preferredTransform
        
        // Determine the video orientation based on natural size and transform
        if size.width > size.height {
            // Landscape video
            if transform.a == 0 && abs(transform.b) == 1 && abs(transform.c) == 1 && transform.d == 0 {
                // 90° or 270° rotation
                return true
            } else {
                // No rotation or 180° rotation
                return false
            }
        } else {
            // Portrait video
            if transform.a == 0 && abs(transform.b) == 1 && abs(transform.c) == 1 && transform.d == 0 {
                // 90° or 270° rotation
                return false
            } else {
                // No rotation or 180° rotation
                return true
            }
        }
    }
    
    static func exportStoryVideo(
        fromVideoAt url: URL,
        with overlay: UIView,
        completion: @escaping (Result<URL?, Error>) -> Void
    ) {
        let asset = AVURLAsset(url: url)
        let composition = AVMutableComposition()
        
        guard let compositionTrack = composition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ), let assetTrack = asset.tracks(withMediaType: .video).first
        else {
            completion(.failure(StoryVideoExportError.assetFailure))
            return
        }
        
        
        do {
            let timeRange = CMTimeRange(start: .zero, duration: asset.duration)
            try compositionTrack.insertTimeRange(timeRange, of: assetTrack, at: .zero)
            
            if let audioAssetTrack = asset.tracks(withMediaType: .audio).first,
               let compositionAudioTrack = composition.addMutableTrack(
                withMediaType: .audio,
                preferredTrackID: kCMPersistentTrackID_Invalid) {
                try compositionAudioTrack.insertTimeRange(
                    timeRange,
                    of: audioAssetTrack,
                    at: .zero)
            }
        } catch {
            completion(.failure(error))
            return
        }
        
        compositionTrack.preferredTransform = assetTrack.preferredTransform
        
        let isPortrait = getVideoOrientation(asset: asset)
        
        let videoSize: CGSize
        let portraitSize: CGSize
        // Temporary
        let isFromCamera = url.absoluteString.contains("kipaskipas-temp-video")
        
        if assetTrack.naturalSize.width < assetTrack.naturalSize.height {
            portraitSize = assetTrack.naturalSize
        } else {
            portraitSize = CGSize(
                width: assetTrack.naturalSize.height,
                height: assetTrack.naturalSize.width
            )
        }
        
        if isPortrait && !isFromCamera {
            videoSize = portraitSize
        } else if isFromCamera {
            videoSize = portraitSize
        } else {
            videoSize = assetTrack.naturalSize
        }
        
        let backgroundLayer = CALayer()
        backgroundLayer.frame = CGRect(origin: .zero, size: portraitSize)
        let videoLayer = CALayer()
        videoLayer.frame = CGRect(origin: .zero, size: videoSize)
        backgroundLayer.addSublayer(videoLayer)
        
        let outputLayer = CALayer()
        outputLayer.frame = CGRect(origin: .zero, size: videoSize)
        outputLayer.addSublayer(backgroundLayer)
        
        let imageOverlay = UIImageView(image: overlay.toImage())
        imageOverlay.backgroundColor = .clear
        imageOverlay.frame = CGRect(origin: .zero, size: portraitSize)
        
        outputLayer.addSublayer(imageOverlay.layer)
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = portraitSize
        videoComposition.frameDuration = CMTime(value: 1, timescale: .init(assetTrack.nominalFrameRate))
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(
            postProcessingAsVideoLayer: backgroundLayer,
            in: outputLayer
        )
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(
            start: .zero,
            duration: composition.duration)
        videoComposition.instructions = [instruction]
        let layerInstruction = videoCompositionInstruction(
            compositionTrack,
            assetTrack: assetTrack,
            outputSize: portraitSize,
            videoSize: videoSize
        )
        instruction.layerInstructions = [layerInstruction]
        
        guard let export = AVAssetExportSession(
            asset: composition,
            presetName: AVAssetExportPresetHighestQuality)
        else {
            completion(.failure(StoryVideoExportError.exportSessionError))
            return
        }
        
        let exportURL = URL.temporaryStoryVideoPath
        
        removeExistingFile(at: exportURL.path)
        
        export.videoComposition = videoComposition
        export.outputFileType = .mp4
        export.outputURL = exportURL
        
        export.exportAsynchronously {
            DispatchQueue.main.async {
                switch export.status {
                case .completed:
                    completion(.success(exportURL))
                    
                default:
                    if let error = export.error {
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    private static func videoCompositionInstruction(
        _ track: AVCompositionTrack,
        assetTrack: AVAssetTrack,
        outputSize: CGSize,
        videoSize: CGSize
    ) -> AVMutableVideoCompositionLayerInstruction {
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let transform = preferredTransform(for: assetTrack)
        let assetInfo = orientation(from: assetTrack)
        
        if assetInfo.isPortrait {
            
            instruction.setTransform(transform, at: .zero)
            
        } else {
            if videoSize.width > videoSize.height {
                let scaleX = outputSize.width / videoSize.width
                let scaleY = outputSize.height / videoSize.height
                let scale = min(scaleX, scaleY)
                
                let scaledVideoSize = CGSize(width: videoSize.width * scale, height: videoSize.height * scale)
                let translationX = (outputSize.width - scaledVideoSize.width) / 2
                let translationY = (outputSize.height - scaledVideoSize.height) / 2
                
                let concat = transform
                    .scaledBy(x: scale, y: scale)
                    .translatedBy(x: translationX / scale, y: translationY / scale)
                instruction.setTransform(concat, at: .zero)
                
            } else {
                
                let concat = transform
                    .scaledBy(x: 1, y: 1)
                
                instruction.setTransform(concat, at: .zero)
            }
        }
        
        return instruction
    }
    
    private static func preferredTransform(for track: AVAssetTrack) -> CGAffineTransform {
        if #available(iOS 15, *) {
            Task {
                do {
                    return try await track.load(.preferredTransform)
                } catch {
                    return track.preferredTransform
                }
            }
        } else {
            return track.preferredTransform
        }
        
        return track.preferredTransform
    }
    
    private static func orientation(from assetTrack: AVAssetTrack) -> (orientation: UIImage.Orientation, isPortrait: Bool) {
        var assetOrientation = UIImage.Orientation.up
        var isPortrait = false
        
        let transform = preferredTransform(for: assetTrack)
        let naturalSize = assetTrack.naturalSize
        
        let tfA = transform.a
        let tfB = transform.b
        let tfC = transform.c
        let tfD = transform.d
        
        if tfA == 0 && tfB == 1.0 && tfC == -1.0 && tfD == 0 {
            assetOrientation = .right
            isPortrait = naturalSize.height > naturalSize.width
        } else if tfA == 0 && tfB == -1.0 && tfC == 1.0 && tfD == 0 {
            assetOrientation = .left
            isPortrait = naturalSize.height > naturalSize.width
        } else if tfA == 1.0 && tfB == 0 && tfC == 0 && tfD == 1.0 {
            assetOrientation = .up
        } else if tfA == -1.0 && tfB == 0 && tfC == 0 && tfD == -1.0 {
            assetOrientation = .down
        }
        return (assetOrientation, isPortrait)
    }
    
    private static func removeExistingFile(at path: String) {
        if FileManager.default.fileExists(atPath: path) {
            try? FileManager.default.removeItem(atPath: path)
        }
    }
}
