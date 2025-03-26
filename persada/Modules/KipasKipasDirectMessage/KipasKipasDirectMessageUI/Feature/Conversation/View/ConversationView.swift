import UIKit
import KipasKipasShared
import KipasKipasDirectMessage

public enum TXIMChatPriceType {
    case none
    case increase_diamond
    case decrease_coin
}

protocol ConversationViewDelegate: AnyObject {
    func didTapMedia(isVideo: Bool, url: URL?)
    func loadPreviousMessages()
    func tableViewDidScroll()
    func didTapSettingButton()
    func didTapVoiceCallButton()
    func didTapVideoCallButton()
    func didTapSendMessageButton()
    func didTapLearnMorePaidDM()
    func didStartPaidMessage()
    func didStopPaidMessage()
    func didTapPatnerProfile()
    func didTapLink(with url: URL)
    func didTapMention(with username: String)
    func didTapHashtag(with hashtag: String)
    func didTapDeleteButton(with messages: [TXIMMessage])
    func didTapForwardButton(with messages: [TXIMMessage])
    func didTapRevokeMessage(with message: TXIMMessage)
    func didSelectEmoji(with message: TXIMMessage, emoji: String)
    func isChatUserVerified() -> Bool
    func updateNavigationBarForSelection(with select: Bool)
    func didStopScrollForSecond()
    func didTapUnblock()
}

public class ConversationView: UIView, Accessible {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var paidHeaderContainer: UIStackView!
    @IBOutlet weak var paidHeaderSessionContainerStackView: KKDefaultStackView!
    @IBOutlet weak var paidChatDateLabel: UILabel!
    @IBOutlet weak var payerSessionContainerStackView: KKDefaultStackView!
    @IBOutlet weak var totalMyCoinLabel: UILabel!
    @IBOutlet weak var totalCoinDepositLabel: UILabel!
    @IBOutlet weak var payerStopSessionContainerStackView: KKDefaultStackView!
    @IBOutlet weak var paidNotifInfoLabel: UILabel!
    @IBOutlet weak var selebSessionContainerStackView: KKDefaultStackView!
    @IBOutlet weak var totalDiamondLabel: UILabel!
    @IBOutlet weak var recipientStopSessionContainerStackView: KKDefaultStackView!
    
    @IBOutlet weak var inputMessageRootContainer: KKDefaultStackView!
    @IBOutlet weak var inputMessageContainerStackView: UIStackView!
    @IBOutlet weak var startSendPaidMessagesContainerStackView: UIStackView!
    @IBOutlet weak var startPaidMessageButtonView: UIView!
    @IBOutlet weak var diamondPriceLabel: UILabel!
//    @IBOutlet weak var attachButton: UIButton!
    @IBOutlet weak var inputContainerStackView: UIStackView!
    @IBOutlet weak var inputMessageTextView: UITextView!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var microphoneButton: UIButton!
    
    @IBOutlet weak var unreadMessageCountContainerStackView: KKDefaultStackView!
    @IBOutlet weak var unReadMessageCountLabel: UILabel!
    
    @IBOutlet weak var selectionFooterContainer: UIView!
    @IBOutlet weak var selectionFooterDeleteButton: UIButton!
    @IBOutlet weak var selectionFooterLabel: UILabel!
    
    @IBOutlet weak var inputBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputMessageTextViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var replyMessageContainer: UIView!
    @IBOutlet weak var replyMessageHeaderLine: UIView!
    @IBOutlet weak var replyMessageUserNameLabel: UILabel!
    @IBOutlet weak var replyMessageDetailTextLabel: UILabel!
    @IBOutlet weak var replyMessageThumnailImageView: UIImageView!
    @IBOutlet weak var replyMessageCloseView: UIView!
    @IBOutlet weak var replyMessageLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var replyMessageSecondLabelConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var blockByMeContainerStackView: UIStackView!
    @IBOutlet weak var blockMeContainerStackView: UIStackView!
    @IBOutlet weak var usernameBlockMeLabel: UILabel!
    @IBOutlet weak var usernameBlockByMeLabel: UILabel!
    
