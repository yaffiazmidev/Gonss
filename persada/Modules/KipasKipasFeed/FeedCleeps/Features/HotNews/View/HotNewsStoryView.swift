//
//  HotNewsStoryView.swift
//  FeedCleeps
//
//  Created by Rahmat Trinanda Pramudya Amar on 12/06/24.
//

import UIKit
import KipasKipasShared
import KipasKipasStoryiOS

public struct HotNewsStoryViewNotification {
    public static let didShow = Notification.Name("HotNewsStoryViewNotification.didShow")
    public static let didDismiss = Notification.Name("HotNewsStoryViewNotification.didDismiss")
}

protocol HotNewsStoryViewDelegate: AnyObject {
    func didShow()
    func didDismiss()
}

public class HotNewsStoryView: UIView {
    
    let height: Double = 230
    private let listHeight: Double = 108
    
    private var containerHeightConstraint: NSLayoutConstraint!
    private var listViewHeightConstraint: NSLayoutConstraint!
    
    weak var delegate: HotNewsStoryViewDelegate?
    
    private var expanded: Bool {
        get {
            return container.bounds.height > 0
        }
    }
    
    lazy var listView: StoryListView = {
        let view = StoryListView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.myPhoto = KKCache.credentials.readString(key: .userPhotoProfile)
        view.style = .init(
            active: .init(hexString: "1AE2C8"),
            hasView: .init(hexString: "4A4A4A"),
            live: .primary,
            background: .init(hexString: "1F1D2A"),
            text: .white
        )
        
        return view
    }()
    
    private lazy var container: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .init(hexString: "1F1D2A")
        view.addSubview(listView)
        
        listViewHeightConstraint = listView.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            listView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            listView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            listView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            listViewHeightConstraint
        ])
        
        return view
    }()
    
//    private lazy var button: UIView = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.text = "Story"
//        label.numberOfLines = 0
//        label.font = .Roboto(.medium, size: 12)
//        label.textColor = .white
//        label.textAlignment = .center
//        
//        let image = UIImageView()
//        image.translatesAutoresizingMaskIntoConstraints = false
//        image.image = .iconDropdownCollapsed
//        image.contentMode = .scaleAspectFit
//        
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = .black.withAlphaComponent(0.2)
//        view.clipsToBounds = true
//        view.layer.cornerRadius = 12
//        
//        view.addSubviews([label, image])
//        label.anchors.top.equal(view.anchors.top, constant: 5)
//        label.anchors.bottom.equal(view.anchors.bottom, constant: -5)
//        label.anchors.leading.equal(view.anchors.leading, constant: 10)
//        
//        image.anchors.centerY.equal(view.anchors.centerY)
//        image.anchors.leading.equal(label.anchors.trailing, constant: 6)
//        image.anchors.trailing.equal(view.anchors.trailing, constant: -10)
//        
//        return view
//    }()
    
    
    // MARK: Function
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configUI()
    }
}

extension HotNewsStoryView {
    func collapse() {
        guard expanded else { return }
        animate()
    }
    
    func expand() {
        guard !expanded else { return }
        animate()
    }
    
    public func animateContainerView() {
        animate()
    }
}

private extension HotNewsStoryView {
    private func configUI() {
//        addSubviews([button, container])
        addSubviews([container])
        
//        button.anchors.centerX.equal(anchors.centerX)
//        button.anchors.top.equal(safeAreaLayoutGuide.anchors.top, constant: 18)
        
        containerHeightConstraint = container.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.topAnchor.constraint(equalTo: topAnchor),
            containerHeightConstraint
        ])
        
        setupGestures()
    }
    
    private func setupGestures() {
//        button.onTap { [weak self] in
//            guard let self = self else { return }
//            self.animate()
//        }
    }
    
    private func animate() {
        containerHeightConstraint.constant = expanded ? 0 : height
        listViewHeightConstraint.constant = expanded ? 0 : listHeight
        
        UIView.animate(
            withDuration: 0.25,
            delay: 0.0,
            options: [.curveEaseInOut]
        ) { [weak self] in
            guard let self = self else { return }
            self.layoutIfNeeded()
        } completion: { [weak self] (_) in
            guard let self = self else { return }
            
            if self.expanded {
                self.delegate?.didShow()
                NotificationCenter.default.post(name: HotNewsStoryViewNotification.didShow, object: nil, userInfo: ["view": self])
            } else {
                self.delegate?.didDismiss()
                NotificationCenter.default.post(name: HotNewsStoryViewNotification.didDismiss, object: nil, userInfo: ["view": self])
            }
        }
    }
}
