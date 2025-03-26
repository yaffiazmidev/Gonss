import UIKit
import KipasKipasShared

enum KKShareSection: CaseIterable {
    case first
    case second
    case third
}

enum KKSharedViewItem: Hashable {
    case firstSection(KKShareItem)
    case secondSection(KKShareSocmedItem)
    case thirdSEction(KKShareMenuItem)
}

struct KKShareItem: Hashable {
    let id: String
    let name: String
    let image: String
}

struct KKShareMenuItem: Hashable {
    let name: String
    let image: String
}

struct KKShareSocmedItem: Hashable {
    let name: String
    let image: String
}

class KKShareView: UIView {
    
    var dummyData1: [KKShareItem] = [
//        KKShareItem(id: "", name: "Add to Story", image: "imgPerson2"),
//        KKShareItem(id: "", name: "Winorlose", image: "imgPerson3"),
//        KKShareItem(id: "", name: "User8765", image: "imgPerson1"),
//        KKShareItem(id: "", name: "User098", image: "imgCouple"),
//        KKShareItem(id: "", name: "User0982", image: "imgPerson4"),
//        KKShareItem(id: "", name: "User0981", image: "imgPerson5"),
//        KKShareItem(id: "", name: "More", image: "ic_more"),
    ]
    
    var dummyData2 = [
//        KKShareSocmedItem(name: "Report", image: "ic_report"),
        KKShareSocmedItem(name: "Copy Link", image: "ic_noInter")

//        KKShareSocmedItem(name: "Instagram", image: "ic_instag"),
//        KKShareSocmedItem(name: "Stories", image: "ic_story"),
//        KKShareSocmedItem(name: "SMS", image: "ic_message"),
//        KKShareSocmedItem(name: "Email", image: "ic_email"),
//        KKShareSocmedItem(name: "Facebook", image: "ic_fb"),
//        KKShareSocmedItem(name: "More", image: "ic_more"),
    ]
    
    var dummyData3: [KKShareMenuItem] = [
//        KKShareMenuItem(name: "Report", image: "ic_reportGrey"),
//        KKShareMenuItem(name: "Not interested", image: "ic_heart_crack_solid_black"),
//        KKShareMenuItem(name: "Save video", image: "ic_download"),
//        KKShareMenuItem(name: "Why this video", image: "ic_pipblack"),
//        KKShareMenuItem(name: "Promote", image: "ic_pip5"),
//        KKShareMenuItem(name: "Turn off captions", image: "ic_fire_black"),
//        KKShareMenuItem(name: "Duet", image: "ic_pip"),
//        KKShareMenuItem(name: "Stitch", image: "ic_pip2"),
//        KKShareMenuItem(name: "Create sticker", image: "ic_pip3"),
//        KKShareMenuItem(name: "Live Photoe", image: "ic_pip4"),
//        KKShareMenuItem(name: "Share as GIF", image: "ic_gif")
    ]
    
    private(set) var collectionView: UICollectionView!
    var sections: [KKShareSection] = [.first, .second, .third]
    private(set) var dataSource: UICollectionViewDiffableDataSource<KKShareSection, KKSharedViewItem>! // retain data source!
    private(set) var containerView: UIView!
    private(set) var backgroundView: UIView!
    private(set) var headStackView: UIStackView!
    private(set) var titleLabel: UILabel!
    private(set) var closeButton: UIButton!
    var handleClose: (() -> Void)?
    
    
    
