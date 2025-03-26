//
//  NewSelebCarouselView.swift
//  Persada
//
//  Created by movan on 15/07/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import ModernAVPlayer
import AVFoundation

private let cellId: String = "cellId"

class NewSelebCarouselView: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    let pref = BaseFeedPreference.instance
    var height: CGFloat?
    var isProduct : Bool = false {
        didSet {
            if isProduct {
                buttonSeeProduct.isHidden = false
                seeProductView.backgroundColor = .whiteSnow
                view.bringSubviewToFront(seeProductView)
            } else {
                buttonSeeProduct.isHidden = true
                seeProductView.backgroundColor = .white
            }
        }
    }
    
    var seeProductHandler: (() -> Void)?
    
    internal var aspectConstraint : NSLayoutConstraint? {
        didSet {
            if oldValue != nil {
                collectionView.removeConstraint(oldValue!)
            }
            if aspectConstraint != nil {
                collectionView.addConstraint(aspectConstraint!)
            }
        }
    }
    
    var items: [Medias] = [Medias]() {
        didSet {
            aspectConstraint = nil
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.collectionView.reloadData()
                if let id = self.items.first?.id {
                    if let index = self.pref.getIndex(key: id) {
                        self.collectionView.scrollToItem(at: IndexPath.init(row: index, section: 0), at: .left, animated: false)
                        self.pageController.currentPage = index
                        return
                    }
                }
               
                self.collectionView.scrollToItem(at: IndexPath.init(row: 0, section: 0), at: .left, animated: false)
                self.pageController.currentPage = 0
            }
        }
    }
    
    lazy var pageController: UIPageControl = {
        let page = UIPageControl()
        page.translatesAutoresizingMaskIntoConstraints = false
        page.pageIndicatorTintColor = .gainsboro
        page.currentPageIndicatorTintColor = .secondary
        page.currentPage = 0
        page.transform = CGAffineTransform(scaleX: 1, y: 1)
        page.isUserInteractionEnabled = false
        return page
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.dataSource = self
        view.delegate = self
        view.isPagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        view.register(UINib(nibName: "NewSelebCarouselCell", bundle: nil), forCellWithReuseIdentifier: cellId)
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var seeProductView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var buttonSeeProduct: UIButton = {
        let button = UIButton()
        button.setTitle(.get(.buyNow), for: .normal)
        button.titleLabel?.font = .Roboto(.medium, size: 13)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()
    
    lazy var priceLabel = UILabel(font: .Roboto(.bold, size: 13), textColor: .primary, textAlignment: .left, numberOfLines: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        setAudioOff()
        pauseAll()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setAudioMode()
    }
    
    
    private func setAudioOff() {
        do {
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            try AVAudioSession.sharedInstance().setActive(false)
        } catch (let err){
            print("setAudioMode error:" + err.localizedDescription)
        }
    }
    
    private func setAudioMode() {
        do {
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch (let err){
            print("setAudioMode error:" + err.localizedDescription)
        }
    }
    
    
    func initView(){
        collectionView.removeFromSuperview()
        seeProductView.removeFromSuperview()
        pageController.removeFromSuperview()
        priceLabel.removeFromSuperview()
        
        view.addSubview(collectionView)
        

    

        collectionView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, height: height)
        
        
        
            view.addSubview(seeProductView)
            seeProductView.addSubview(buttonSeeProduct)
            seeProductView.addSubview(pageController)
            seeProductView.addSubview(priceLabel)
        
        seeProductView.anchor(top: collectionView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, height: 32)
            buttonSeeProduct.anchor(top: seeProductView.topAnchor, bottom: seeProductView.bottomAnchor, right: seeProductView.rightAnchor, paddingTop: 9, paddingBottom: 9, paddingRight: 14)
            pageController.anchor(top: seeProductView.topAnchor, left: seeProductView.leftAnchor, bottom: seeProductView.bottomAnchor, right: seeProductView.rightAnchor , height: 8)
            
            buttonSeeProduct.addTarget(self, action: #selector(seeProductAction), for: .touchUpInside)
        
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.anchor(left: seeProductView.leftAnchor, paddingLeft: 14)
        priceLabel.centerYAnchor.constraint(equalTo: seeProductView.centerYAnchor).isActive = true
        
//        if let index = indexToScroll {
//            pageController.currentPage = index
//            self.collectionView.scrollToItem(at:IndexPath(item: index, section: 0), at: .right, animated: false)
//        }
        
        if isProduct {
            buttonSeeProduct.isHidden = false
            seeProductView.backgroundColor = .whiteSnow
            view.bringSubviewToFront(seeProductView)
        } else {
            buttonSeeProduct.isHidden = true
            seeProductView.backgroundColor = .white
        }
    }
    
    @objc
    func seeProductAction(){
        self.seeProductHandler?()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! NewSelebCarouselCell
 
        cell.configure(item: items[indexPath.row])
        
        
        
        print("NEWSELEB cellForItemAt")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width, height: height ?? 0)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = collectionView.frame.size.width
        pageController.currentPage = Int(collectionView.contentOffset.x / pageWidth)
        if let id = items.first?.id {
            pref.saveIndex(key: id, value: pageController.currentPage)
        }
        
        print("NEWSELEB scrollViewDidEndDecelerating")
        
        let completelyVisible = collectionView.visibleCells.filter { cell in
            let cellRect = collectionView.convert(cell.frame, to: collectionView.superview)
            return collectionView.frame.contains(cellRect)
        }
        print("VISIBLE CELL \(completelyVisible)")
            if let cell = completelyVisible.first as? NewSelebCarouselCell {
                cell.play()
            }
    }
    
    func setIsPageView(values: Int) {
        pageController.currentPageIndicatorTintColor = values == 1 ? .white : .secondary
        pageController.layoutIfNeeded()
    }
    

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? NewSelebCarouselCell {
            cell.pause()
        }

        print("NEWSELEB didEndDisplaying \(indexPath.row)")
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? NewSelebCarouselCell {
            cell.pause()
        }
        print("NEWSELEB WILLDISPLAY \(indexPath.row)")
        
    }
    
    func pauseAll(){
        for (index, _) in items.enumerated() {
            guard let cell = collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? NewSelebCarouselCell else { return }
            cell.pause()
            cell.setPlayerNil()
        }
    }
    
    func playFirst(){
            if let cell = self.collectionView.visibleCells.first as? NewSelebCarouselCell {
                cell.play()
            }
    }
    
    
    func checkIsPlaying() -> Bool {
        var isPlay : [Bool] = []
        self.collectionView.visibleCells.forEach({ cell in
            if let cell = cell as? NewSelebCarouselCell {
                isPlay.append(cell.isPlaying())
            }
        })
        return !isPlay.contains(false)
    }
}