    lazy var keyboardObserver: KeyboardObserver = {
        let keyboardObserver = KeyboardObserver()
        keyboardObserver.delegate = self
        return keyboardObserver
    }()
    
    lazy var cancleSelectButton: UIButton = {
        let button = UIButton()
        button.setTitle("Batalkan", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.frame = CGRect(x: 0, y: 0, width: 48, height: 32)
        button.addTarget(self, action: #selector(handleDidTapCancleSelectButton), for: .touchUpInside)
        return button
    }()
    
    lazy var settingButton: UIButton = {
        let button = UIButton()
        let img = UIImage.set(.get(.icEllipsisVBlack))?.withTintColor(.systemBlue)
        button.setImage(img, for: UIControl.State())
        button.frame = CGRect(x: 0, y: 0, width: 48, height: 32)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(handleDidTapSettingButton), for: .touchUpInside)
        return button
    }()
    
    lazy var voiceCallButton: UIButton = {
        let button = UIButton()
        let img = UIImage.set(.get(.icVoiceCall))?.withTintColor(.systemBlue)
        button.setImage(img, for: UIControl.State())
        button.frame = CGRect(x: 0, y: 0, width: 48, height: 32)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(handleDidTapVoiceCallButton), for: .touchUpInside)
        return button
    }()
    