    lazy var customSendToUserView: KKShareSendToUserView = {
        let view = KKShareSendToUserView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var followings: [RemoteFollowingContent] = [] {
        didSet {
            dummyData1 = followings.compactMap({ KKShareItem(id: $0.id ?? "", name: $0.name ?? "", image: $0.photo ?? "") })
            updateSnapshot(animated: true)
        }
    }
    
    var item: CustomShareItem? {
        didSet {
            guard let item = item else { return }
            if getIdUser() == item.accountId {
                if item.type != .live {
                    dummyData3.append(KKShareMenuItem(name: "Delete", image: "ic_trashCan_solid_black"))
                }
            } else if item.type != .story {
                dummyData3.append(KKShareMenuItem(name: "Report", image: "ic_reportGrey"))
            }
            if(item.type != .live){
                dummyData3.append(KKShareMenuItem(name: "Save \(KKMediaItemExtension.isVideo(item.assetUrl) ? "video" : "photo")", image: "ic_download"))
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContainerView()
        setupHeaderView()
        addCollectionView()
        configureCollectionView()
        checkAlreadyInstallShareApps()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func checkAlreadyInstallShareApps() {
        let isAlreadyInstallInstagram = UIApplication.shared.canOpenURL(URL(string: "instagram://sharesheet")!)
        let isAlreadyInstallWhatsapp = UIApplication.shared.canOpenURL(URL(string: "whatsapp://app")!)
        if isAlreadyInstallInstagram {
            dummyData2.append(KKShareSocmedItem(name: "Instagram Direct Message", image: "ic_instagDiag"))
        }
        
        if isAlreadyInstallWhatsapp {
            dummyData2.append(KKShareSocmedItem(name: "Whatsapp", image: "iconWhatsapp"))
        }
        
        updateSnapshot(animated: true)
    }
    
    func addRepostOption() {
        dummyData2.insert(KKShareSocmedItem(name: "Repost", image: "iconRepost"), at: 0)
        updateSnapshot(animated: true)
    }
    
    func setupHeaderView() {
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .roboto(.medium, size: 13)
        titleLabel.text = "Send to"
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        closeButton = UIButton()
        let imgButton = UIImage(named: .get(.iconClose))?.withTintColor(.black)
        closeButton.setImage(imgButton, for: .normal)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(handleWhenTappedClose), for: .touchUpInside)
        closeButton.tintColor = .black
        
        headStackView = UIStackView(arrangedSubviews: [titleLabel])
        headStackView.translatesAutoresizingMaskIntoConstraints = false
        headStackView.distribution = .fill
        headStackView.alignment = .center
        headStackView.axis = .horizontal
        
        headStackView.addSubview(closeButton)
        closeButton.heightAnchor.constraint(equalToConstant: 16).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 16).isActive = true
        closeButton.topAnchor.constraint(equalTo: headStackView.topAnchor).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: headStackView.trailingAnchor, constant: -10).isActive = true
        
        containerView.addSubview(headStackView)
        headStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10).isActive = true
        headStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        headStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        headStackView.heightAnchor.constraint(equalToConstant: 16).isActive = true
    }
    
    func setupContainerView() {
        containerView = UIView()
        containerView.backgroundColor = .white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.cornerRadius = 14
        UIFont.loadCustomFonts
        
        addSubview(containerView)
        containerView.heightAnchor.constraint(equalToConstant: 364).isActive = true
        containerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        backgroundView = UIView()
        backgroundView.backgroundColor = .clear
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundView)
        backgroundView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
    }
    
    func addCollectionView() {
        let layout = createContentLayout()
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = false
        collectionView.bounces = false
        collectionView.alwaysBounceHorizontal = false
        collectionView.bouncesZoom = false
        collectionView.isDirectionalLockEnabled = true
        collectionView.isScrollEnabled = false
        collectionView.contentInset.top = 12
        containerView.addSubview(collectionView)
        
        collectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: headStackView.safeAreaLayoutGuide.bottomAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        
//        containerView.addSubview(customSendToUserView)
//        customSendToUserView.topAnchor.constraint(equalTo: headStackView.safeAreaLayoutGuide.bottomAnchor).isActive = true
//        customSendToUserView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
//        customSendToUserView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
//        customSendToUserView.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: 4).isActive = true
//        containerView.layoutIfNeeded()
        
    }
    
    func configureCollectionView() {
        collectionView.register(KKShareViewCell.self, forCellWithReuseIdentifier: "cellId")
        collectionView.register(KKShareFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "KKShareFooterView")
        configureDiffableDataSource()
    }
    
    @objc func handleWhenTappedClose() {
        self.handleClose?()
    }
    
}

// MARK: - Collection View Layout -

