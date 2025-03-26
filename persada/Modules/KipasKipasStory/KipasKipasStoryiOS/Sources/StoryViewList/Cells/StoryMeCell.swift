import UIKit
import KipasKipasShared
import KipasKipasStory
import KipasKipasImage

internal class StoryMeCell: BaseStoryCell {
    
    private let bottomContainerView = UIStackView()
    private let stackLeftContent = UIStackView()
    private let photoView = SpanPhotoView(dimension: 30)
    private let totalViewButton = KKBaseButton()
    private let shareButton = KKBaseButton()
    private let chevronView = KKBaseButton()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureBottomContainerView()
    }
    
    override func configure(with story: StoryItemViewModel, index: Int) {
        super.configure(with: story, index: index)
        totalViewButton.setTitle("\(story.totalView) penayangan")
        configureViewersPhoto(story)
    }
    
    private func configureViewersPhoto(_ story: StoryItemViewModel) {
        image(
            for: photoView.firstImageView,
            url: story.firstViewerPhotoURL,
            size: .w_50
        )
        image(
            for: photoView.secondImageView,
            url: story.secondViewerPhotoURL,
            size: .w_50
        )
    }
    
    private func image(
        for view: UIImageView,
        url: URL?,
        size: ImageSize
    ) {
        fetchImage(
            with: .init(url: url, size: size),
            into: view
        ) { [weak view] _, error in
            view?.isHidden = error != nil
        }
    }
    
    @objc private func didTapShareButton() {
        onTapShareButton?()
    }
    
    @objc private func didTapTotalViewersButton() {
        onTapListViewers?()
    }
}

// MARK: UI
private extension StoryMeCell {
    func configureBottomContainerView() {
        bottomContainerView.distribution = .equalCentering
        bottomContainerView.alignment = .center
        bottomContainerView.backgroundColor = .clear
        
        bottomView.addSubview(bottomContainerView)
        bottomContainerView.anchors.top.pin(inset: 26)
        bottomContainerView.anchors.edges.pin(insets: 24, axis: .horizontal)
        bottomContainerView.anchors.height.equal(32)
        
        configureStackLeftContent()
        configureShareButton()
    }
    
    func configureStackLeftContent() {
        stackLeftContent.spacing = 4
        stackLeftContent.alignment = .center
        bottomContainerView.addArrangedSubview(stackLeftContent)
        
        configurePhotoView()
        configureTotalViewButton()
    }
    
    func configurePhotoView() {
        stackLeftContent.addArrangedSubview(photoView)
    }
    
    func configureTotalViewButton() {
        totalViewButton.setTitleColor(.water, for: .normal)
        totalViewButton.font = .roboto(.medium, size: 14)
        totalViewButton.addTarget(self, action: #selector(didTapTotalViewersButton), for: .touchUpInside)
        
        chevronView.setImage(UIImage.Story.iconChevronDownSmall)
        chevronView.tintColor = .white
        chevronView.imageEdgeInsets.top = 2
        
        stackLeftContent.addArrangedSubview(totalViewButton)
        stackLeftContent.addArrangedSubview(chevronView)
    }
    
    func configureShareButton() {
        shareButton.setImage(UIImage.Story.iconShare)
        shareButton.backgroundColor = .clear
        shareButton.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
        
        bottomContainerView.addArrangedSubview(shareButton)
    }
}