    lazy var videoCallButton: UIButton = {
        let button = UIButton()
        let img = UIImage.set(.get(.icVideoCall))?.withTintColor(.systemBlue)
        button.setImage(img, for: UIControl.State())
        button.frame = CGRect(x: 0, y: 0, width: 48, height: 32)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(handleDidTapVideoCallButton), for: .touchUpInside)
        return button
    }()


    lazy var imageBackground: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.image = UIImage(named: "imgBackground")!
        image.backgroundColor = .systemBlue
        return image
    }()
    
    private enum Constant {
        static let loadMoreThreshold: CGFloat = 100
    }
    
    var isTyping: Bool = false {
        didSet {
            sendMessageButton.setImage(UIImage.set(isTyping ? "ic_send_solid_blue" : "ic_camera_outline_blue"), for: .normal)
            microphoneButton.isHidden = isTyping
        }
    }
    
    weak var delegate: ConversationViewDelegate?
    var messageList: [TXIMMessage] = []
    private let placeholder = ".."
    var isStayOnLastIndex: Bool = true
    var isEndScrolling: Bool = true
    var allowDismissKeyboard = true
    var isPaid: Bool = false
    private var isSeleb: Bool = false
    private var price: Int?
    private var selectedMessage: [TXIMMessage] = []
    private var isSelecting: Bool = false
    private var isDeleting: Bool = false
    public var replyMsg: TXIMMessage?
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        generateAccessibilityIdentifiers()
        handleOnTap()
        setupTableView()
        setupPaidNotifInfoAttributedText()
        inputMessageTextView.delegate = self
        inputMessageTextView.inputAccessoryView = UIView()
        inputContainerStackView.layer.borderColor = UIColor(hexString: "#DDDDDD").cgColor
        setupImageBackground()
        sendMessageButton.setImage(UIImage.set("ic_camera_outline_blue"), for: .normal)
        
        selectionFooterDeleteButton.setTitle("", for: .normal)
    }
    
    private func setupImageBackground() {
        addSubview(imageBackground)
        imageBackground.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor).isActive = true
        imageBackground.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageBackground.bottomAnchor.constraint(equalTo: inputMessageRootContainer.topAnchor).isActive = true
        imageBackground.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
        sendSubviewToBack(imageBackground)
    }
    
    private func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = .init(top: 10, left: 0, bottom: 0, right: 0)
        tableView.allowsMultipleSelection = false
        tableView.allowsSelection = false
        tableView.register(ConversationTextCell.self, forCellReuseIdentifier: "ConversationTextCell")
        tableView.register(ConversationMediaCell.self, forCellReuseIdentifier: "ConversationMediaCell")
        tableView.register(ConversationRevokeCell.self, forCellReuseIdentifier: "ConversationRevokeCell")
        tableView.register(ConversationLocalCell.self, forCellReuseIdentifier: "ConversationLocalCell")
    }
    
    private func setupPaidNotifInfoAttributedText() {
        let paidNotifInfoAttributedText = NSMutableAttributedString(string: "Koin yang kamu miliki akan berkurang 1 untuk setiap balasan dalam sesi yang berlangsung. ")
        let attributedString = NSAttributedString(
            string: "Pelajari lebih lanjut",
            attributes: [.foregroundColor: UIColor(hexString: "#1890FF"), .underlineStyle: NSUnderlineStyle.single.rawValue]
        )
        
        paidNotifInfoAttributedText.append(attributedString)
        paidNotifInfoLabel.attributedText = paidNotifInfoAttributedText
    }
    
    private func handleOnTap() {
        replyMessageCloseView.onTap { [weak self] in
            guard let self = self else { return }
            self.replyMsg = nil
            self.replyMessageContainer.isHidden = true
        }
        
        paidNotifInfoLabel.onTap { [weak self] in
            guard let self = self else { return }
            
            self.delegate?.didTapLearnMorePaidDM()
        }
        
        startPaidMessageButtonView.onTap { [weak self] in
            guard let self = self else { return }
            
            self.delegate?.didStartPaidMessage()
        }
        
        payerStopSessionContainerStackView.onTap { [weak self] in
            guard let self = self else { return }
            
            self.delegate?.didStopPaidMessage()
        }
        
        recipientStopSessionContainerStackView.onTap { [weak self] in
            guard let self = self else { return }
            
            self.delegate?.didStopPaidMessage()
        }
        
        unreadMessageCountContainerStackView.onTap { [weak self] in
            guard let self = self else { return }
            self.unreadMessageCountContainerStackView.isHidden = true
            self.scrollToLastMessage(force: true)
        }
        
        sendMessageButton.onTap { [weak self] in
            guard let self = self else { return }
            self.didTapSendMessageButton()
        }
    }
    
    @IBAction func selectionFooterDeleteButtonAction(sender: UIButton) {
        if isDeleting {
            delegate?.didTapDeleteButton(with: selectedMessage)
        } else {
            delegate?.didTapForwardButton(with: selectedMessage)
        }
    }
    
    @IBAction func didTapUnblocMemberButton(_ sender: Any) {
        delegate?.didTapUnblock()
    }
    
    @objc private func handleDidTapCancleSelectButton() {
        cancelMultipleSelection()
    }
    
    @objc private func handleDidTapSettingButton() {
        delegate?.didTapSettingButton()
    }
    
    @objc private func handleDidTapVoiceCallButton() {
        delegate?.didTapVoiceCallButton()
    }
    
    @objc private func handleDidTapVideoCallButton() {
        delegate?.didTapVideoCallButton()
    }
    
    func didTapSendMessageButton() {
        delegate?.didTapSendMessageButton()
    }
    
    func makeLeftBarButtonItems(userName: String, avatar: String, isVerify: Bool) -> [UIBarButtonItem] {
        let targetProfileImageView = UIImageView()
        targetProfileImageView.backgroundColor = .clear
        targetProfileImageView.contentMode = .scaleAspectFill
        targetProfileImageView.clipsToBounds = true
        targetProfileImageView.layer.cornerRadius = 18
        targetProfileImageView.sd_setImage(with: URL(string: avatar), placeholderImage:.defaultProfileImageCircle)
        
        let targetProfileContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        
        targetProfileContainerView.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.didTapPatnerProfile()
        }
        
        targetProfileContainerView.addSubview(targetProfileImageView)
        targetProfileImageView.frame = targetProfileContainerView.bounds
        
        let targetNameLabel = UILabel()
        targetNameLabel.textColor = .black
        targetNameLabel.text = userName
        targetNameLabel.font = .Roboto(.medium, size: 18)
        
        let targetIsVerifiedImageView = UIImageView()
        targetIsVerifiedImageView.setImage(.get(.icVerified))
        targetIsVerifiedImageView.contentMode = .scaleAspectFill
        targetIsVerifiedImageView.clipsToBounds = true
        let isVerified = isVerify
        targetIsVerifiedImageView.isHidden = !isVerified
        targetIsVerifiedImageView.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        
        let targetNameContainerStackView = UIStackView()
        targetNameContainerStackView.axis = .horizontal
        targetNameContainerStackView.spacing = 4
        targetNameContainerStackView.alignment = .center
        targetNameContainerStackView.distribution = .fill
        targetNameContainerStackView.addArrangedSubview(targetNameLabel)
        targetNameContainerStackView.addArrangedSubview(targetIsVerifiedImageView)
        
        targetNameContainerStackView.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.didTapPatnerProfile()
        }
        
        return [
            UIBarButtonItem(customView: targetProfileContainerView),
            UIBarButtonItem(customView: targetNameContainerStackView),
        ]
    }
    
    func messageSent() {
        self.replyMsg = nil
        self.replyMessageContainer.isHidden = true
    }
    
    func updateHeaderView(diamond: Int?, coin: Int?, deposit: Int?, isSeleb: Bool) {
        self.isSeleb = isSeleb
        
        totalDiamondLabel.text = "\(diamond ?? 0)"
        totalMyCoinLabel.text = "\(coin ?? 0)"
        totalCoinDepositLabel.text = "\(deposit ?? 0)"
        paidChatDateLabel.text = "\(Date().sbu_toString(format: .ddMMMyyyy)) - Pesan Berbayar"
        
        updatePaidUI()
    }
    
    func updateFooterView(price: Int?) {
        self.price = price
        diamondPriceLabel.text = "\(price ?? 0)"
        updatePaidUI()
    }
    
    private func updatePaidUI() {
        tableView.contentInset = .init(top: isPaid ? 20 : 10, left: 0, bottom: 0, right: 0)
        
        if isPaid {
            startSendPaidMessagesContainerStackView.isHidden = true
            selebSessionContainerStackView.isHidden = !isSeleb
            payerSessionContainerStackView.isHidden = isSeleb
            paidHeaderSessionContainerStackView.isHidden = false
        } else {
            //TODO: close Paid temply
//            let isVerified = delegate?.isChatUserVerified() ?? false
//            startSendPaidMessagesContainerStackView.isHidden = !isVerified
            startSendPaidMessagesContainerStackView.isHidden = true
            selebSessionContainerStackView.isHidden = true
            payerSessionContainerStackView.isHidden = true
            paidHeaderSessionContainerStackView.isHidden = true
        }
    }
    
    func updateBlockByMeUI(block: Bool, name: String) {
        usernameBlockByMeLabel.text = name
        blockByMeContainerStackView.isHidden = !block
        inputMessageContainerStackView.isHidden = block
    }
    
    func isEmptyInputMessageField() -> Bool {
        guard let message = inputMessageTextView.text, !message.isEmpty else { return true }
        return message == placeholder
    }
    
    func setInputMessageDefaultView() {
        isTyping = false
        inputMessageTextView.text = placeholder
        inputMessageTextView.textColor = UIColor(hexString: "#BBBBBB")
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) { [weak self] in
                guard let self = self else { return }
                self.inputMessageTextViewHeightConstraint.constant = 32
                self.layoutIfNeeded()
            }
        }
    }
    
    func scrollToLastMessage(force: Bool) {
        if !force && !isStayOnLastIndex {
            return
        }
        DispatchQueue.main.async {
            guard !self.messageList.isEmpty else { return }
            self.tableView.scrollToRow(at: IndexPath(row: self.messageList.count - 1, section: 0), at: .bottom, animated: true)
        }
    }
    
    func cancelMultipleSelection() {
        isSelecting = false
        
        tableView.allowsSelection = false
        tableView.allowsMultipleSelection = false
        delegate?.updateNavigationBarForSelection(with: false)
        
        inputMessageRootContainer.isHidden = false
        selectionFooterContainer.isHidden = true
        
        selectedMessage.removeAll()
        tableView.reloadData()
    }
    
    func enableMultipleSelection(delete: Bool) {
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = true
        delegate?.updateNavigationBarForSelection(with: true)
        
        inputMessageRootContainer.isHidden = true
        selectionFooterContainer.isHidden = false
        
        isSelecting = true
        isDeleting = delete
        if delete {
            let blueImage = UIImage.set("conv_bottom_delete_icon")?.withTintColor(.systemBlue)
            selectionFooterDeleteButton.setImage(blueImage, for: .normal)
            let grayImage = UIImage.set("conv_bottom_delete_icon")?.withTintColor(.systemGray)
            selectionFooterDeleteButton.setImage(grayImage, for: .disabled)
        } else {
            let blueImage = UIImage.set("conv_bottom_forward_icon")?.withTintColor(.systemBlue)
            selectionFooterDeleteButton.setImage(blueImage, for: .normal)
            let grayImage = UIImage.set("conv_bottom_forward_icon")?.withTintColor(.systemGray)
            selectionFooterDeleteButton.setImage(grayImage, for: .disabled)
        }
        
        tableView.reloadData()
    }
    
    private func selectedMessageChanged(_ message: TXIMMessage, add: Bool) {
        if add {
            selectedMessage.append(message)
        } else {
            selectedMessage = selectedMessage.filter({ $0.msgID != message.msgID })
        }
        selectionFooterLabel.text = "\(selectedMessage.count) Terplilih"
        selectionFooterDeleteButton.isEnabled = selectedMessage.count > 0
    }
    
    func scrollToStayWithMessageInsert(count: Int) {
        UIView.setAnimationsEnabled(false)
        tableView.performBatchUpdates {
            let indexPathsToInsert = (0..<count).map { IndexPath(row: $0, section: 0) }
            tableView.insertRows(at: indexPathsToInsert, with: .none)
        } completion: { [weak self] _ in
            guard let self else { return }
            self.tableView.layoutIfNeeded()
            
            if let index = self.tableView.indexPathsForVisibleRows?.first as? IndexPath {
                let indexPath = IndexPath(row: index.row + count, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
            }
            
            UIView.setAnimationsEnabled(true)
        }
    }
}

