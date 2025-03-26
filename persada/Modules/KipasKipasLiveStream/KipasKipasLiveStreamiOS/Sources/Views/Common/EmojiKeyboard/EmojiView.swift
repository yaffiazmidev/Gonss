import UIKit
import Combine

let row: Int = 12
let col: Int = 7

let screenWidth = UIScreen.main.bounds.size.width


class EmojiView: UIView {
    private var cancellables: Set<AnyCancellable> = []
     
    var emojiBlock: ((EmojiModel)->Void)?
    
    var deleteBlock: (()->Void)?
     
    lazy var emojiManager: EmojiManager = {
       let manager = EmojiManager.shared
        return manager
    }()
    
    lazy var collectionView: UICollectionView = {[unowned self] in
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: EmojiFlowLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")
        collectionView.backgroundColor = UIColor(red: 246/255.0, green: 246/255.0, blue: 246/255.0, alpha:1)
        return collectionView
    }()
      
    init(frame: CGRect,selectedEmoji:((EmojiModel)->Void)?) {
        super.init(frame: frame)
        emojiBlock = selectedEmoji
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupUI(){
        
        let width = UIScreen.main.bounds.size.width/CGFloat(col)
        let height = width*CGFloat(row)
    
        addSubview(collectionView)
        collectionView.anchors.top.pin()
        collectionView.anchors.leading.pin()
        collectionView.anchors.trailing.pin()
        collectionView.anchors.height.equal(height)
        collectionView.anchors.bottom.pin(inset: 20)
          
    }
     
//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        let view = super.hitTest(point, with: event)
//        if view == nil {
//            for subview in deleteBtn.subviews {
//                for v in subview.subviews{
//                    let myPoint = v.convert(point, from: self)
//                    if v.bounds.contains(myPoint){
//                        return v
//                    }
//                }
//            }
//        }
//
//        return view;
//    }
}

extension EmojiView: UICollectionViewDelegate,UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return emojiManager.emojiPackages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let emojiPackage = emojiManager.emojiPackages[section]
        return emojiPackage.emojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as! EmojiCell
        let emojiPackage = emojiManager.emojiPackages[indexPath.section]
        let model = emojiPackage.emojis[indexPath.row]
        cell.model = model
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let emojiPackage = emojiManager.emojiPackages[indexPath.section]
        let model = emojiPackage.emojis[indexPath.row]
        emojiBlock?(model)
    }
     
}

class EmojiFlowLayout: UICollectionViewFlowLayout {
    
    var attributesArr: [UICollectionViewLayoutAttributes] = []
    var lastPage: Int = 0

    override func prepare() {
        super.prepare()
         
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        scrollDirection = .vertical //.horizontal
        let width = screenWidth/CGFloat(col)
        itemSize = CGSize(width: width, height: width)
        let bmHeight = collectionView!.bounds.size.height - width*CGFloat(row)
//        sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: bmHeight, right: 0)
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.showsHorizontalScrollIndicator = false
        
        var page = 0
        let section = collectionView?.numberOfSections ?? 0
        lastPage = 0
        for i in 0..<section {
             
            let count = collectionView?.numberOfItems(inSection: i) ?? 0
            for index in 0..<count{
                let indexPath = IndexPath(row: index, section: i)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                 
                page = index / (row*col) + lastPage
                
                let r = index/col%row
                
                let c = index%col
                
//                print("r = \(r) ----> c = \(c) ----> page = \(page)")
                
                let x = CGFloat(page)*screenWidth + CGFloat(c)*width
                let y = CGFloat(r)*width
                
                attributes.frame = CGRect(x: x, y: y, width: width, height: width)
                
                attributesArr.append(attributes)
//                print(attributes)
            }
            lastPage = lastPage + count/(row*col)
        }
    }
    
    override var collectionViewContentSize: CGSize{
        let size: CGSize = super.collectionViewContentSize
        return CGSize(width: CGFloat(lastPage)*screenWidth, height: size.height)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.attributesArr
    }
}

class EmojiCell: UICollectionViewCell {
    
    var model: EmojiModel? {
        didSet{
            emojiBtn.setImage(UIImage(contentsOfFile: model?.pngPath ?? ""), for: .normal)
            emojiBtn.setTitle(model?.emojiCode, for: .normal)
            if  let model = model {
                if model.isDelete{
                    emojiBtn.setImage(UIImage(contentsOfFile: EmojiManager.shared.deletePath ?? ""), for: .normal)
                }
                if model.isSpace{
                }
            }
        }
    }
    
    lazy var emojiBtn: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        button.isUserInteractionEnabled = false

        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupUI(){
        contentView.addSubview(emojiBtn)
        emojiBtn.anchors.edges.pin()
    }
}