class NewSelebCarouselCell: UICollectionViewCell {
    
    var isZooming = false
    var originalImageCenter:CGPoint?
    weak var delegateZoom: CellDelegate?
    
    // the view that will be overlayed, giving a back transparent look
    var overlayView: UIView!
    var windowImageView: UIView?
    var initialCenter: CGPoint?
    var startingRect = CGRect.zero
    
    // a property representing the maximum alpha value of the background
    let maxOverlayAlpha: CGFloat = 0.8
    // a property representing the minimum alpha value of the background
    let minOverlayAlpha: CGFloat = 0.4

    private lazy var player: ModernAVPlayer = {
        let config = PlayerConfigurationEx()
        return ModernAVPlayer(config: config, loggerDomains: [.error, .unavailableCommand])
    }()
    
    @IBOutlet weak var timerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var playerView: AVPlayerView!
    
    @IBOutlet weak var playImageView: UIImageView!
    
    @IBOutlet weak var timerLabel: UILabel!
    private var isImage = false
    
    private var urlDebug = "empty"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        player.delegate = self
        playerView.onTap {
            print("VIEW TAPPED KAH")
            self.handlePause()
        }
        
        addMovementGesturesToView(self)
    }
    
    func handlePause(){
        if self.isPlaying() {
            UIView.animate(withDuration: 0.075, delay: 0, options: .curveEaseIn) {
                if !self.isImage {
                    self.playImageView.isHidden = false
                }
            } completion: { [weak self] _ in
                self?.player.player.pause()
            }
        } else {
            UIView.animate(withDuration: 0.075, delay: 0, options: .curveEaseIn) {
                if !self.isImage {
                    self.playImageView.isHidden = true
                }
            } completion: { [weak self] _ in
                self?.player.player.play()
            }
        }
    }

    
    func play(){
        print("newseleb1 PLAY kah \(urlDebug)")
        self.playImageView.isHidden = true
        self.player.play()
    }
    
    func pause(){
        print("newseleb1 PAUSE kah \(urlDebug)")
        self.player.pause()
    }
    
    func setPlayerNil(){
        guard let videoLayer = playerView.layer as? AVPlayerLayer
        else { return }
        if let playerLayer = videoLayer.player {
            playerLayer.replaceCurrentItem(with: nil)
        } else {
            videoLayer.player = nil
        }
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(item: Medias) {
        print("AKU ADALAH CELL:::: \(self)")

        print("newseleb1 DATANYA \(item)")
        
  
        
        let width = Double(item.metadata?.width ?? "550") ?? 550
        let height =  Double(item.metadata?.height ?? "550") ?? 550
        
        if width > height || width == height  {
            self.imageView.contentMode = .scaleAspectFit
        } else {
            self.imageView.contentMode = .scaleAspectFill
        }
        
        imageView.loadImage(at: item.thumbnail?.large ?? ""
                            , low: item.thumbnail?.medium ?? "", .w1280, .w576)
        
        if item.type == "image" {
            playerView.isHidden = true
            isImage = true
            return
        } else if item.type == "video" {
            playerView.isHidden = false
            playVideo(item: item)
            guard let videoLayer = playerView.layer as? AVPlayerLayer else { return }
            if width > height || width == height {
                videoLayer.videoGravity = .resizeAspect
            } else {
                videoLayer.videoGravity = .resizeAspectFill
            }
            return
        }
    }
    
    func playVideo(item: Medias){
        if let isHlsReady = item.isHlsReady, isHlsReady {
            
            guard let hlsUrl = item.hlsUrl else { return }
            
            urlDebug = hlsUrl
            
            let asset = AVAsset(url: URL(string: hlsUrl)!)
            let avPlayerItem = AVPlayerItem(asset: asset)
            avPlayerItem.preferredForwardBufferDuration = 3
            guard let item = ModernAVPlayerMediaItem(item: avPlayerItem, type: .clip, metadata: nil) else { return }
            player.load(media: item, autostart: false)
            player.loopMode = true
            guard let videoLayer = playerView.layer as? AVPlayerLayer
            else { return }
            if let playerLayer = videoLayer.player {
                playerLayer.replaceCurrentItem(with: player.player.currentItem)
            } else {
                videoLayer.player = player.player
            }
           
            
        } else {
            guard let videoUrl = item.url else { return }
            
            urlDebug = videoUrl
            
            let asset = AVAsset(url: URL(string: videoUrl)!)
            let avPlayerItem = AVPlayerItem(asset: asset)
            avPlayerItem.preferredForwardBufferDuration = 3
            guard let item = ModernAVPlayerMediaItem(item: avPlayerItem, type: .clip, metadata: nil) else { return }
            player.load(media: item, autostart: false)
            player.loopMode = true
            
            guard let videoLayer = playerView.layer as? AVPlayerLayer
            else { return }
            if let playerLayer = videoLayer.player {
                playerLayer.replaceCurrentItem(with: player.player.currentItem)
            } else {
                videoLayer.player = player.player
            }
        }
    }
    
    func isPlaying() -> Bool {
        if player.player.rate > 0.0 {
            return true
        }
        return false
    }

}

