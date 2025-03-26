import UIKit

class EmojiInputView: UIControl {
 
    var emojiReturnBlock: ((String)->Void)?
    var viewHeightBlock: ((CGFloat)->Void)?
    
     
    var textFont: UIFont = .systemFont(ofSize: 14){
        didSet{
            textView.font = textFont
            placeHolderLabel.font = textFont
        }
    }
    
   
    var textColor: UIColor = .black {
        didSet{
            textView.textColor = textColor
        }
    }
    
     
    var placeHolder: String? {
        didSet{
            placeHolderLabel.text = placeHolder
        }
    }
    
    
    var placeHolderColor: UIColor = .gray {
        didSet{
            placeHolderLabel.textColor = placeHolderColor
        }
    }
    
   
    private let keyBoardDefaultHeight: CGFloat = 30
    private let keyBoardMaxheight: CGFloat = 60
    private let emojiViewHeight: CGFloat = 336  
    
    
    private var last: CGFloat = 30
    
    public lazy var bgView: UIView = {
        let bgView = UIView()
        bgView.layer.cornerRadius = 15
        bgView.layer.masksToBounds = true
        bgView.layer.borderWidth = 1
        bgView.layer.borderColor = UIColor.gainsboro.cgColor
        bgView.backgroundColor = .white
        bgView.layer.masksToBounds = true
        return bgView
    }()
    
    public lazy var textView: UITextView = {
        let textView = UITextView()
        textView.delegate = self
        textView.showsHorizontalScrollIndicator = false
        textView.showsVerticalScrollIndicator = false
        textView.isScrollEnabled = false
        textView.font = .roboto(.regular, size: 14)
        textView.textColor = .gravel
        textView.layoutManager.allowsNonContiguousLayout = false
        textView.returnKeyType = .send
        textView.backgroundColor = .clear
        return textView
    }()
    
    public lazy var placeHolderLabel: UILabel = {
        let label = UILabel()
        label.font = textView.font
        label.textColor = UIColor.gray
        return label
    }()
    
