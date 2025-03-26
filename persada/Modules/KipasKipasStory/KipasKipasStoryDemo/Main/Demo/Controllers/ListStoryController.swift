//
//  ListStoryController.swift
//  KipasKipasStoryDemo
//
//  Created by Rahmat Trinanda Pramudya Amar on 09/06/24.
//

import UIKit
import KipasKipasStory
import KipasKipasStoryiOS

class ListStoryController: UIViewController {
    let loader: StoryListInteractorAdapter
    
    private var setError: Bool = true
    private var page: Int = 0
    private var data: StoryData?
    
    var didSelectMyStory: ((StoryFeed, StoryData) -> Void)?
    
    lazy var homeListView: StoryListView = {
        let view = StoryListView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.style = .init(
            active: .init(hexString: "1AE2C8"),
            hasView: .init(hexString: "4A4A4A"),
            live: .primary,
            background: .init(hexString: "1F1D2A"),
            text: .white
        )
        return view
    }()
    
    lazy var homeView: UIView = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Home"
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .init(hexString: "1F1D2A")
        
        view.addSubviews([label, homeListView])
        
        label.anchors.leading.equal(view.anchors.leading)
        label.anchors.trailing.equal(view.anchors.trailing)
        label.anchors.top.equal(view.anchors.top, constant: 16)
        
        homeListView.anchors.leading.equal(view.anchors.leading)
        homeListView.anchors.trailing.equal(view.anchors.trailing)
        homeListView.anchors.top.equal(label.anchors.bottom, constant: 12)
        homeListView.anchors.bottom.equal(view.anchors.bottom)
        homeListView.anchors.height.equal(108)
        
        return view
    }()
    
    lazy var notifListView: StoryListView = {
        let view = StoryListView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.style = .init(
            active: .init(hexString: "1AE2C8"),
            hasView: .init(hexString: "DDDDDD"),
            live: .primary,
            background: .white,
            text: .black
        )
        return view
    }()
    
    lazy var notifView: UIView = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Notification"
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        
        view.addSubviews([label, notifListView])
        
        label.anchors.leading.equal(view.anchors.leading)
        label.anchors.trailing.equal(view.anchors.trailing)
        label.anchors.top.equal(view.anchors.top, constant: 16)
        
        notifListView.anchors.leading.equal(view.anchors.leading)
        notifListView.anchors.trailing.equal(view.anchors.trailing)
        notifListView.anchors.top.equal(label.anchors.bottom, constant: 12)
        notifListView.anchors.bottom.equal(view.anchors.bottom)
        notifListView.anchors.height.equal(108)
        
        return view
    }()
    
    public required init(loader: StoryListInteractorAdapter) {
        self.loader = loader
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .white
        
        view.addSubviews([homeView, notifView])
        
        homeView.anchors.leading.equal(view.anchors.leading)
        homeView.anchors.trailing.equal(view.anchors.trailing)
        homeView.anchors.top.equal(view.safeAreaLayoutGuide.anchors.top)
        
        notifView.anchors.leading.equal(view.anchors.leading)
        notifView.anchors.trailing.equal(view.anchors.trailing)
        notifView.anchors.top.equal(homeView.anchors.bottom, constant: 16)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestData(reset: true)
    }
}

private extension ListStoryController {
    func requestData(reset: Bool) {
        let loadPage: Int = reset ? 0 : page + 1
        loader.load(StoryListRequest(page: loadPage)) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                self.data = data
                self.page = loadPage
                self.homeListView.myStory = data.myFeedStory
                self.notifListView.myStory = data.myFeedStory
                if loadPage == 0 {
                    self.homeListView.stories = data.feedStoryAnotherAccounts?.content ?? []
                    self.notifListView.stories = data.feedStoryAnotherAccounts?.content ?? []
                } else {
                    self.homeListView.stories.append(contentsOf: data.feedStoryAnotherAccounts?.content ?? [])
                    self.notifListView.stories.append(contentsOf: data.feedStoryAnotherAccounts?.content ?? [])
                }
            case .failure(let error): print("error", error.localizedDescription)
            }
        }
    }
}

extension ListStoryController: StoryListViewDelegate {
    func didSelectedMyStory(by item: KipasKipasStory.StoryFeed) {
        print("select my story")
        guard let data = data else { return }
        didSelectMyStory?(item, data)
    }
    
    func didSelectedOtherStory(by item: KipasKipasStory.StoryFeed) {
        print("select story", item.account?.name ?? "another")
    }
    
    func didAddStory() {
        print("add story")
        homeListView.setUploadProgress(to: 0.25)
        notifListView.setUploadProgress(to: 0.25)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.homeListView.setUploadProgress(to: 0.5)
            self.notifListView.setUploadProgress(to: 0.5)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                if self.setError {
                    self.homeListView.setUploadError()
                    self.notifListView.setUploadError()
                    return
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    self.homeListView.setUploadProgress(to: 1)
                    self.notifListView.setUploadProgress(to: 1)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        self.homeListView.setUploadDone()
                        self.notifListView.setUploadDone()
                    }
                }
            }
        }
    }
    
    func didSelectedLive() {
        print("open live")
    }
    
    func didRetryUpload() {
        print("retry upload")
        setError = false
        didAddStory()
    }
    
    func didReachLast() {
        print("reach last")
        requestData(reset: false)
    }
}
