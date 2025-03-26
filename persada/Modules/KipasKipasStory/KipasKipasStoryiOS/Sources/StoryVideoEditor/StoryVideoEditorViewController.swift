import UIKit
import KipasKipasShared
import KipasKipasCamera
import Photos

public final class StoryVideoEditorViewController: StoryEditorViewController {
    
    private let player = Player()
    
    private var playerView: PlayerView {
        player.playerView
    }
    
    public var videoURL: URL? {
        didSet { player.url = videoURL }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configurePlayerView()
        player.playFromBeginning()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        player.stop()
    }
    
    public override func saveMedia() {
        exportStoryVideo { [weak self] (_, error) in
            if error == nil {
                self?.saveVideoToGallery()
            }
        }
    }
    
    public override func exportMedia(with completion: @escaping (KKMediaItem) -> Void) {
        exportStoryVideo { url, error in
            guard error == nil else { return }
            
            if let url = url,
               let data = try? Data(contentsOf: url) {
                KKMediaHelper.instance.video(url: url, postType: .story) { item, _  in
                    guard let item = item else {
                        completion(.init(
                            data: data,
                            path: url.absoluteString,
                            type: .video,
                            postType: .story,
                            videoThumbnail: KKMediaHelper.instance.videoThumbnail(url.absoluteString)
                        ))
                        return
                    }
                    
                    completion(item)
                }
            }
        }
    }
    
    
    private func exportStoryVideo(completion: @escaping (URL?, Error?) -> Void) {
        guard let videoURL = videoURL else { return }
        
        StoryVideoExporter.exportStoryVideo(
            fromVideoAt: videoURL,
            with: overlayView
        ) { result in
            switch result {
            case let .success(url):
                completion(url, nil)
            case let .failure(error):
                completion(nil, error)
            }
        }
    }
    
    private func saveVideoToGallery() {
        saveStoryVideoToGallery { isSaved, _ in
            if isSaved {
                self.showToast(with: "Berhasil menyimpan ke galeri", verticalSpace: 30)
            } else {
                self.showToast(with: "Gagal menyimpan ke galeri", verticalSpace: 30)
            }
        }
    }
}

// MARK: UI
private extension StoryVideoEditorViewController {
    func configurePlayerView() {
        player.playbackLoops = true
        playerView.playerBackgroundColor = .clear
        playerView.isUserInteractionEnabled = false
        
        mediaView.addSubview(playerView)
        playerView.anchors.edges.pin()
    }
}
