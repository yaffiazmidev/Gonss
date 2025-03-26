import KipasKipasStory
import KipasKipasShared

protocol StoryViewersManagerDelegate: AnyObject {
    func reload()
}

final class StoryViewersManager: NSObject {
    
    private(set) var viewers: [StoryViewerViewModel] = []
    
    private weak var delegate: StoryViewersManagerDelegate?
    
    private static var _shared: StoryViewersManager?
        
    private lazy var followQueue = {
        return SimpleQueue<StoryViewerViewModel>(maxQueue: 1) { [weak self] viewer in
            if let viewer = viewer {
                self?.update(viewer)
                self?.delegate?.reload()
            }
        }
    }()
    
    static var shared: StoryViewersManager {
        if let instance = _shared {
            return instance
        } else {
            let instance = StoryViewersManager()
            _shared = instance
            return instance
        }
    }
    
    static func nullify() {
        _shared = nil
    }
    
    private override init() {}
    
    private func update(_ viewer: StoryViewerViewModel) {
        guard viewers.isEmpty == false else {
            fatalError("Viewers cannot be empty")
        }
        
        if let index = viewers.firstIndex(where: { $0.accountId == viewer.accountId }) {
            viewers[index] = viewer
        }
    }
    
    // MARK: API
    func configure(
        _ viewers: [StoryViewerViewModel],
        delegate: StoryViewersManagerDelegate
    ) {
        self.viewers = viewers
        self.delegate = delegate
    }
    
    func setFollow(for viewer: inout StoryViewerViewModel) {
        viewer.isFollow = true
        followQueue.enqueue(viewer)
    }
    
    func finalizeFollow(_ isFollow: Bool) {
        followQueue.queues[0].isFollow = isFollow
        followQueue.dequeue()
    }
}