extension ConversationView: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messageList[indexPath.row]
        if message.status == .revoke {
            tableView.deselectRow(at: indexPath, animated: false)
        } else {
            selectedMessageChanged(message, add: true)
        }
    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let message = messageList[indexPath.row]
        selectedMessageChanged(message, add: false)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        isEndScrolling = false
        if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) - 150 {
            isStayOnLastIndex = true
        } else {
            isStayOnLastIndex = false
        }
        
        if let _ = self.tableView.visibleCells.last {
            delegate?.tableViewDidScroll()
        }
        scrollStop()
    }
    
    private func scrollStop() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(didStopScrollForSecond), object: nil)
        self.perform(#selector(didStopScrollForSecond), with: nil, afterDelay: 1)
    }
    
    @objc private func didStopScrollForSecond() {
        delegate?.didStopScrollForSecond()
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isEndScrolling = true
        if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) {
            isStayOnLastIndex = true
        } else {
            isStayOnLastIndex = false
        }
        
        if scrollView.contentOffset.y - Constant.loadMoreThreshold <= 0 {
            delegate?.loadPreviousMessages()
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = messageList[indexPath.row]
        if message.status == .revoke {
            return ConversationRevokeCell.height(with: message)
        } else if message.status == .local {
            return ConversationLocalCell.height(with: message)
        } else {
            switch message.type {
            case .text:
                return ConversationTextCell.heightWithMessage(message, enableSelect: isSelecting)
            case .image, .video:
                return ConversationMediaCell.height(with: message)
            default:
                return 0
            }
        }
    }
}

