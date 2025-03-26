//
//  ViewController.swift
//  KKPlayerApp
//
//  Created by Rahmat Trinanda Pramudya Amar on 19/06/23.
//

import UIKit
import FeedCleeps

class ViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    private var tryCountToAutoPlay: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.registerXibCell(PlayerCollectionViewCell.self)
        //createButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.validateView()
        self.playVisibleCell()
        self.addPreload()
        
    }
    
    func createButtons(){
        
        let buttonPause = UIButton(frame: CGRect(x: 20,
                                            y: 700,
                                            width: 100,
                                            height: 40))
        buttonPause.setTitle("Pause", for: .normal)
        buttonPause.setTitleColor(UIColor.white, for: .normal)
        buttonPause.backgroundColor = UIColor.systemBlue
        buttonPause.addTarget(self, action: #selector(buttonActionPause), for: .touchUpInside)

        let buttonResume = UIButton(frame: CGRect(x: 220,
                                            y: 700,
                                            width: 100,
                                            height: 40))
        buttonResume.setTitle("Resume", for: .normal)
        buttonResume.setTitleColor(UIColor.white, for: .normal)
        buttonResume.backgroundColor = UIColor.systemGray
        buttonResume.addTarget(self, action: #selector(buttonActionResume), for: .touchUpInside)

        
        self.view.addSubview(buttonPause)
        self.view.addSubview(buttonResume)

    }

    @objc
    func buttonActionPause() {
        print("Button Pause pressed")
        KKTencentVideoPlayerPreload.instance.pauseAll()
    }

    @objc
    func buttonActionResume() {
        print("Button Resume pressed")
        KKTencentVideoPlayerPreload.instance.resumeAll()
    }

}

fileprivate extension ViewController {
    private func validateView(){
        var visibleRect = CGRect()
        visibleRect.origin = self.collectionView.contentOffset
        visibleRect.size = self.collectionView.bounds.size
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let indexPath = self.collectionView.indexPathForItem(at: visiblePoint) else { return }
        
        if visibleRect.origin.y.truncatingRemainder(dividingBy: visibleRect.size.height) != 0 {
            self.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
        }
    }
    
    private func addPreload() {
        guard AppConfig.shared.usePreload else { return }
        
        if let index = self.collectionView.indexPathsForVisibleItems.first?.item {
//            let startIndex = index
//            let endIndex = index + 3
//
//            var data: [String] = []
//            for i in startIndex...endIndex where AppConfig.shared.data.count > i {
//                data.append(AppConfig.shared.data[i])
//            }
            
            if let _ = AppConfig.shared.player as? TencentVideoPlayer {
                //let preloadedRange: Range = 2..<AppConfig.shared.data.count
                let preloadedRange: Range = 1..<3
                
                for index in preloadedRange {
                    KKTencentVideoPlayerPreload.instance.addQueue(video: AppConfig.shared.data[index], queueId: "IDTEST")
                }
                //TencentVideoPlayerPreload.instance.addQueue(videos: AppConfig.shared.data[preloadedRange])
            }
        }
    }
    
    
}

extension ViewController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var visibleRect = CGRect()
        visibleRect.origin = collectionView.contentOffset
        visibleRect.size = collectionView.bounds.size
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let indexPath = collectionView.indexPathForItem(at: visiblePoint) else { return }
        
        
        AppConfig.shared.player.pause()
        
        self.validateView()
        if AppConfig.shared.usePreload {
            if let _ = AppConfig.shared.player as? TencentVideoPlayer {
                //KKTencentVideoPlayerPreload.instance.currentIndex = indexPath.item
            }
        }
        print("didEndDecelerating", indexPath.item)
        if let cell = collectionView.cellForItem(at: indexPath) as? PlayerCollectionViewCell {
            DispatchQueue.main.async {
                cell.configure(AppConfig.shared.data[indexPath.item])
                self.playVisibleCell(preferIndex: indexPath)
            }
        }else {
            DispatchQueue.main.async {
                AppConfig.shared.player.pause()
            }
        }
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return UIScreen.main.bounds.size
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat { 0 }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return AppConfig.shared.data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(PlayerCollectionViewCell.self, for: indexPath)
        let index = indexPath.item
        let url = AppConfig.shared.data[indexPath.item]
        print("configure cell for index", index, "with video", url.split(separator: "/").last)
        cell.configure(url)
        DispatchQueue.main.async {
            self.playVisibleCell(preferIndex: indexPath)
        }
        return cell
    }
}

fileprivate extension ViewController {
    
    private func playVisibleCell(preferIndex: IndexPath? = nil){
        let isVisible = collectionView.window != nil
        guard isVisible else {
            AppConfig.shared.player.pause()
            return
        }
        
        if let cell = collectionView.visibleCells.first as? PlayerCollectionViewCell {
            var index: IndexPath? = nil
            if preferIndex != nil {
                for indexPath in collectionView.indexPathsForVisibleItems {
                    if indexPath == preferIndex {
                        index = indexPath
                        break
                    }
                }
            }
            
            var preferCell: PlayerCollectionViewCell = cell
            if let index = index {
                preferCell = (collectionView.cellForItem(at: index) as? PlayerCollectionViewCell) ?? cell
            }
            
            if preferCell != cell {
                print("10216 - harusnya gak ke play dan index selanjutnya bocor")
            }
            
            tryCountToAutoPlay = 0
            
            let videoUrl = preferCell.videoUrl
            
            KKTencentVideoPlayerPreload.instance.cancelPreload(video: videoUrl, queueId: "XXXX", reason: "playing")
            
            
            KKTencentVideoPlayerPreload.instance.checkQueue()
            
            DispatchQueue.main.async {
                preferCell.prepareKKPlayer()
                AppConfig.shared.player.play()
            }
            
        } else {
            if tryCountToAutoPlay < 10 {
                tryCountToAutoPlay += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                    self.playVisibleCell(preferIndex: preferIndex)
                }
            }
        }
    }
}
