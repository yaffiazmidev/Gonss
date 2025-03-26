//
//  StoryPreviewCell.swift
//  RnDPersada
//
//  Created by NOOR on 13/01/21.
//  Copyright © 2021 Muhammad Noor. All rights reserved.
//

import UIKit
import AVKit

protocol StoryPreviewProtocol {
    func didCompletePreview()
    func moveToPreviousStory()
    func didTapCloseButton()
    func didTapProfile()
    func didTapMore(_ idStories: String, _ idFeeds: String)
    func didTapProduct(_ product: Product)
}
enum SnapMovementDirectionState {
    case forward
    case backward
}

//Identifiers
fileprivate let snapViewTagIndicator: Int = 8

final class StoryPreviewCell: UICollectionViewCell, UIScrollViewDelegate {
    
    //MARK: - Delegate
    public var delegate: StoryPreviewProtocol? {
        didSet { storyHeaderView.delegate = self }
    }
    
    //MARK:- Private iVars
    private let scrollview: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var storyHeaderView: StoryPreviewHeaderView = {
        let view = StoryPreviewHeaderView.init(frame: CGRect(x: 0,y: 0,width: frame.width,height: 90))
        return view
    }()
    
    private lazy var viewHeaderBackground: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        //Setup Gradient
        let colorTop    = UIColor.black.withAlphaComponent(0.7).cgColor
        let colorBottom = UIColor.black.withAlphaComponent(0).cgColor
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = CGRect(x: 0, y: 0, width: IGScreen.width, height: 120)
        view.layer.insertSublayer(gradientLayer, at:0)
    
