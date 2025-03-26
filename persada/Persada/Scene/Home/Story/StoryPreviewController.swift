//
//  StoryPreviewController.swift
//  RnDPersada
//
//  Created by NOOR on 13/01/21.
//  Copyright © 2021 Muhammad Noor. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import KipasKipasShared

public enum layoutType {
	case cubic
	var animator: LayoutAttributesAnimator {
		switch self {
		case .cubic:return CubeAttributesAnimator(perspective: -1/100, totalAngle: .pi/12)
		}
	}
}

/**Road-Map: Story(CollectionView)->Cell(ScrollView(nImageViews:Snaps))
If Story.Starts -> Snap.Index(Captured|StartsWith.0)
While Snap.done->Next.snap(continues)->done
then Story Completed
*/
final class StoryPreviewController: UIViewController, UIGestureRecognizerDelegate {
	
	//MARK: - iVars
	private var _view: StoryPreviewView {return view as! StoryPreviewView}
	private var viewModel: StoryPreviewModel?
	
	private(set) var stories: [StoriesItem]
	/** This index will tell you which Story, user has picked*/
	private(set) var handPickedStoryIndex: Int //starts with(i)
	/** This index will help you simply iterate the story one by one*/
	private var nStoryIndex: Int = 0 //iteration(i+1)
	private var story_copy: StoriesItem?
	private(set) var layoutType: layoutType
	
	private let dismissGesture: UISwipeGestureRecognizer = {
		let gesture = UISwipeGestureRecognizer()
		gesture.direction = .down
		return gesture
	}()
	
	private(set) var executeOnce = false
    
    private let disposeBag   = DisposeBag()
    let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)
	
    //Loading Animation
    private let hud = CPKProgressHUD.progressHUD(style: .loading(text: nil))
    var actionRefresh : () -> () = {}
    var handleDismiss: (() -> Void)?
    
	//MARK: - Overriden functions
	override func loadView() {
		super.loadView()
		view = StoryPreviewView.init(layoutType: self.layoutType)
		viewModel = StoryPreviewModel.init(self.stories, self.handPickedStoryIndex)
		_view.snapsCollectionView.decelerationRate = .fast
		dismissGesture.addTarget(self, action: #selector(didSwipeDown(_:)))
		_view.snapsCollectionView.addGestureRecognizer(dismissGesture)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		//MARK:: Bugfix - Add Delegate
		self._view.snapsCollectionView.delegate = self
		self._view.snapsCollectionView.dataSource = self
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

        if !executeOnce {
            DispatchQueue.main.async {
                self._view.snapsCollectionView.delegate = self
                self._view.snapsCollectionView.dataSource = self
                let indexPath = IndexPath(item: self.handPickedStoryIndex, section: 0)
                self._view.snapsCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
                self.handPickedStoryIndex = 0
                self.executeOnce = true
            }
        }
	}
	
	//MARK:: Bugfix - Add Did Appear
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	init(layout:layoutType = .cubic, stories: [StoriesItem], handPickedStoryIndex: Int) {
		self.layoutType = layout
        let filter_stories = stories.filter({ return $0.stories?.count ?? 0 > 0 })
        self.stories = filter_stories
        self.handPickedStoryIndex = handPickedStoryIndex - (stories.count - filter_stories.count)
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	override var prefersStatusBarHidden: Bool { return true }

	//MARK: - Selectors
	@objc func didSwipeDown(_ sender: Any) {
        dismiss()
	}
    
    private func dismiss() {
        dismiss(animated: true, completion: handleDismiss)
    }
}

//MARK:- Extension|UICollectionViewDataSource
extension StoryPreviewController:UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let model = viewModel else { return 0 }
		
		return model.numberOfItemsInSection(section)
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCustomCell(with: StoryPreviewCell.self, indexPath: indexPath)
		
		let story = viewModel?.cellForItemAtIndexPath(indexPath)
		cell.story = story
		cell.delegate = self
		nStoryIndex = indexPath.item
		
		return cell
	}
}