extension ConversationView: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messageList[indexPath.row]
        if message.status == .revoke {
            let cell:ConversationRevokeCell  = tableView.dequeueReusableCell(withIdentifier: "ConversationRevokeCell", for: indexPath) as! ConversationRevokeCell
            cell.delegate = self
            cell.updateMessage(message)
            return cell
        } else if message.status == .local {
            let cell:ConversationLocalCell  = tableView.dequeueReusableCell(withIdentifier: "ConversationLocalCell", for: indexPath) as! ConversationLocalCell
            cell.updateMessage(message)
            return cell
        } else {
            switch message.type {
            case .text:
                let cell: ConversationTextCell  = tableView.dequeueReusableCell(withIdentifier: "ConversationTextCell", for: indexPath) as! ConversationTextCell
                cell.delegate = self
                cell.updateMessage(message, indexPath: indexPath, enableSelect:isSelecting, type: self.showDiamondIncreaseOrCoinDecrease(at: indexPath.row))
                message.setEmojiChangeHandle { [weak self] _ in
                    if let self {
                        cell.autoUpdateMessage(message, indexPath: indexPath, enableSelect:isSelecting, type: self.showDiamondIncreaseOrCoinDecrease(at: indexPath.row))
                        if let index = cell.indexPath {
                            tableView.reloadRows(at: [index], with: .automatic)
                        }
                    }
                }
                message.setStatusChangeHandle { status in
                    cell.updateMessageStatus(message)
                }
                message.setQuoteMessageHandle { [weak self] message in
                    if let self {
                        cell.updateMessage(message, indexPath: indexPath, enableSelect:isSelecting, type: self.showDiamondIncreaseOrCoinDecrease(at: indexPath.row))
                        if let index = cell.indexPath {
                            tableView.reloadRows(at: [index], with: .automatic)
                        }
                    }
                }
                message.setCloudCustomDataChangedHandle { [weak self] _, _, _ in
                    if let self {
                        cell.updateMessage(message, indexPath: indexPath, enableSelect:isSelecting, type: self.showDiamondIncreaseOrCoinDecrease(at: indexPath.row))
                    }
                }
                /*
                 cell.messageLabel.handleURLTap { [weak self] url in
                 guard let self = self else { return }
                 self.delegate?.didTapLink(with: url)
                 }
                 
                 cell.messageLabel.handleMentionTap { [weak self] mention in
                 guard let self = self else { return }
                 self.delegate?.didTapMention(with: mention)
                 }
                 
                 cell.messageLabel.handleHashtagTap { [weak self] hashtag in
                 guard let self = self else { return }
                 self.delegate?.didTapHashtag(with: hashtag)
                 }
                 */
                return cell
            case .image, .video:
                let cell: ConversationMediaCell  = tableView.dequeueReusableCell(withIdentifier: "ConversationMediaCell", for: indexPath) as! ConversationMediaCell
                cell.delegate = self
                cell.updateMessage(message, indexPath: indexPath, enableSelect:isSelecting, type: self.showDiamondIncreaseOrCoinDecrease(at: indexPath.row))
                message.setEmojiChangeHandle { [weak self] _ in
                    if let self {
                        cell.autoUpdateMessage(message, indexPath: indexPath, enableSelect:isSelecting, type: self.showDiamondIncreaseOrCoinDecrease(at: indexPath.row))
                        if let index = cell.indexPath {
                            tableView.reloadRows(at: [index], with: .automatic)
                        }
                    }
                }
                message.setStatusChangeHandle { status in
                    cell.updateMessageStatus(message)
                }
                message.setQuoteMessageHandle { [weak self] message in
                    if let self {
                        cell.updateMessage(message, indexPath: indexPath, enableSelect:isSelecting, type: self.showDiamondIncreaseOrCoinDecrease(at: indexPath.row))
                        if let index = cell.indexPath {
                            tableView.reloadRows(at: [index], with: .automatic)
                        }
                    }
                }
                message.setCloudCustomDataChangedHandle { [weak self] _, _, _ in
                    if let self {
                        cell.updateMessage(message, indexPath: indexPath, enableSelect:isSelecting, type: self.showDiamondIncreaseOrCoinDecrease(at: indexPath.row))
                    }
                }
                cell.thumbnailImageView.onTap { [weak self] in
                    guard let self = self else { return }
                    let isVideo = message.type == .video
                    if isVideo {
                        if let path = message.videoPath, FileManager.default.fileExists(atPath: path) {
                            self.delegate?.didTapMedia(isVideo: isVideo, url: URL(fileURLWithPath: path))
                        } else {
                            self.delegate?.didTapMedia(isVideo: isVideo, url: URL(string: message.videoUrl ?? ""))
                        }
                    } else {
                        if let path = message.imagePath, FileManager.default.fileExists(atPath: path) {
                            self.delegate?.didTapMedia(isVideo: isVideo, url: URL(fileURLWithPath: path))
                        } else {
                            self.delegate?.didTapMedia(isVideo: isVideo, url: URL(string: message.originImageUrl ?? ""))
                        }
                    }
                }
                return cell
            default:
                return UITableViewCell()
            }
        }
    }
         
    private func showDiamondIncreaseOrCoinDecrease(at index: Int) -> TXIMChatPriceType {
        guard index > 0 && index <= messageList.count - 1 else {
            return .none
        }
        
        let lastMsg = messageList[index - 1]
        let msg = messageList[index]
        if lastMsg.isSelf == msg.isSelf {
            return .none
        }
        
        if !msg.isPaid || !lastMsg.isPaid {
            return .none
        }
        
        if msg.isSelf && !msg.isPayer {
            return .increase_diamond
        } else if !msg.isSelf && msg.isPayer {
            return .decrease_coin
        } else {
            return .none
        }
    }
}