        return view
    }()
    
    //MARK:- More Button
    private let btnMore: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: IGScreen.width - 50, y: IGScreen.height - 80, width: 40, height: 40)
        button.setImage(UIImage(named: String.get(.iconReport))!, for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let cell = Bundle.main.loadNibNamed("RowTagProduct", owner: self, options: nil)?[0] as! RowTagProduct
    
    private lazy var longPress_gesture: UILongPressGestureRecognizer = {
        let lp = UILongPressGestureRecognizer.init(target: self, action: #selector(didLongPress(_:)))
        lp.minimumPressDuration = 0.2
        return lp
    }()
    
    private lazy var tap_gesture: UITapGestureRecognizer = {
        let tg = UITapGestureRecognizer(target: self, action: #selector(didTapSnap(_:)))
        tg.numberOfTapsRequired = 1
        return tg
    }()
    
    private var previousSnapIndex: Int {
        return snapIndex - 1
    }
    
    private var snapViewXPos: CGFloat {
        return (snapIndex == 0) ? 0 : scrollview.subviews[previousSnapIndex].frame.maxX
    }
    
    private var videoSnapIndex: Int = 0
    //private var videoView: StoryPlayerView?
    
    var retryBtn: IGRetryLoaderButton!
    
    //MARK:- Public iVars
    public var direction: SnapMovementDirectionState = .forward
    
    public var snapIndex: Int = 0 {
        didSet {
            scrollview.isUserInteractionEnabled = true
            
            switch direction {
            case .forward:
                if snapIndex < story?.storiesCount ?? 0 {
                    if let snap = story?.stories?[snapIndex] {
                        if snap.medias?.first?.kind != MimeType.video {
                            if let snapView = getSnapview() {
                                startRequest(snapView: snapView, with: snap.medias?.first?.url ?? "", index: snapIndex)
                            } else {
                                let snapView = createSnapView()
                                startRequest(snapView: snapView, with: snap.medias?.first?.url ?? "", index: snapIndex)
                            }
                        }else {
                            if let videoView = getVideoView(with: snapIndex) {
                                print("*** checkVideoHLSURL 1")
                                checkVideoHLSURL(medias: snap.medias?.first, videoView: videoView)
                            }else {
                                let videoView = createVideoView()
                                print("*** checkVideoHLSURL 2")
                                checkVideoHLSURL(medias: snap.medias?.first, videoView: videoView)
                            }
                        }
                    }
                }
            case .backward:
                if snapIndex < story?.storiesCount ?? 0 {
                    if let snap = story?.stories?[snapIndex] {
                        if snap.medias?.first?.kind != MimeType.video {
                            if let snapView = getSnapview() {
                                self.startRequest(snapView: snapView, with: snap.medias?.first?.url ?? "", index: snapIndex)
                            }
                        }else {
                            if let videoView = getVideoView(with: snapIndex) {
                                print("*** checkVideoHLSURL 3")
                                checkVideoHLSURL(medias: snap.medias?.first, videoView: videoView)
                            }
                            else {
                                let videoView = self.createVideoView()
                                print("*** checkVideoHLSURL 4")
                                checkVideoHLSURL(medias: snap.medias?.first, videoView: videoView)
                            }
                        }
                    }
                }
            }
            
            if snapIndex < story?.storiesCount ?? 0 {
                if let snap = story?.stories?[snapIndex] {
                    let snap = snap.createAt ?? 0
                    storyHeaderView.lastUpdatedLabel.text = TimeFormatHelper.getDateFromTimeStamp(snap/1000)
                }
            }
        }
    }
    
    public var story: StoriesItem? {
        didSet {
            storyHeaderView.story = story
            storyHeaderView.snaperImageView.image = nil
            if let picture = story?.account?.photo {
                if picture != ""{
                    
                    let photo = picture
                    
                    storyHeaderView.snaperImageView.setImage(url: photo)
                }
                else{
                    addPlaceholderImageProfile(storyHeaderView.snaperImageView)
                }
            }
            else{
                addPlaceholderImageProfile(storyHeaderView.snaperImageView)
            }
            
            if let count = story?.stories?.count {
                scrollview.contentSize = CGSize(width: IGScreen.width * CGFloat(count), height: IGScreen.height)
            }
            
            btnMore.isHidden = getIdUser() != (story?.account?.id ?? "")
        }
    }
    
    private func checkVideoHLSURL(medias: MediasStory?, videoView: StoryPlayerView) {
        print("***** log 4, checkVideoHLSURL", medias?.url ?? "")
//        guard let isHlsReady = medias?.isHlsReady, isHlsReady == true else  {
            startPlayer(videoView: videoView, with: medias?.url ?? "")
//            return
//        }
//        startPlayer(videoView: videoView, with: medias?.hlsUrl ?? "")
    }
    
    // MARK: - Add Placeholder Image Nil
    private func addPlaceholderImageProfile(_ imgView: UIImageView){
        imgView.backgroundColor = .lightGray
        imgView.image = UIImage(named: AssetEnum.iconProfile.rawValue)?.withTintColor(.white)
        imgView.layer.cornerRadius = imgView.frame.height / 2
        imgView.layer.borderWidth = 0
        imgView.contentMode = .center
    }
    
    //MARK: - Overriden functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        scrollview.frame = CGRect(origin: .zero, size: CGSize(width: IGScreen.width, height: IGScreen.height))
        loadUIElements()
        installLayoutConstraints()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        direction = .forward
        clearScrollViewGarbages()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Private functions
    private func loadUIElements() {
        scrollview.delegate = self
        scrollview.isPagingEnabled = true
        scrollview.backgroundColor = .black
        contentView.addSubview(scrollview)
        contentView.addSubview(viewHeaderBackground)
        contentView.addSubview(storyHeaderView)
        contentView.addSubview(btnMore)
        scrollview.addGestureRecognizer(longPress_gesture)
        scrollview.addGestureRecognizer(tap_gesture)
        btnMore.addTarget(self, action: #selector(didTapMore(_:)), for: .touchUpInside)
        //Product
        cell.setupMargin(12)
        cell.contentView.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.backgroundColor = .white
        cell.contentView.layer.cornerRadius = 12
        cell.contentView.isHidden = true
        contentView.addSubview(cell.contentView)
    }
    
    private func installLayoutConstraints() {
        //Setting constraints for scrollview
        NSLayoutConstraint.activate([
            scrollview.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            scrollview.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            scrollview.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -32),
            scrollview.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 32),
            //View Header Background
            viewHeaderBackground.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            viewHeaderBackground.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -32),
            viewHeaderBackground.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            viewHeaderBackground.heightAnchor.constraint(equalToConstant: 120),
            //Product
            cell.contentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            cell.contentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            cell.contentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24)
        ])
    }
    
    private func createSnapView() -> UIImageView {
        let snapView = UIImageView(frame: CGRect(x: snapViewXPos, y: 0, width: scrollview.frame.width, height: scrollview.frame.height))
        //Bugfix::Setting Content Mode
        snapView.contentMode = .scaleAspectFit
        snapView.tag = snapIndex + snapViewTagIndicator
        scrollview.subviews.filter({$0.tag == snapIndex + snapViewTagIndicator}).first?.removeFromSuperview()
        scrollview.addSubview(snapView)
        return snapView
    }
    
    private func getSnapview() -> UIImageView? {
        if let imageView = scrollview.subviews.filter({$0.tag == snapIndex + snapViewTagIndicator}).first as? UIImageView {
            return imageView
        }
        
        return nil
    }
    
    private func createVideoView() -> StoryPlayerView {
        let videoView = StoryPlayerView.init(frame: CGRect(x: snapViewXPos, y: 0, width: scrollview.frame.width, height: scrollview.frame.height))
        videoView.tag = snapIndex + snapViewTagIndicator
        videoView.playerObserverDelegate = self
        scrollview.subviews.filter({$0.tag == snapIndex + snapViewTagIndicator}).first?.removeFromSuperview()
        scrollview.addSubview(videoView)
        return videoView
    }
    
    private func getVideoView(with index: Int) -> StoryPlayerView? {
        print("**** log 2  getVideoView index:", index)
        if let videoView = scrollview.subviews.filter({$0.tag == index + snapViewTagIndicator}).first as? StoryPlayerView {
            
            print("**** log 3 getVideoView index:", index)
            return videoView
        }
        
        return nil
    }
    
    private func startRequest(snapView: UIImageView, with url: String, index: Int) {
        print("**** startRequest url:", url)
        snapView.setImage(url: url, style: .squared) {[weak self] (result) in
            guard let strongSelf = self else { return }
            if index == strongSelf.snapIndex{
                DispatchQueue.main.async {
                    switch result {
                    case .success(_):
                        print("**** startProgressors 2")
                        strongSelf.startProgressors()
                    case .failure(_):
                        strongSelf.showRetryButton(with: url, for: snapView)
                    }
                }
            }
            else{
                strongSelf.stopPlayer()
            }
        }
    }
    
    private func showRetryButton(with url: String, for snapView: UIImageView) {
        self.retryBtn = IGRetryLoaderButton.init(withURL: url)
        self.retryBtn.center = CGPoint(x: self.bounds.width/2, y: self.bounds.height/2)
        self.retryBtn.delegate = self
        self.isUserInteractionEnabled = true
        
        snapView.addSubview(self.retryBtn)
    }
    
    private func startPlayer(videoView: StoryPlayerView, with url: String) {        
        print("**** log 5", url)
        if scrollview.subviews.count > 0 {
            print("**** log 6 isCompletelyVisible:", story?.isCompletelyVisible)
            if story?.isCompletelyVisible == true {
                self.stopAllPlayer()
                let videoResource = VideoResource(filePath: url)
                videoView.play(with: videoResource)
            } else {
                videoView.activityIndicator.stopAnimating()
            }
        }
    }
    
    @objc private func didLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began || sender.state == .ended {
            let v = getProgressView(with: snapIndex)
            let videoView = scrollview.subviews.filter{v in v.tag == snapIndex + snapViewTagIndicator}.first as? StoryPlayerView
            
            if sender.state == .began {
                if videoView != nil {
                    v?.pause()
                    videoView?.pause()
                }else {
                    v?.pause()
                }
            } else {
                if videoView != nil {
                    v?.resume()
                    videoView?.play()
                }else {
                    v?.resume()
                }
            }
            
        }
    }
    
    @objc private func didTapMore(_ sender: UIButton){
        let idStories = story?.stories?[snapIndex].id ?? ""
        let idFeeds   = story?.id ?? ""
        delegate?.didTapMore(idStories, idFeeds)
    }
    
    @objc private func didTapSnap(_ sender: UITapGestureRecognizer) {
        let touchLocation = sender.location(ofTouch: 0, in: self.scrollview)
        
        if let snapCount = story?.storiesCount {
            var n = snapIndex
            /*!
            * Based on the tap gesture(X) setting the direction to either forward or backward
            */
            
            if (story?.stories?.count ?? 0) < n {
                
                if let snap = story?.stories?[n], snap.medias?.first?.kind == .image, getSnapview()?.image == nil {
                    //Remove retry button if tap forward or backward if it exists
                    if let snapView = getSnapview(), let btn = retryBtn, snapView.subviews.contains(btn) {
                        snapView.removeRetryButton()
                    }
                    fillupLastPlayedSnap(n)
                }else {
                    //Remove retry button if tap forward or backward if it exists
                    if let videoView = getVideoView(with: n), let btn = retryBtn, videoView.subviews.contains(btn) {
                        videoView.removeRetryButton()
                    }
                    if getVideoView(with: n)?.player?.timeControlStatus != .playing {
                        fillupLastPlayedSnap(n)
                    }
                }
            }
            
            if touchLocation.x < scrollview.contentOffset.x + (scrollview.frame.width/2) {
                direction = .backward
                if snapIndex >= 1 && snapIndex <= snapCount {
                    clearLastPlayedSnaps(n)
                    stopSnapProgressors(with: n)
                    n -= 1
                    resetSnapProgressors(with: n)
                    willMoveToPreviousOrNextSnap(n: n)
                } else {
                    delegate?.moveToPreviousStory()
                }
            } else {
                if snapIndex >= 0 && snapIndex <= snapCount {
                    //Stopping the current running progressors
                    stopSnapProgressors(with: n)
                    direction = .forward
                    n += 1
                    willMoveToPreviousOrNextSnap(n: n)
                }
            }
        }
    }
    
    @objc private func didEnterForeground() {
        //startSnapProgress(with: snapIndex)
        //snapIndex = (story != nil) ? (story!.lastPlayedSnapIndex > 0 ? story!.lastPlayedSnapIndex - 1 : 0) : 0
        if let snap = story?.stories?[snapIndex] {
            if snap.medias?.first?.kind == .video {
                //startSnapProgress(with: snapIndex)
                print("*** checkVideoHLSURL 5")
                if let videoView = getVideoView(with: snapIndex) {
                    checkVideoHLSURL(medias: snap.medias?.first, videoView: videoView)
                }
            }else {
                startSnapProgress(with: snapIndex)
            }
        }
    }
    
    @objc private func didEnterBackground() {
        if let snap = story?.stories?[snapIndex] {
            if snap.medias?.first?.kind == .video {
                stopPlayer()
            }
        }
        
        resetSnapProgressors(with: snapIndex)
    }
    
    private func willMoveToPreviousOrNextSnap(n: Int) {
        if let count = story?.storiesCount {
            if n < count {
                //Move to next or previous snap based on index n
                let x = n.toFloat * frame.width
                let offset = CGPoint(x: x,y: 0)
                scrollview.setContentOffset(offset, animated: false)
                story?.lastPlayedSnapIndex = n
                clearLastPlayedSnaps(snapIndex)
                stopSnapProgressors(with: snapIndex)
                stopPlayer()
                snapIndex = n
                showProduct()
            } else {
                pausePlayer(with: snapIndex)
                stopPlayer()
                delegate?.didCompletePreview()
            }
        }
    }
    
    @objc private func didCompleteProgress() {
        let n = snapIndex + 1
        
        if let count = story?.storiesCount {
            if n < count {
                //Move to next snap
                let x = n.toFloat * frame.width
                let offset = CGPoint(x: x,y: 0)
                scrollview.setContentOffset(offset, animated: false)
                story?.lastPlayedSnapIndex = n
                direction = .forward
                snapIndex = n
                showProduct()
            }else {
                pausePlayer(with: snapIndex)
                stopPlayer()
                delegate?.didCompletePreview()
            }
        }
    }
    
    private func getProgressView(with index: Int) -> SnapProgressView? {
        let progressView = storyHeaderView.getProgressView
        
        if progressView.subviews.count > 0 {
            let pv = progressView.subviews.filter { v in v.tag == index+progressViewTag }.first as? SnapProgressView
            guard let currentStory = self.story else {
                fatalError("story not found")
            }
            
            pv?.story = currentStory
            
            return pv
        }
        return nil
    }
    
    private func getProgressIndicatorView(with index: Int) -> UIView? {
        let progressView = storyHeaderView.getProgressView
        
        if progressView.subviews.count>0 {
            return progressView.subviews.filter({v in v.tag == index+progressIndicatorViewTag}).first
        } else {
            return nil
        }
    }
    
    private func fillUpMissingImageViews(_ sIndex: Int) {
        if sIndex != 0 {
            for i in 0..<sIndex {
                snapIndex = i
            }
            let xValue = sIndex.toFloat * scrollview.frame.width
            scrollview.contentOffset = CGPoint(x: xValue, y: 0)
        }
    }
    
    //Before progress view starts we have to fill the progressView
    private func fillupLastPlayedSnap(_ sIndex: Int) {
        if let snap = story?.stories?[sIndex], snap.medias?.first?.kind == .video {
            videoSnapIndex = sIndex
            stopPlayer()
        }
        if let holderView = self.getProgressIndicatorView(with: sIndex),
             let progressView = self.getProgressView(with: sIndex){
            progressView.frame.size.width = holderView.frame.width
        }
    }
    
    private func fillupLastPlayedSnaps(_ sIndex: Int) {
        //Coz, we are ignoring the first.snap
        if sIndex != 0 {
            for i in 0..<sIndex {
                if let holderView = self.getProgressIndicatorView(with: i),
                     let progressView = self.getProgressView(with: i){
                    progressView.frame.size.width = holderView.frame.width
                }
            }
        }
    }
    
    private func clearLastPlayedSnaps(_ sIndex: Int) {
        if let _ = self.getProgressIndicatorView(with: sIndex),
             let progressView = self.getProgressView(with: sIndex) {
            progressView.frame.size.width = 0
        }
    }
    
    private func clearScrollViewGarbages() {
        scrollview.contentOffset = CGPoint(x: 0, y: 0)
        
        if scrollview.subviews.count > 0 {
            var i = 0 + snapViewTagIndicator
            var snapViews = [UIView]()
            
            scrollview.subviews.forEach({ (imageView) in
                if imageView.tag == i {
                    snapViews.append(imageView)
                    i += 1
                }
            })
            
            if snapViews.count > 0 {
                snapViews.forEach({ (view) in
                    view.removeFromSuperview()
                })
            }
        }
    }
    
    private func gearupTheProgressors(type: MimeType, playerView: StoryPlayerView? = nil) {
        if let holderView = getProgressIndicatorView(with: snapIndex),
             let progressView = getProgressView(with: snapIndex) {
            progressView.story_identifier = self.story?.id
            progressView.snapIndex = snapIndex
            
            DispatchQueue.main.async {
                if type == .image {
                    self.stopAllPlayer()
                    progressView.start(with: 5.0, width: holderView.frame.width, completion: {(identifier, snapIndex, isCancelledAbruptly) in
                        if isCancelledAbruptly == false {
                            self.didCompleteProgress()
                        }
                    })
                }else {
                    //Handled in delegate methods for videos
                }
            }
        }
    }
    
    //MARK:- Internal functions
    func startProgressors() {
        DispatchQueue.main.async {
            
            if self.scrollview.subviews.count > 0 {
                let imageView = self.scrollview.subviews.filter{v in v.tag == self.snapIndex + snapViewTagIndicator}.first as? UIImageView
                
                print("*** checkVideoHLSURL 5A")
                if imageView?.image != nil && self.story?.isCompletelyVisible == true {
                    print("*** checkVideoHLSURL 5B")
                    self.gearupTheProgressors(type: .image)
                } else {
                    print("*** checkVideoHLSURL 5C")
                    // Didend displaying will call this startProgressors method. After that only isCompletelyVisible get true.
                    // Then we have to start the video if that snap contains video.
                    if self.story?.isCompletelyVisible == true {
                        let videoView = self.scrollview.subviews.filter{v in v.tag == self.snapIndex + snapViewTagIndicator}.first as? StoryPlayerView
                        
                        let snap = self.story?.stories?[self.snapIndex]
                        
                        print("*** checkVideoHLSURL 6A isCompletelyVisible:", self.story?.isCompletelyVisible)
                        
                        if let videoValid = videoView, self.story?.isCompletelyVisible == true {
                            print("*** checkVideoHLSURL 6B")
                            self.checkVideoHLSURL(medias: snap?.medias?.first, videoView: videoValid)
                        } else {
                            self.stopPlayer()
                        }
                    }
                }
            }
        }
    }
    
    private func showProduct(){
        if let snap = story?.stories?[snapIndex] {
            if let pp = snap.products?.first{
                cell.contentView.isHidden = false
                cell.setupData(pp)
                cell.contentView.isUserInteractionEnabled = true
                let tap = UITapGestureRecognizer(target: self, action: #selector(tapProduct))
                cell.contentView.addGestureRecognizer(tap)
            }
            else{
                cell.contentView.isHidden = true
            }
        }
    }
    
    @objc private func tapProduct(){
        if let snap = story?.stories?[snapIndex] {
            if var pp = snap.products?.first{
                pp.sellerName = story?.account?.username
                self.delegate?.didTapProduct(pp)
            }
        }
    }
    
    //MARK: - Public functions
    public func willDisplayCellForZerothIndex(with sIndex: Int) {
        print("**** log willDisplayCellForZerothIndex index", sIndex)
        story?.isCompletelyVisible = true
        willDisplayCell(with: sIndex)
    }
    
    public func willDisplayCell(with sIndex: Int) {

        //Todo:Make sure to move filling part and creating at one place
        //Clear the progressor subviews before the creating new set of progressors.
        storyHeaderView.clearTheProgressorSubviews()
        storyHeaderView.createSnapProgressors()
        fillUpMissingImageViews(sIndex)
        fillupLastPlayedSnaps(sIndex)
        snapIndex = sIndex
        showProduct()
        //Remove the previous observors
        NotificationCenter.default.removeObserver(self)
        
        // Add the observer to handle application from background to foreground
        NotificationCenter.default.addObserver(self, selector: #selector(self.didEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    public func startSnapProgress(with sIndex: Int) {
        
        if let indicatorView = getProgressIndicatorView(with: sIndex),
             let pv = getProgressView(with: sIndex) {
            pv.start(with: 5.0, width: indicatorView.frame.width, completion: { (identifier, snapIndex, isCancelledAbruptly) in
                if isCancelledAbruptly == false {
                    self.didCompleteProgress()
                }
            })
        }
    }
    
    public func pauseSnapProgressors(with sIndex: Int) {
        story?.isCompletelyVisible = false
        getProgressView(with: sIndex)?.pause()
    }
    
    public func stopSnapProgressors(with sIndex: Int) {
        getProgressView(with: sIndex)?.stop()
    }
    
    public func resetSnapProgressors(with sIndex: Int) {
        self.getProgressView(with: sIndex)?.reset()
    }
    
    public func pausePlayer(with sIndex: Int) {
        getVideoView(with: sIndex)?.pause()
    }
    
    public func stopPlayer() {
        DispatchQueue.main.async {
            let videoView = self.getVideoView(with: self.videoSnapIndex)
            if videoView?.player?.timeControlStatus != .playing {
                self.getVideoView(with: self.videoSnapIndex)?.player?.replaceCurrentItem(with: nil)
            }
            videoView?.stop()
        }
        //getVideoView(with: videoSnapIndex)?.player = nil
    }
    
    func stopAllPlayer() {
        scrollview.subviews.forEach { (v) in
            if let vw = v as? StoryPlayerView{
                vw.stop()
            }
        }
    }
    
    public func resumePlayer(with sIndex: Int) {
        getVideoView(with: sIndex)?.play()
    }
    
    public func didEndDisplayingCell() { }
    
    public func resumePreviousSnapProgress(with sIndex: Int) {
        getProgressView(with: sIndex)?.resume()
    }
    
    //Used the below function for image retry option
    public func retryRequest(view: UIView, with url: String) {
        if let v = view as? UIImageView {
            v.removeRetryButton()
            self.startRequest(snapView: v, with: url, index: snapIndex)
        }else if let v = view as? StoryPlayerView {
            v.removeRetryButton()
            self.startPlayer(videoView: v, with: url)
        }
    }
}

//MARK: - Extension|StoryPreviewHeaderProtocol
extension StoryPreviewCell: StoryPreviewHeaderProtocol {
    func didTapProfile() {
        delegate?.didTapProfile()
    }
    
    func didTapCloseButton() {
        delegate?.didTapCloseButton()
    }
}

//MARK: - Extension|RetryBtnDelegate
extension StoryPreviewCell: RetryBtnDelegate {
    func retryButtonTapped() {
        self.retryRequest(view: retryBtn.superview!, with: retryBtn.contentURL!)
    }
}

//MARK: - Extension|IGPlayerObserverDelegate
extension StoryPreviewCell: IGPlayerObserver {
    
    func didStartPlaying() {
        if let videoView = getVideoView(with: snapIndex), videoView.currentTime <= 0 {
            //let videoView = scrollview.subviews.filter{v in v.tag == snapIndex + snapViewTagIndicator}.first as? StoryPlayerView
            
            if videoView.error == nil && (story?.isCompletelyVisible)! == true {
                if let holderView = getProgressIndicatorView(with: snapIndex),
                     let progressView = getProgressView(with: snapIndex) {
                    progressView.story_identifier = self.story?.id
                    progressView.snapIndex = snapIndex
                    
                    if let duration = videoView.currentItem?.asset.duration {
                        if Float(duration.value) > 0 {
                            progressView.start(with: duration.seconds, width: holderView.frame.width, completion: {(identifier, snapIndex, isCancelledAbruptly) in
                                if isCancelledAbruptly == false {
                                    self.videoSnapIndex = snapIndex
                                    self.stopPlayer()
                                    self.didCompleteProgress()
                                } else {
                                    self.videoSnapIndex = snapIndex
                                    self.stopPlayer()
                                }
                            })
                        }else {
                            debugPrint("Player error: Unable to play the video")
                        }
                    }
                }
            }
        }
    }
    
    func didFailed(withError error: String, for url: URL?) {
        debugPrint("Failed with error: \(error)")
        
        if let videoView = getVideoView(with: snapIndex), let videoURL = url {
            self.retryBtn = IGRetryLoaderButton(withURL: videoURL.absoluteString)
            self.retryBtn.center = CGPoint(x: self.bounds.width/2, y: self.bounds.height/2)
            self.retryBtn.delegate = self
            self.isUserInteractionEnabled = true
            videoView.addSubview(self.retryBtn)
        }
    }
    
    func didCompletePlay() {
        //Video completed
    }
    
    func didTrack(progress: Float) {
        //Delegate already handled. If we just print progress, it will print the player current running time
    }
}

extension StoryPreviewCell: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