//MARK:- Extension|UICollectionViewDelegate
extension StoryPreviewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		
		if executeOnce || handPickedStoryIndex == 0 {
			guard let cell = cell as? StoryPreviewCell else {
				return
			}
			
			//Taking Previous(Visible) cell to store previous story
			let visibleCells = collectionView.visibleCells.sortedArrayByPosition()
			let visibleCell = visibleCells.first as? StoryPreviewCell
			
			if let vCell = visibleCell {
				vCell.story?.isCompletelyVisible = false
				vCell.pauseSnapProgressors(with: (vCell.story?.lastPlayedSnapIndex)!)
				story_copy = vCell.story
			}
			
			//Prepare the setup for first time story launch
			if story_copy == nil {
				cell.willDisplayCellForZerothIndex(with: cell.story?.lastPlayedSnapIndex ?? 0)
				return
			}
			
			//MARK:: Bugfix - Remove Code
			let s = stories[nStoryIndex+handPickedStoryIndex]
			cell.willDisplayCell(with: s.lastPlayedSnapIndex )
			
		} else{
			executeOnce = true
			let indexToScrollTo = IndexPath(row: handPickedStoryIndex, section: 0)
			collectionView.scrollToItem(at: indexToScrollTo, at: .left, animated: false)
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		
		let visibleCells = collectionView.visibleCells.sortedArrayByPosition()
		let visibleCell = visibleCells.first as? StoryPreviewCell
		guard let vCell = visibleCell else { return }
		guard let vCellIndexPath = _view.snapsCollectionView.indexPath(for: vCell) else {
			return
		}
        print("**** startProgressors 1-A")
		vCell.story?.isCompletelyVisible = true
		
		if vCell.story == story_copy {
            print("**** startProgressors 1-B")
			//Bugfix::Add Conditional Index Array
			let n = vCell.story?.lastPlayedSnapIndex ?? 0
			if (vCell.story?.stories?.count ?? 0) < n{
				nStoryIndex = vCellIndexPath.item
			}
			
			//MARK:: Bugfix - Index out of range
			vCell.resumePreviousSnapProgress(with: (vCell.story?.lastPlayedSnapIndex)!)
			if let s = vCell.story?.stories{
                print("**** startProgressors 1-B-1")
				let lastPlayed = vCell.story?.lastPlayedSnapIndex ?? 0
				if s.count > lastPlayed {
                    print("**** startProgressors 1-B-2")
					if (s[lastPlayed]).medias?.first?.kind == .video {
                        print("**** startProgressors 1-B-3")
                        print("**** log 1 ", (s[lastPlayed]).medias?.first?.kind)
						//vCell.resumePlayer(with: lastPlayed)
                        vCell.startProgressors()
					}
				}
			}
		} else {
            print("**** startProgressors 1-C")
			if let cell = cell as? StoryPreviewCell {
				cell.stopPlayer()
			}
            print("**** startProgressors 1")
			vCell.startProgressors()
		}
		
		if vCellIndexPath.item == nStoryIndex {
			vCell.didEndDisplayingCell()
		}
	}
}

//MARK:- Extension|UICollectionViewDelegateFlowLayout
extension StoryPreviewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: view.frame.width, height: view.frame.height - 60)
	}
}

//MARK:- Extension|UIScrollViewDelegate<CollectionView>
extension StoryPreviewController {
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		guard let vCell = _view.snapsCollectionView.visibleCells.first as? StoryPreviewCell else { return }
		vCell.pauseSnapProgressors(with: (vCell.story?.lastPlayedSnapIndex)!)
		vCell.pausePlayer(with: (vCell.story?.lastPlayedSnapIndex)!)
	}
	
	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		
		let sortedVCells = _view.snapsCollectionView.visibleCells.sortedArrayByPosition()
		guard let f_Cell = sortedVCells.first as? StoryPreviewCell, let l_Cell = sortedVCells.last as? StoryPreviewCell else {
			return
		}
		
		let f_IndexPath = _view.snapsCollectionView.indexPath(for: f_Cell)
		let l_IndexPath = _view.snapsCollectionView.indexPath(for: l_Cell)
		let numberOfItems = collectionView(_view.snapsCollectionView, numberOfItemsInSection: 0)-1
		
		if l_IndexPath?.item == 0 {
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2) {
				self.dismiss()
			}
		} else if f_IndexPath?.item == numberOfItems {
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2) {
                self.dismiss()
			}
		}
	}
}