extension ConversationView: UITextViewDelegate {
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        inputMessageTextView.text = textView.text == placeholder ? "" : textView.text
        inputMessageTextView.textColor = textView.text == placeholder ? UIColor(hexString: "#BBBBBB") : .black
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        inputMessageTextView.text = textView.text == "" ? placeholder : textView.text
        inputMessageTextView.textColor = textView.text == placeholder ? UIColor(hexString: "#BBBBBB") : .black
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        isTyping = !textView.text.isEmpty
        let contentHeight = inputMessageTextView.contentSize.height
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) { [weak self] in
                guard let self = self else { return }
                
                if contentHeight >= 32 {
                    self.inputMessageTextViewHeightConstraint.constant = contentHeight <= 100 ? contentHeight : 110
                } else {
                    self.inputMessageTextViewHeightConstraint.constant = 32
                }
                self.layoutIfNeeded()
            }
        }
    }
    
    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return allowDismissKeyboard
    }
}

// MARK: - KeyboardObserverDelegate

extension ConversationView: KeyboardObserverDelegate {
    
    public func keyboardObserver(_ keyboardObserver: KeyboardObserver, willShowKeyboardWith keyboardInfo: KeyboardInfo) {
        let keyboardHeight = keyboardInfo.height - safeAreaInsets.bottom
        inputBottomConstraint?.constant = isDeviceWithHomeButton ? (keyboardHeight - 16) : (keyboardHeight - 2)
        
        keyboardInfo.animate { [weak self] in
            self?.layoutIfNeeded()
        }
    }
    
