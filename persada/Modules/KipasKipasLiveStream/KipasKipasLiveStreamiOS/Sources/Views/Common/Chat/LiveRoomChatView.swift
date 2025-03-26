import UIKit
import KipasKipasTRTC
import KipasKipasLiveStream
import KipasKipasShared

public final class LiveRoomChatView: UIView {
    
    private let tableView = UITableView()
    
    private var animatedIndexPaths: [IndexPath] = []
    
    private var chats: [LiveRoomChatViewModel] = [] {
        didSet { reload() }
    }
    
    private lazy var joinedMessages = {
        return TimedSequence<LiveRoomChatViewModel>(interval: 0.7) { [weak self] newChat in
            self?.reconfigureChats(of: .JOIN, newChat: newChat)
        }
    }()
    
    private lazy var likedMessages = {
        return TimedSequence<LiveRoomChatViewModel>(interval: 0.7) { [weak self] newChat in
            self?.reconfigureChats(of: .LIKE, newChat: newChat)
        }
    }()
    
    private let gradientLayer = CAGradientLayer()
    private let opaqueColor = UIColor.black.cgColor
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        configureFadingLayer()
        updateContentInsets()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        return nil
    }
    
    private func reload() {
        guard chats.isEmpty == false else { return }
        
        tableView.reloadData()
        
        setNeedsLayout()
        layoutIfNeeded()
        
        let indexPath = IndexPath(row: chats.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
}

extension LiveRoomChatView: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: LiveRoomChatCell = tableView.dequeueReusableCell(at: indexPath)
        cell.configure(with: chats[indexPath.row])
        return cell
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (animatedIndexPaths.contains(indexPath) == false) {
            let animation = TableAnimation.makeFadeAnimation(duration: 0.4)
            let animator = TableViewAnimator(animation: animation)
            animator.animate(cell: cell, at: indexPath, in: tableView)
            
            animatedIndexPaths.append(indexPath)
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        gradientLayer.colors = [
            scrollView.topOpacity,
            opaqueColor,
            opaqueColor,
            scrollView.bottomOpacity
        ]
    }
}

extension LiveRoomChatView: LiveRoomMessageServiceDelegate {
    public func onReceiveMessage(_ data: Data?) {
        guard let data,
              let chat = LiveRoomChatView.decode(
                LiveRoomMessage<Sender>.self,
                from: data)
        else { return }
        
        let sender = chat.data.extInfo.value
        let message = chat.data.message
        let type = chat.data.extInfo.msgType
        
        let fullMessage = LiveRoomChatViewModel(
            senderUserId: sender.userId,
            senderUsername: sender.userName,
            senderAvatarURL: sender.avatarUrl,
            message: message,
            messageType: .init(rawValue: type.rawValue) ?? .CHAT
        )
        
        let shortMessage = LiveRoomChatViewModel(
            message: message,
            messageType: .init(rawValue: type.rawValue) ?? .CHAT
        )
        
        switch type {
        case .CHAT:
            chats.append(fullMessage)
            
        case .LIKE:
            likedMessages.append(shortMessage)
            
        case .JOIN:
            joinedMessages.append(shortMessage)
            
        case .WELCOME:
            guard chats.ofType(.WELCOME).isEmpty else { return }
            chats.append(shortMessage)
        }
    }
    
    private func reconfigureChats(
        of type: LiveRoomChatViewModel.ChatType,
        newChat viewModel: LiveRoomChatViewModel
    ) {
        guard let index = chats.lastIndexOf(type: type) else {
            chats.append(viewModel)
            return
        }
        
        let filtered = chats.ofType(type)
        
        if filtered.count < 2 {
            chats.append(viewModel)
            
        } else if index == chats.count - 1 {
            animatedIndexPaths.safeRemoveLast()
            chats[index] = viewModel
        } else {
            animatedIndexPaths.safeRemoveLast()
            
            chats.append(viewModel)
            chats.safeRemove(at: index)
        }
    }
    
    private static func decode<T: Decodable>(_ response: T.Type, from data: Data) -> T? {
        return try? JSONDecoder().decode(response, from: data)
    }
}

// MARK: UI
private extension LiveRoomChatView {
    func configureUI() {
        backgroundColor = .clear
        configureTableView()
    }
    
    func configureTableView() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.alwaysBounceVertical = false
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerCell(LiveRoomChatCell.self)
        
        addSubview(tableView)
        tableView.anchors.edges.pin()
    }
    
    
    func configureFadingLayer() {
        gradientLayer.removeFromSuperlayer()
        
        let maskLayer = CALayer()
        maskLayer.frame = bounds
        
        let boundsSize = bounds.size
        
        gradientLayer.frame = CGRect(x: bounds.origin.x, y: 0, width: boundsSize.width, height: boundsSize.height)
        gradientLayer.colors = [tableView.topOpacity, opaqueColor, opaqueColor, tableView.bottomOpacity]
        gradientLayer.locations = [0, 0.2, 0.8, 1]
        
        maskLayer.addSublayer(gradientLayer)
        
        layer.mask = maskLayer
    }
    
    func updateContentInsets() {
        let midFrameHeight = bounds.height
        let contentSizeHeight = tableView.contentSize.height
        let diff = midFrameHeight - contentSizeHeight
        
        UIView.animate(withDuration: 0.3) {
            self.tableView.contentInset = UIEdgeInsets(top: diff > 0 ? diff : 0, left: 0, bottom: 12, right: 0)
        }
    }
}
