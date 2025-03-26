//
//  MessageReactionSelectionView.swift
//  KipasKipasDirectMessageUI
//
//  Created by MissYasiky on 2024/4/25.
//

import Foundation
import UIKit

protocol MessageReactionSelectionViewDelegate: NSObject {
    func reactionSelectionView(_ reactionSelectionView: MessageReactionSelectionView, didSelect emoji: String)
}

class MessageReactionSelectionView: UIView {
    weak public var delegate: MessageReactionSelectionViewDelegate?
    public var width: CGFloat {
        get {
            return 6.0 + self.itemWith * CGFloat(self.dataSource.count) + 6.0//52.0
        }
    }
    public var height: CGFloat = 52.0
    public var selectedEmoji: String?
    private let itemWith: CGFloat = 40.0
    private let dataSource: [String] = ["👍", "❤️", "😂", "😮", "😢", "🙏"]
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0.0 // 设置行间距
        layout.minimumInteritemSpacing = 0.0 // 设置列间距
        layout.sectionInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0) // 设置边缘内边距
        layout.itemSize = CGSize(width: 40.0, height: 40.0) // 自定义单元格大小
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.isScrollEnabled = false
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")
        return view
    }()
    
    private let moreEmojiButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage.set("msg_emoji_add_btn")
        button.setImage(image, for: .normal)
        return button
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: CGRectZero)
        
        setupUI()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        moreEmojiButton.addTarget(self, action: #selector(moreEmojiButtonAction), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView.frame = CGRectMake(6, 6, itemWith * CGFloat(self.dataSource.count), itemWith)
//        moreEmojiButton.frame = CGRect(origin: CGPoint(x: width - 6 - itemWith, y: 6), size: CGSize(width: itemWith, height: itemWith))
    }
    
    private func setupUI() {
        self.backgroundColor = .white
        layer.masksToBounds = true
        layer.cornerRadius = height / 2.0
        
        self.addSubview(collectionView)
//        self.addSubview(moreEmojiButton)
    }
    
    @objc func moreEmojiButtonAction(_ sender: UIButton) {
        print("【DM】moreEmojiButtonAction")
    }
}

extension MessageReactionSelectionView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let emoji = self.dataSource[indexPath.row]
        self.delegate?.reactionSelectionView(self, didSelect: emoji)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
        cell.backgroundColor = .clear
        
        let emoji = self.dataSource[indexPath.row]
        
        let label = UILabel()
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 20.0
        if let selectedEmoji = self.selectedEmoji, selectedEmoji == emoji {
            label.backgroundColor = UIColor(hexString: "#E7E8E8")
        } else {
            label.backgroundColor = .clear
        }
        label.font = UIFont.systemFont(ofSize: 26)
        label.text = emoji
        label.textAlignment = .center
        cell.contentView.addSubview(label)
        label.frame = cell.contentView.bounds
        
        return cell
    }
}