    public func keyboardObserver(_ keyboardObserver: KeyboardObserver, willHideKeyboardWith keyboardInfo: KeyboardInfo) {
        inputBottomConstraint?.constant = keyboardInfo.height
        
        keyboardInfo.animate { [weak self] in
            self?.layoutIfNeeded()
        }
    }
}

extension ConversationView: ConversationMenuWindowDelegate {
    func menuWindow(_ menuWindow: ConversationMenuWindow, didSelectAt type: MenuItemType, message: TXIMMessage?) {
        switch type {
        case .reply:
            replyMessage(message)
        case .forward:
            forwardMessage(message)
        case .copy:
            copyMessage(message)
        case .revoke:
            revokeMessage(message)
        case .info:
            print("【DM】message info")
        case .pin:
            print("【DM】message pin")
        case .delete:
            deleteMessage(message)
        }
    }
    
    func menuWindow(_ menuWindow: ConversationMenuWindow, didSelectEmoji emoji: String?, message: TXIMMessage?) {
        guard let emoji, let message else {
            return
        }
        delegate?.didSelectEmoji(with: message, emoji: emoji)
    }
    
    private func replyMessage(_ message: TXIMMessage?) {
        guard let message, let index = messageList.firstIndex(where: { $0.msgID == message.msgID }) else {
            return
        }
        replyMsg = message
        replyMessageContainer.isHidden = false
        let hexString = message.isSelf ? "#19A901" : "#D9006A"
        replyMessageHeaderLine.backgroundColor = UIColor(hexString: hexString)
        replyMessageUserNameLabel.textColor = UIColor(hexString: hexString)
        replyMessageUserNameLabel.text = message.isSelf ? "You" : message.nickName
        
        let media = message.type == .image || message.type == .video
        replyMessageThumnailImageView.isHidden = !media
        replyMessageLabelConstraint?.constant = media ? 0 : -40
        replyMessageSecondLabelConstraint?.constant = media ? 0 : -40
        
        if media {
            let isVideo = message.type == .video
            let imagePath = isVideo == true ? message.snapshotPath : message.imagePath
            let imageUrl = isVideo == true ? message.snapshotUrl : message.thumnailImageUrl
            var url: URL? = nil
            if let path = imagePath, FileManager.default.fileExists(atPath: path) {
                url = URL(fileURLWithPath: path)
            } else {
                url = URL(string: imageUrl ?? "")
            }
            replyMessageThumnailImageView.sd_setImage(with: url, placeholderImage: UIImage.set("empty"))
            
            let muString: NSMutableAttributedString = NSMutableAttributedString()
            
            let attach: NSTextAttachment = NSTextAttachment()
            attach.bounds = isVideo ? CGRectMake(0, -2, 14.5, 10) : CGRectMake(0, -2, 12, 12)
            attach.image = UIImage.set(isVideo ? "conv_reply_msg_video_icon" : "conv_reply_msg_image_icon")
            muString.append(NSAttributedString(attachment: attach))
            
            let text = isVideo ? " Video" : " Foto"
            let attributeDict: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11),
                .foregroundColor: UIColor(hexString: "#48494F")
            ]
            let string = NSAttributedString(string: text, attributes: attributeDict)
            muString.append(string)
            replyMessageDetailTextLabel.attributedText = muString
        } else {
            replyMessageDetailTextLabel.text = message.text ?? ""
        }
        inputMessageTextView.becomeFirstResponder()
    }
    
    private func forwardMessage(_ message: TXIMMessage?) {
        guard let message, let index = messageList.firstIndex(where: { $0.msgID == message.msgID }) else {
            return
        }
        enableMultipleSelection(delete: false)
        tableView.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .none)
        selectedMessageChanged(message, add: true)
    }
    
    private func copyMessage(_ message: TXIMMessage?) {
        guard let message else {
            return
        }
        if let text = message.text {
            UIPasteboard.general.string = text
        }
    }
    
    private func revokeMessage(_ message: TXIMMessage?) {
        guard let message else {
            return
        }
        delegate?.didTapRevokeMessage(with: message)
    }
    
    private func deleteMessage(_ message: TXIMMessage?) {
        guard let message, let index = messageList.firstIndex(where: { $0.msgID == message.msgID }) else {
            return
        }
        enableMultipleSelection(delete: true)
        tableView.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .none)
        selectedMessageChanged(message, add: true)
    }
}

