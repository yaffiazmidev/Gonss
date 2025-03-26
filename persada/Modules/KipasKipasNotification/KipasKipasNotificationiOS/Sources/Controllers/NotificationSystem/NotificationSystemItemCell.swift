import UIKit
import KipasKipasShared

public class NotificationSystemItemCell: UICollectionViewCell {
   
    private let containerStack = UIStackView()
    private let headerStack = UIStackView()
    private let contentStack = UIStackView()
    private let footerStack = UIStackView()
    
    private(set) var imageHeaderView = UIImageView()
    private(set) var viewHeader = UIView()
    private(set) var headerLabel = UILabel()
    private(set) var elipsisButton = UIButton()
    
    private(set) var titleContentLabel = UILabel()
    private(set) var subtitleContentTextView = UILabel()
    private(set) var createdAtLabel = UILabel()
    
    private(set) var footerLabel = UILabel()
    private(set) var iconFooter = UIImageView()
    private(set) var redDotView = UIView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI () {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 4
        UIFont.loadCustomFonts
        configureContainerStack()
    }
    
    private func configureContainerStack() {
        contentView.addSubview(containerStack)
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        containerStack.axis = .vertical
        containerStack.alignment = .fill
        containerStack.distribution = .fill
        containerStack.spacing = 12
        containerStack.anchors.edges.pin(insets: 8)
        
        configureHeaderStack()
        configureContentStack()
        configureFooterStack()
    }
    
    private func configureHeaderStack() {
        containerStack.addArrangedSubview(headerStack)
        headerStack.axis = .horizontal
        headerStack.distribution = .fill
        headerStack.alignment = .fill
        headerStack.spacing = 10
        
        configureImageHeaderView()
        configureLabelHeaderView()
        configureElipsisButtonHeader()
    }
    
    private func configureImageHeaderView() {
        headerStack.addArrangedSubview(viewHeader)
        
        imageHeaderView.translatesAutoresizingMaskIntoConstraints = false
        imageHeaderView.image = .iconNewsPaperGray?.withTintColor(.black, renderingMode: .alwaysOriginal)
        viewHeader.backgroundColor = .whiteSmoke
        
        viewHeader.layer.cornerRadius = 27 / 2
        viewHeader.anchors.width.equal(27)
        viewHeader.anchors.height.equal(27)
        
        viewHeader.addSubview(imageHeaderView)
        imageHeaderView.anchors.width.equal(16)
        imageHeaderView.anchors.height.equal(16)
        imageHeaderView.anchors.centerX.equal(viewHeader.anchors.centerX)
        imageHeaderView.anchors.centerY.equal(viewHeader.anchors.centerY)
    }
    
    private func configureLabelHeaderView() {
        headerStack.addArrangedSubview(headerLabel)
        headerLabel.text = "Sosial"
        headerLabel.font = .roboto(.bold, size: 14)
        headerLabel.textColor = .contentGrey
    }
    
    private func configureElipsisButtonHeader() {
        headerStack.addArrangedSubview(elipsisButton)
        elipsisButton.translatesAutoresizingMaskIntoConstraints = false
        elipsisButton.setImage(.iconHorizontalElipsisGrey)
        elipsisButton.anchors.width.equal(27)
    }
    
    private func configureContentStack() {
        containerStack.addArrangedSubview(contentStack)
        contentStack.axis = .vertical
        contentStack.distribution = .fill
        contentStack.alignment = .fill
       
        let spacer = UIView()
        spacer.backgroundColor = .whiteSmoke
        contentStack.addSubview(spacer)
        spacer.anchors.height.equal(1)
        spacer.anchors.top.equal(contentStack.anchors.top)
        spacer.anchors.leading.equal(contentStack.anchors.leading)
        spacer.anchors.trailing.equal(contentStack.anchors.trailing)
        
        configureTitleContentStack()
        configureSubtitleContentStack()
        configureCreatedAtLabel()
    }
    
    private func configureTitleContentStack() {
        contentStack.addArrangedSubview(titleContentLabel)
        titleContentLabel.translatesAutoresizingMaskIntoConstraints = false
        titleContentLabel.text = "title testing aja dul"
        titleContentLabel.textColor = .black
        titleContentLabel.font = .roboto(.medium, size: 16)
        titleContentLabel.numberOfLines = 3
        titleContentLabel.anchors.height.equal(30)
        
        configureRedDoView()
    }
    
