import Foundation
import KipasKipasStory
import KipasKipasShared
import KipasKipasImage

protocol StoriesManagerDelegate: AnyObject {
    func didUpdateLike(on story: StoryItemViewModel)
    func didUpdateViewed(on story: StoryItemViewModel)
    func didDelete(for story: StoryItemViewModel, isEmpty: Bool)
}

final class StoriesManager {
    
    private(set) var sections: [StorySectionViewModel] = []
    
    private var viewedStories: Set<String> = []
    
    private static var _shared: StoriesManager?
    
    private weak var delegate: StoriesManagerDelegate?
    
    static var shared: StoriesManager {
        if let instance = _shared {
            return instance
        } else {
            let instance = StoriesManager()
            _shared = instance
            return instance
        }
    }
    
    static func nullify() {
        _shared = nil
    }
    
    func configure(
        _ stories: [StorySectionViewModel],
        delegate: StoriesManagerDelegate
    ) {
        self.sections = stories
        self.delegate = delegate
        
        preloadVideos(from: sections)
        preloadImages(from: sections)
        appendCurrentViewedStories()
    }
    
    private func preloadVideos(from sections: [StorySectionViewModel]) {
        let videoURLs = sections
            .flatMap { $0.stories }
            .filter { $0.media.type == .video }
            .compactMap { $0.media.mediaURL }
        VideoPreloadManager.shared.preloadByteCount = 1024 * 1024 * 25
        VideoPreloadManager.shared.set(waiting: videoURLs)
    }
    
    private func preloadImages(from sections: [StorySectionViewModel]) {
        let imageURLs = sections
            .flatMap { $0.stories }
            .filter { $0.media.type == .image }
            .compactMap { $0.media.mediaURL }
        let thumbnailURLs = sections
            .flatMap { $0.stories }
            .compactMap { $0.media.thumbnailURL }
        
        imagePrefetcher.startPrefetching(with: imageURLs + thumbnailURLs )
    }
    
    private func appendCurrentViewedStories() {
        let viewedIds = sections
            .flatMap { $0.stories }
            .filter { $0.isViewed }
            .map { $0.id }
        
        for id in viewedIds {
            viewedStories.insert(id)
        }
    }
    
    private func updateSection(_ section: StorySectionViewModel) {
        guard sections.isEmpty == false, delegate != nil else {
            fatalError("Configure the sections & delegate first")
        }
        
        if let index = sections.firstIndex(where: { $0.feedId == section.feedId }) {
            sections[index] = section
        }
    }
    
    // MARK: APIs
    func setLike(
        section: StorySectionViewModel,
        story: StoryItemViewModel
    ) {
        updateSection(section)
        delegate?.didUpdateLike(on: story)
    }
    
    func setViewed(
        section: StorySectionViewModel,
        story: StoryItemViewModel
    ) {
        if viewedStories.contains(where: { $0 == story.id }) == false {
            viewedStories.insert(story.id)
            updateSection(section)
            
            delegate?.didUpdateViewed(on: story)
        }
    }
    
    func delete(
        section: StorySectionViewModel,
        story: StoryItemViewModel
    ) {
        updateSection(section)
        
        if section.stories.isEmpty {
            sections.removeAll(where: { $0.feedId == section.feedId })
            delegate?.didDelete(for: story, isEmpty: true)
        } else {
            delegate?.didDelete(for: story, isEmpty: false)
        }
    }
    
    func section(for section: StorySectionViewModel) -> StorySectionViewModel? {
        if let index = sections.firstIndex(where: { $0.feedId == section.feedId }) {
            return sections[safe: index]
        }
        return nil
    }
}
