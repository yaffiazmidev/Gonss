//
//  ConversationMenuView.swift
//  KipasKipasDirectMessageUI
//
//  Created by MissYasiky on 2024/4/16.
//

import Foundation
import UIKit

enum MenuItemType {
    case reply
    case forward
    case copy
    case revoke
    case info
    case pin
    case delete
}

protocol ConversationMenuViewDelegate: NSObject {
    func menuView(_ menuView: ConversationMenuView, didSelectAt type: MenuItemType)
}

class ConversationMenuView: UIView {
    weak public var delegate: ConversationMenuViewDelegate?
    public let width: CGFloat = 230.0
    public var height: CGFloat {
        get {
            return CGFloat(self.dataSource.count) * rowHeight
        }
    }
    public var allowReply: Bool = false
    public var allowRevoke: Bool = false
    public var allowCopy: Bool = false
    public var isPin: Bool = false
    private var dataSource: [(MenuItemType, String, String)] {
        get {
            let reply: (MenuItemType, String, String) = (.reply, "Balas", "conv_meun_reply_icon")
            let forward: (MenuItemType, String, String) = (.forward, "Teruskan", "conv_meun_forward_icon")
            let copy: (MenuItemType, String, String) = (.copy, "Salin", "conv_meun_copy_icon")
            let revoke: (MenuItemType, String, String) = (.revoke, "Tarik", "conv_meun_revoke_icon")
            let info: (MenuItemType, String, String) = (.info, "Informasi", "conv_meun_info_icon")
            let pin: (MenuItemType, String, String) = isPin ? (.pin, "Sematkan", "conv_meun_unpin_icon") : (.pin, "Pin", "conv_meun_pin_icon")
            let delete: (MenuItemType, String, String) = (.delete, "Hapus", "conv_meun_delete_icon")
            
            var array: [(MenuItemType, String, String)] = []
            if allowRevoke {
//                array = [forward, revoke, info, pin, delete]
                array = [forward, revoke, delete]
            } else {
//                array = [forward, info, pin, delete]
                array = [forward, delete]
            }
            if allowCopy {
                array.insert(copy, at: 1)
            }
            if allowReply {
                array.insert(reply, at: 0)
            }
            return array
        }
    }
    private var containerView: UIView!
    private var tableView: UITableView!
    private var blurView: UIVisualEffectView!
    private let rowHeight: CGFloat = 40.0
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: CGRectZero)
        
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        containerView.frame = self.bounds
        blurView.frame = containerView.bounds
        tableView.frame = containerView.bounds
    }
    
    private func setupUI() {
        layer.masksToBounds = true
        layer.cornerRadius = 6.5
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.init(hexString: "#979797", alpha: 0.5).cgColor
        
        let blurEffect = UIBlurEffect(style: .light) // or .dark, .extraLight, .regular
        blurView = UIVisualEffectView(effect: blurEffect)
        
        containerView = UIView()
        containerView.addSubview(blurView)
        containerView.sendSubviewToBack(blurView)
        self.addSubview(containerView)
        
        setupTableView()
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: CGRectZero, style: .plain)
        containerView.addSubview(tableView)
        
        tableView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "menuCell")
        tableView.isScrollEnabled = false
        tableView.rowHeight = rowHeight
        tableView.estimatedRowHeight = rowHeight
        tableView.separatorInset = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
//        tableView.anchors.edges.pin(insets: 0)
    }
}

extension ConversationMenuView: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = dataSource[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath)
        cell.backgroundColor = .clear
        
        let imageView: UIImageView = UIImageView.init()
        imageView.setImage(data.2)
        cell.contentView.addSubview(imageView)
        imageView.frame = CGRectMake(width - 20 - 15, (rowHeight - 20) / 2.0, 20, 20)
//        imageView.anchors.size.equal(CGSize(width: 20, height: 20))
//        imageView.anchors.centerY.equal(self.anchors.centerY)
//        imageView.anchors.trailing.equal(self.anchors.trailing, constant: -16)

        let label: UILabel = UILabel.init()
        label.text = data.1
        if data.0 == .delete {
            label.textColor = UIColor.init(hexString: "#FF3B30")
        } else {
            label.textColor = .black
        }
        label.font = UIFont.systemFont(ofSize: 16)
        cell.contentView.addSubview(label)
        label.frame = CGRectMake(15, 0, imageView.frame.origin.x - 15, rowHeight)
//        label.anchors.centerY.equal(self.anchors.centerY)
//        label.anchors.leading.equal(self.anchors.leading, constant: 16)
//        label.anchors.trailing.equal(imageView.anchors.leading, constant: -10)
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let data = dataSource[indexPath.row]
        self.delegate?.menuView(self, didSelectAt: data.0)
    }
}