    public lazy var emojiBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(.iconLaugh, for: .normal)
        btn.setImage(.iconVector, for: .selected)
        btn.addTarget(self, action: #selector(keyboardExchange(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var sendBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(.iconSendNormal, for: .normal)
        btn.setImage(.iconSend, for: .disabled)
        btn.isEnabled = false
        btn.addTarget(self, action: #selector(sendEmojiContent), for: .touchUpInside)
        return btn
    }()

    private lazy var emojiView: EmojiView = {
        let size = UIScreen.main.bounds.size
        let v = EmojiView(frame: CGRect(x: 0, y: 0, width: size.width, height: emojiViewHeight)){ [weak self] model in
            self?.showEmojiText(emojModel: model)
        }
        v.backgroundColor = UIColor.init(hexString: "#F6F6F6") 
        v.deleteBlock = {
            self.textView.deleteBackward()
        }
        return v
    }()
    
    init(frame: CGRect, emojiReturn: ((String)->Void)?) {
        super.init(frame: frame)
        emojiReturnBlock = emojiReturn
        setupUI()
    }
    
    override init(frame: CGRect) {
            super.init(frame: frame)
            setupUI()
        }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setup(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(_:)), name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(_:)), name: UIResponder.keyboardWillHideNotification , object: nil)
    }
    
    private func setupUI(){
         
        setup()
        backgroundColor = UIColor(red: 246/255.0, green: 246/255.0, blue: 246/255.0, alpha:1)
        
        addSubview(bgView)
        addSubview(textView)
        addSubview(emojiBtn)
        addSubview(sendBtn)
        
        let bottomView = UIView()
        bottomView.backgroundColor = UIColor.init(hexString: "#F6F6F6")
        addSubview(bottomView)
        bottomView.anchors.leading.pin()
        bottomView.anchors.trailing.pin()
        bottomView.anchors.bottom.pin(inset: -emojiViewHeight)
        bottomView.anchors.height.equal(emojiViewHeight)
         
        
        addSubview(emojiView)
        textView.addSubview(placeHolderLabel)
        
        
        bgView.anchors.leading.pin(inset: 15)
        bgView.anchors.bottom.pin(inset: 5)
        bgView.anchors.top.pin(inset: 5)
        
        //textView 
        textView.anchors.bottom.pin(inset: 5)
        textView.anchors.top.pin(inset: 5)
        textView.anchors.height.greaterThanOrEqual(keyBoardDefaultHeight)
        textView.anchors.height.lessThanOrEqual(keyBoardMaxheight)
        
        textView.anchors.leading.equal(bgView.anchors.leading, constant: 10)
        textView.anchors.trailing.equal(bgView.anchors.trailing, constant: -20-10)
         
        
        placeHolderLabel.anchors.leading.equal(textView.anchors.leading, constant: textView.textContainer.lineFragmentPadding)
        placeHolderLabel.anchors.centerY.align()
        placeHolderLabel.anchors.height.equal(keyBoardDefaultHeight)
    
        //emojiBtn
        emojiBtn.anchors.trailing.equal(bgView.anchors.trailing, constant: -8)
        emojiBtn.anchors.bottom.pin(inset: 5)
        emojiBtn.anchors.size.equal(CGSize(width: 30, height: 30))
        
        //sendBtn
        sendBtn.anchors.leading.equal(bgView.anchors.trailing, constant: 10)
        sendBtn.anchors.bottom.pin(inset: 5)
        sendBtn.anchors.size.equal(CGSize(width: 30, height: 30))
        sendBtn.anchors.trailing.pin(inset: 10)
        
        emojiView.anchors.leading.pin()
        emojiView.anchors.trailing.pin()
        emojiView.anchors.bottom.pin(inset: -emojiViewHeight)
        emojiView.anchors.height.equal(emojiViewHeight)
         
        let topLine = UIView()
        topLine.backgroundColor = UIColor.lightGray
        addSubview(topLine)
        topLine.anchors.leading.pin()
        topLine.anchors.trailing.pin()
        topLine.anchors.top.pin( )
        topLine.anchors.height.equal(0.3)
        
        let bmLine = UIView()
        bmLine.backgroundColor = UIColor.lightGray
        addSubview(bmLine)
        bmLine.anchors.leading.pin()
        bmLine.anchors.trailing.pin()
        bmLine.anchors.bottom.pin( )
        bmLine.anchors.height.equal(0.3)
        
         
    }
    
    //MARK:-
    private func showEmojiText(emojModel: EmojiModel){
        
        if emojModel.isDelete{
            self.textView.deleteBackward()
            return
        }
      
        if emojModel.isSpace{
            return
        }
        
        if emojModel.emojiCode != nil {
          
            let textRange = textView.selectedTextRange
            textView.replace(textRange!, withText: emojModel.emojiCode!)
            return
        }
    
        let font = textView.font!
        let range = textView.selectedRange
        if emojModel.pngPath != nil {
            let attr = NSMutableAttributedString(attributedString: textView.attributedText)
            let attach = EmojiAttachment()
            attach.chs = emojModel.chs
            attach.image = UIImage(contentsOfFile: emojModel.pngPath!)
            attach.bounds = CGRect(x: 0, y: -4, width: font.lineHeight, height: font.lineHeight)
            
            attr.replaceCharacters(in: range, with: NSAttributedString(attachment: attach))
            textView.attributedText = attr
        }
        
        textView.font = font
        
       
        textView.selectedRange = NSRange(location: range.location+1, length: 0)
        
//        _ = textView(textView, shouldChangeTextIn: range, replacementText: "")
         
        textViewDidChange(textView)
    }
    
     
    @objc private func keyboardExchange(_ btn: UIButton){
        btn.isSelected = !btn.isSelected
     
        if textView.isFirstResponder{
            textView.resignFirstResponder()
        }
        if btn.isSelected {
            UIView.animate(withDuration: 0.25) {
                self.viewHeightBlock?(-self.emojiViewHeight-self.keyBoardMaxheight)
                self.transform = CGAffineTransform(translationX: 0, y: -self.emojiViewHeight)
                self.emojiView.transform = CGAffineTransform(translationX: 0, y: 0)
            }
        }else{
            textView.becomeFirstResponder()
        }
    }
    
   
    @objc private func sendEmojiContent(){
        
        let attr = NSMutableAttributedString(attributedString: textView.attributedText)
        
        if attr.length == 0 {
            return
        }
        
        attr.enumerateAttributes(in: NSRange(location: 0, length: textView.attributedText.length), options: []) { (dict, range, _) in
            
            if let attach = dict[NSAttributedString.Key.init(rawValue: "NSAttachment")] as? EmojiAttachment {
                attr.replaceCharacters(in: range, with: attach.chs!)
            }
        }
        
        emojiReturnBlock?(attr.string)
        textView.text = ""
        textViewDidChange(textView)
    }
    
     
    @objc func keyBoardWillShow(_ noti: Notification){
        
        let info = noti.userInfo
        let rect = (info?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let changeY = rect.size.height
        let duration = info?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        viewHeightBlock?(-changeY-keyBoardMaxheight)
        UIView.animate(withDuration: duration) {
            self.transform = CGAffineTransform(translationX: 0, y: -changeY)
        }
        if !emojiBtn.isSelected{
            UIView.animate(withDuration: duration) {
                self.emojiView.transform = CGAffineTransform(translationX: 0, y: changeY)
            }
        }
    }
     
    @objc func keyBoardWillHide(_ noti: Notification){
        let info = noti.userInfo
         
        let duration = info?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        viewHeightBlock?(-self.emojiViewHeight)
        UIView.animate(withDuration: duration) {
            self.viewHeightBlock?(-self.keyBoardMaxheight)
            self.transform = CGAffineTransform.identity
        }
        if emojiBtn.isSelected{
            UIView.animate(withDuration: duration) {
                self.viewHeightBlock?(-self.emojiViewHeight-self.keyBoardMaxheight)
                self.transform = CGAffineTransform(translationX: 0, y: -self.emojiViewHeight)
                self.emojiView.transform = CGAffineTransform.identity
            }
        }
    }
    
     
    func closeEmojikeyBoard(){
        if textView.isFirstResponder{
            textView.resignFirstResponder()
        }
        if emojiBtn.isSelected {
            UIView.animate(withDuration: 0.25) {
                self.transform = CGAffineTransform.identity
                self.emojiView.transform = CGAffineTransform.identity
            }
        }
        emojiBtn.isSelected = false
    }
     
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view == nil {
            for subview in emojiView.subviews {
                for v in subview.subviews{
                    let myPoint = v.convert(point, from: self)
                    if v.bounds.contains(myPoint){
                        return v
                    }
                }
            }
        }

        return view;
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension EmojiInputView: UITextViewDelegate{
   
    func textViewDidChange(_ textView: UITextView) {
        let height = textHeight()
        if textHeight() <= keyBoardMaxheight {
            textView.isScrollEnabled = false
        }else{
            textView.isScrollEnabled = true
        }
        if height != last {
            last = height
            textView.setNeedsUpdateConstraints()
            if textView.isScrollEnabled{
                textView.scrollRangeToVisible(NSRange(location: textView.attributedText.length, length: 1))
            }
        }
        placeHolderLabel.isHidden = textView.text.count > 0
        sendBtn.isEnabled = textView.text.count > 0
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            sendEmojiContent()
            return false
        }
        return true
    }

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if emojiBtn.isSelected {
            emojiBtn.isSelected = true
            keyboardExchange(emojiBtn)
        }
        return true
    }
    
    
    private func textHeight() ->  CGFloat{
        let rect = textView.attributedText.boundingRect(with: CGSize(width: textView.bounds.size.width - textView.textContainer.lineFragmentPadding*2, height: CGFloat.greatestFiniteMagnitude) , options: .usesLineFragmentOrigin, context: nil)
        return rect.height + textView.textContainerInset.top*2
    }
    
    
    public func changeTextStr(_ str:String){
        guard str.count > 0  else { return }
        self.textView.text = str
        self.placeHolderLabel.isHidden = true
        self.textViewDidChange(self.textView)
    }
    
}
