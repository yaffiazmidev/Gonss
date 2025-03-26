import UIKit

public final class KKDropDownMenuViewController: UIViewController {
    
    private let transparentView = UIView()
    
    private lazy var tableViewContainer: UIView = {
        let containerView = UIView()
        let blurEffect = UIBlurEffect(style: .systemMaterialDark)
        
        let customBlurEffectView = CustomVisualEffectView(effect: blurEffect, intensity: 0.2)
        
        let dimmedView = UIView()
        dimmedView.backgroundColor = .black.withAlphaComponent(0.6)
        
        containerView.addSubview(customBlurEffectView)
        containerView.addSubview(dimmedView)
        return containerView
    }()
    
    private let tableView = UITableView()
    
    public var frames: CGRect = .zero {
        didSet {
            view.setNeedsLayout()
            view.layoutIfNeeded()
        }
    }
    
    public var center: CGPoint = .zero {
        didSet {
            view.setNeedsLayout()
            view.layoutIfNeeded()
        }
    }
    
    private let menus: [NSAttributedString]
    private let widthDimension: CGFloat
    private let heightDimension: CGFloat
    
    public var onSelectItem: (() -> Void)?
    
    public init(
        menus: [NSAttributedString],
        frames: CGRect,
        widthDimension: CGFloat,
        heightDimension: CGFloat = 154,
        center: CGPoint = .zero
    ) {
        self.menus = menus
        self.frames = frames
        self.widthDimension = widthDimension
        self.heightDimension = heightDimension
        self.center = center
        
        super.init(nibName: nil, bundle: nil)
    }
  
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        return nil
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        tableView.reloadData()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateFrames()
    }
    
    @objc private func onTapOutside() {
        onSelectItem?()
    }
}

// MARK: UI
private extension KKDropDownMenuViewController {
    func configureUI() {
        configureTransparentView()
        configureTableContainerView()
    }
    
    func configureTransparentView() {
        transparentView.backgroundColor = .clear
        transparentView.frame = view.bounds
        view.addSubview(transparentView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapOutside))
        transparentView.addGestureRecognizer(tapGesture)
    }
    
    func configureTableContainerView() {
        tableViewContainer.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        tableViewContainer.layer.cornerRadius = 12
        view.addSubview(tableViewContainer)
        
        configureTableView()
    }
    
    func updateFrames() {
        tableViewContainer.frame = CGRect(
            x: 0,
            y: frames.height + safeAreaInsets.top,
            width: widthDimension,
            height: heightDimension
        )
        tableViewContainer.center.x = center.x
        tableViewContainer.frame.size.height = heightDimension
    }
    
    func configureTableView() {
        tableView.backgroundColor = .clear
        tableView.rowHeight = 37
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerCell(DropDownCell.self)
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        
        tableViewContainer.addSubview(tableView)
        tableView.anchors.edges.pin()
    }
}

// MARK: Delegate
extension KKDropDownMenuViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        removeFromParentView()
        onSelectItem?()
    }
}

// MARK: DataSource
extension KKDropDownMenuViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        menus.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DropDownCell = tableView.dequeueReusableCell(at: indexPath)
        cell.menuLabel.attributedText = menus[indexPath.row]
        cell.lineView.isHidden = indexPath.row == menus.count - 1
        return cell
    }
}