private extension KKShareView {
    
    private func createContentLayout() -> UICollectionViewCompositionalLayout {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.interSectionSpacing = 10
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { [weak self] (sectionIndex: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            guard let self = self else { return nil }
            
            var itemSection = self.makeItemSectionDeclaration(environment: environment)
            
            if sectionIndex == 0  {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let width: CGFloat = 64
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(followings.isEmpty ? 0 : width),
                                                       heightDimension: .absolute(followings.isEmpty ? 0 : 93))
                let group: NSCollectionLayoutGroup
                if #available(iOS 16.0, *) {
                    group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)
                } else {
                    group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
                }
                
                group.interItemSpacing = NSCollectionLayoutSpacing.fixed(20)
                
                let footerSection = self.makeFooterSectionDeclaration(environment: environment)
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
                
                if !followings.isEmpty {
                    section.boundarySupplementaryItems = [footerSection.footer]
                }
                section.interGroupSpacing = 6
                section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
                
                return section
            }
            
            let footerSection = self.makeFooterSectionDeclaration(environment: environment)
            let section = NSCollectionLayoutSection(group: itemSection.group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
            section.boundarySupplementaryItems = [footerSection.footer]
            section.interGroupSpacing = 6
            section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
            
            return section
            
        }, configuration: configuration)
        return layout
    }

    func makeItemSectionDeclaration(environment: NSCollectionLayoutEnvironment) -> (group: NSCollectionLayoutGroup, itemSize: NSCollectionLayoutSize) {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let width: CGFloat = 64
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(width),
                                               heightDimension: .absolute(93))
        let group: NSCollectionLayoutGroup
        if #available(iOS 16.0, *) {
            group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)
        } else {
            group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        }
        
        group.interItemSpacing = NSCollectionLayoutSpacing.fixed(20)
        
        return (group, itemSize)
    }

    func makeFooterSectionDeclaration(environment: NSCollectionLayoutEnvironment) -> (footer: NSCollectionLayoutBoundarySupplementaryItem, footerSize: NSCollectionLayoutSize) {
        let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .absolute(1))
        let footer = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: footerSize,
            elementKind: UICollectionView.elementKindSectionFooter,
            alignment: .bottom
        )
        footer.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: -10, bottom: 0, trailing: -10)
        return (footer, footerSize)
    }

}

// MARK: - Collection View DataSource -

private extension KKShareView {

    func configureDiffableDataSource() {
        
        let dataSource = UICollectionViewDiffableDataSource<KKShareSection, KKSharedViewItem>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, item: KKSharedViewItem) -> UICollectionViewCell? in
            
            switch item {
            case .firstSection(let item):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! KKShareViewCell
                cell.fillWithData(item.name, url: item.image, isSelf: item.id == getIdUser())
                return cell
                
            case .secondSection(let item):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! KKShareViewCell
                cell.fillWithData(item.name, asset: item.image)
                return cell
                
            case .thirdSEction(let item):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! KKShareViewCell
                cell.fillWithData(item.name, asset: item.image)
                return cell
            }
        }
        
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            switch kind {
            case UICollectionView.elementKindSectionFooter:
                let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "KKShareFooterView", for: indexPath) as! KKShareFooterView
                if indexPath.section == 0 {
                    footer.isHidden = false
                } else {
                    footer.isHidden = true
                }
                return footer
            default:
                fatalError("Header/Footer not found")
            }
        }
        self.dataSource = dataSource

        updateSnapshot(animated: false)
    }
    
    func updateSnapshot(animated: Bool = true) {
        
        var snapshot = NSDiffableDataSourceSnapshot<KKShareSection, KKSharedViewItem>()

        snapshot.appendSections([.first])
        snapshot.appendItems(dummyData1.map { KKSharedViewItem.firstSection($0) })
        
        snapshot.appendSections([.second])
        snapshot.appendItems(dummyData2.map { KKSharedViewItem.secondSection($0) })
        
        snapshot.appendSections([.third])
        snapshot.appendItems(dummyData3.map { KKSharedViewItem.thirdSEction($0) })
        
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
}