extension NewSelebCarouselCell : ModernAVPlayerDelegate {
    func modernAVPlayer(_ player: ModernAVPlayer, didStateChange state: ModernAVPlayer.State) {
        
    }
    
    func modernAVPlayer(_ player: ModernAVPlayer, didCurrentTimeChange currentTime: Double) {
        let floatDuration = Float(CMTimeGetSeconds(player.player.currentItem?.duration ?? .zero))
        
        if(floatDuration > 0){
            let videoDuration = Int(floatDuration)
            let remainingDuration = videoDuration - Int(currentTime)
            let timeInMinutesSecond = getFormattedVideoTime(totalVideoDuration: remainingDuration)
            
            let time = String(format: "%2d:%02d", timeInMinutesSecond.1, timeInMinutesSecond.2)

            timerLabel.text = time
        }
    }
    
    private func getFormattedVideoTime(totalVideoDuration: Int) -> (hour: Int, minute: Int, seconds: Int){
        let seconds = totalVideoDuration % 60
        let minutes = (totalVideoDuration / 60) % 60
        let hours   = totalVideoDuration / 3600
        return (hours,minutes,seconds)
    }
}

extension NewSelebCarouselCell : UIGestureRecognizerDelegate {
    func addMovementGesturesToView(_ view: UIView) {
        view.isUserInteractionEnabled = true
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        pinchGesture.delegate = self
        view.addGestureRecognizer(pinchGesture)
    }
    