    private func configureSubtitleContentStack() {
        contentStack.addArrangedSubview(subtitleContentTextView)
        subtitleContentTextView.translatesAutoresizingMaskIntoConstraints = false
        subtitleContentTextView.text = "Saksikan keseruan Rossa, Weird Genius, Novia Bachmid dan kreator Kipaskipas LIVE langsung dari Garuda Wisnu Kencana, Bali  1/13"
        subtitleContentTextView.textColor = .contentGrey
        subtitleContentTextView.font = .roboto(.regular, size: 14)
        subtitleContentTextView.isUserInteractionEnabled = false
    }
    
    private func configureCreatedAtLabel() {
        contentStack.addArrangedSubview(createdAtLabel)
        createdAtLabel.translatesAutoresizingMaskIntoConstraints = false
        createdAtLabel.text = "1/13"
        createdAtLabel.textColor = .placeholder
        createdAtLabel.font = .roboto(.regular, size: 14)
        createdAtLabel.numberOfLines = 1
        createdAtLabel.anchors.height.equal(18)
    }
    
    private func configureFooterStack() {
        containerStack.addArrangedSubview(footerStack)
        footerStack.axis = .horizontal
        footerStack.distribution = .fill
        footerStack.alignment = .fill
        
        let spacer = UIView()
        spacer.backgroundColor = .whiteSmoke
        footerStack.addSubview(spacer)
        spacer.anchors.height.equal(1)
        spacer.anchors.top.equal(footerStack.anchors.top, constant: -4)
        spacer.anchors.leading.equal(footerStack.anchors.leading)
        spacer.anchors.trailing.equal(footerStack.anchors.trailing)
        
        configureFooterLabeltStack()
        configureIconFooter()
    }
    
    private func configureFooterLabeltStack() {
        footerStack.addArrangedSubview(footerLabel)
        footerLabel.translatesAutoresizingMaskIntoConstraints = false
        footerLabel.text = "Lihat selengkapnya"
        footerLabel.font = .roboto(.regular, size: 14)
        footerLabel.textColor = .contentGrey
        footerLabel.anchors.height.equal(27)
    }
    
    private func configureIconFooter() {
        footerStack.addArrangedSubview(iconFooter)
        iconFooter.image = UIImage(systemName: "chevron.right")?.withTintColor(.contentGrey, renderingMode: .alwaysOriginal)
        iconFooter.contentMode = .center
        iconFooter.anchors.width.equal(20)
    }
    
    private func configureRedDoView() {
        titleContentLabel.addSubview(redDotView)
        redDotView.backgroundColor = .warning
        redDotView.anchors.top.equal(titleContentLabel.anchors.top, constant: 20)
        redDotView.anchors.trailing.equal(titleContentLabel.anchors.trailing)
        redDotView.anchors.height.equal(8)
        redDotView.anchors.width.equal(8)
        redDotView.layer.cornerRadius = 4
    }
    
    func select() {
        contentView.backgroundColor = .water
    }
    
    func deselect() {
        contentView.backgroundColor = .white
    }
    
    func configure(types: String, title: String, description: String, isRead: Bool, epoch: Int = 0) {
        imageHeaderView.contentMode = .scaleAspectFit
        if types == "account" {
            imageHeaderView.image = .iconArrowUpGray
            headerLabel.text = "Akun Update"
        } else if types == "live" {
            imageHeaderView.image = .iconVideo
            headerLabel.text = types.uppercased()
        } else if types == "hotroom" {
            imageHeaderView.image = .iconNewsPaperGray
            headerLabel.text = "Sosial"
        }
 
        let validEpoch = epoch / 1000
        let date = Date(timeIntervalSince1970: TimeInterval(validEpoch))

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM"

        if title != "" {
            titleContentLabel.text = title
        } else  {
            titleContentLabel.text = description
        }
        
        subtitleContentTextView.text = description
        redDotView.isHidden = types != "account" || isRead
        createdAtLabel.text = dateFormatter.string(from: date)
    }
}