//MARK:- StoryPreview Protocol implementation
extension StoryPreviewController: StoryPreviewProtocol {
    
    func didTapMore(_ idStories: String, _ idFeeds: String) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (_) in
            self.deleteFeed(idStories, idFeeds)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in
            self.resumePlayer()
        }))
        self.present(alert, animated: true) {
            self.pausePlayer()
        }
    }
    
	func didTapProfile() {
		let id: String = stories[nStoryIndex].account?.id ?? ""
		if getIdUser() != id{
			let type: String = "social"
			let controller =  AnotherUserProfileViewController(mainView: AnotherUserProfileView(), dataSource: NewUserProfileModel.DataSource(id: id, type: type))
			controller.bindNavigationBar("", false)
			controller.setProfile(id: id, type: type)
			controller.actionDismiss = {
				self.resumePlayer()
			}
			
			let navigate = UINavigationController(rootViewController: controller)
			present(navigate, animated: true, completion: {
				self.pausePlayer()
			})
		}
	}
    
	func didCompletePreview() {
		let n = handPickedStoryIndex+nStoryIndex+1
		if n < stories.count {
			//Move to next story
			nStoryIndex = n
			story_copy = stories[n+handPickedStoryIndex]
			
			let nIndexPath = IndexPath.init(row: n, section: 0)
			_view.snapsCollectionView.scrollToItem(at: nIndexPath, at: .right, animated: true)
		} else {
            self.dismiss()
		}
	}
	
	func moveToPreviousStory() {
		if nStoryIndex <= stories.count && nStoryIndex >= 0 {
            story_copy = stories[nStoryIndex+handPickedStoryIndex]
			nStoryIndex = nStoryIndex - 1
			let nIndexPath = IndexPath.init(row: nStoryIndex, section: 0)
			_view.snapsCollectionView.scrollToItem(at: nIndexPath, at: .left, animated: true)
		} else {
            self.dismiss()
		}
	}
	
	func didTapCloseButton() {
        self.dismiss()
	}
    
    func didTapProduct(_ product: Product) {
        let controller = ProductDetailFactory.createProductDetailController(dataSource: product)
        controller.hidesBottomBarWhenPushed = true
        controller.isPresent = true
        present(UINavigationController(rootViewController: controller), animated: true, completion: {
            self.pausePlayer()
        })
    }
}

extension StoryPreviewController {
    private func pausePlayer(){
        guard let vCell = self._view.snapsCollectionView.visibleCells.first as? StoryPreviewCell else { return }
        vCell.pauseSnapProgressors(with: (vCell.story?.lastPlayedSnapIndex)!)
        vCell.pausePlayer(with: (vCell.story?.lastPlayedSnapIndex)!)
    }
    private func resumePlayer(){
        guard let vCell = self._view.snapsCollectionView.visibleCells.first as? StoryPreviewCell else { return }
        vCell.resumePreviousSnapProgress(with: (vCell.story?.lastPlayedSnapIndex)!)
        if let s = vCell.story?.stories{
            let lastPlayed = vCell.story?.lastPlayedSnapIndex ?? 0
            if s.count > lastPlayed{
                if (s[lastPlayed]).medias?.first?.kind == .video {
                    vCell.resumePlayer(with: lastPlayed)
                }
            }
        }
    }
    //MARK:- Delete Story API
    private func deleteFeed(_ idStories: String, _ idFeeds: String){
        let usecase = Injection.init().provideFeedUseCase()
        hud.show(in: view)
        usecase.deleteStoryBy(idStories: idStories, idFeeds: idFeeds)
            .subscribeOn(self.concurrentBackground)
            .observeOn(MainScheduler.instance)
            .subscribe { result in
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: {
                        self.actionRefresh()
                        NotificationCenter.default.post(name: notificationStoryData, object: nil)
                        self.handleDismiss?()
                    })
                }
            } onError: { err in
                self.hud.dismiss()
                self.showAlert("Error delete story", err.localizedDescription)
            }.disposed(by: self.disposeBag)
    }
    private func showAlert(_ title: String,_ msg: String){
        UIAlertController.showAlertWithOneButton(title, msg, .alert, "Close", { _ in
            self.dismiss()
        }, self)
    }
}