    @objc private func handlePinchGesture(_ sender: UIPinchGestureRecognizer) {
        if sender.state == .began {
            let currentScale = self.frame.size.width / self.bounds.size.width
            let newScale = currentScale * sender.scale
            
            if newScale > 1 {
                isZooming = true
                guard let currentWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {return}
                
                print("media view frame = \(self.frame) \(self.bounds)")
                self.delegateZoom?.zooming(started: true)
                
                overlayView = UIView.init(
                    frame: CGRect(
                        x: 0,
                        y: 0,
                        width: (currentWindow.frame.size.width),
                        height: (currentWindow.frame.size.height)
                    )
                )
                
                overlayView.backgroundColor = UIColor.black
                overlayView.alpha = CGFloat(minOverlayAlpha)
                currentWindow.addSubview(overlayView)
                
                initialCenter = sender.location(in: currentWindow)
                print("INITIAL CENTER \(String(describing: initialCenter))")
                
                if !self.isImage {
                    let viewVideo = UIView(frame: self.frame)
                    
                    guard let videoLayer = self.playerView.layer as? AVPlayerLayer else { return }

                    viewVideo.layer.addSublayer(videoLayer)
                    windowImageView = viewVideo
                } else {
                    windowImageView = UIImageView.init(image: self.imageView.image)
                }
                print(self.frame)
                
                windowImageView!.contentMode = .scaleAspectFill
                windowImageView!.clipsToBounds = true
                
                let point = self.convert(
                    UIScreen.main.bounds,
                    to: nil
                )
                
                print("point: \(point)")
                
                startingRect = CGRect(
                    x: point.minX,
                    y: point.minY,
                    width: self.frame.size.width,
                    height: self.frame.size.height
                )
                
                print("startingRect" + "\(startingRect)")
                windowImageView?.frame = startingRect
                currentWindow.addSubview(windowImageView!)
                currentWindow.bringSubviewToFront(overlayView)
                currentWindow.bringSubviewToFront(windowImageView!)
                self.isHidden = true
            }
        } else if sender.state == .changed {
            guard let currentWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
                  let initialCenter = initialCenter,
                  let windowImageWidth = windowImageView?.frame.size.width
            else { return }
            
            let currentScale = windowImageWidth / startingRect.size.width
            let newScale = currentScale * sender.scale
            overlayView.alpha = minOverlayAlpha + (newScale - 1) < maxOverlayAlpha ? minOverlayAlpha + (newScale - 1) : maxOverlayAlpha
            
            let pinchCenter = CGPoint(
                x: sender.location(in: currentWindow).x - (currentWindow.bounds.midX),
                y: sender.location(in: currentWindow).y - (currentWindow.bounds.midY)
            )
            
            let centerXDif = initialCenter.x - sender.location(in: currentWindow).x
            let centerYDif = initialCenter.y - sender.location(in: currentWindow).y
            let zoomScale = (newScale * windowImageWidth >= self.frame.width) ? newScale : currentScale
            print("Datanyaxx centerXDif \(centerXDif) | centerYDif \(centerYDif) | initialCenter \(initialCenter)")

            let transform = currentWindow.transform
                .translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                .scaledBy(x: zoomScale, y: zoomScale)
                .translatedBy(x: -centerXDif, y: -centerYDif)
            print("Datanyaxx pinchCenter \(pinchCenter) | zoomScale \(zoomScale) | transform \(transform)")

            windowImageView?.transform = transform
            
            sender.scale = 1
        } else if sender.state == .ended || sender.state == .failed || sender.state == .cancelled {
            guard let windowImageView = self.windowImageView else { return }
            
            UIView.animate(withDuration: 0.3, animations: {
                windowImageView.transform = CGAffineTransform.identity
                self.transform = CGAffineTransform.identity
                
            }, completion: { [weak self] _ in
                guard let self = self else { return }
                self.isHidden = false
                if !self.isImage {
                    guard let videoLayer = self.playerView.layer as? AVPlayerLayer else { return }
                    self.layer.addSublayer(videoLayer)
                    self.layer.addSublayer(self.timerView.layer)
                    self.layer.addSublayer(self.playImageView.layer)
                    self.timerView.layer.addSublayer(self.timerLabel.layer)
                }
                windowImageView.removeFromSuperview()
                self.overlayView.removeFromSuperview()
                self.delegateZoom?.zooming(started: false)
                self.isZooming = false
            })
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