extension ConversationView: ConversationTextCellDelegate, ConversationMediaCellDelegate, ConversationRevokeCellDelegate {
    func didLongPress(with cell: ConversationTextCell, message: TXIMMessage, indexPath: IndexPath) {
        if !ConversationMenuWindow.instance.isHidden {
            return
        }
        
        self.allowDismissKeyboard = true
        self.endEditing(true)
        let pointInSuperview = cell.contentView.convert(cell.bubbleView.frame.origin, to: self.superview)
        let type = self.showDiamondIncreaseOrCoinDecrease(at: indexPath.row)
        ConversationMenuWindow.showCell(at: pointInSuperview, message: message, priceType: type, delegate: self)
    }
    
    func didLongPress(with cell:  ConversationMediaCell, message: TXIMMessage, indexPath: IndexPath) {
        if !ConversationMenuWindow.instance.isHidden {
            return
        }
        
        self.allowDismissKeyboard = true
        self.endEditing(true)
        let pointInSuperview = cell.contentView.convert(cell.bubbleView.frame.origin, to: self.superview)
        let type = self.showDiamondIncreaseOrCoinDecrease(at: indexPath.row)
        ConversationMenuWindow.showCell(at: pointInSuperview, message: message, priceType: type, delegate: self)
    }
    
    func didReEdit(with cell: ConversationRevokeCell, message: TXIMMessage) {
        inputMessageTextView.text = message.text
        inputMessageTextView.becomeFirstResponder()
        isTyping = !inputMessageTextView.text.isEmpty
        textViewDidChange(inputMessageTextView)
    }
}
