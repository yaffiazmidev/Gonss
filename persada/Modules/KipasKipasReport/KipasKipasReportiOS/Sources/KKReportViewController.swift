import UIKit
import KipasKipasReport
import KipasKipasShared
import Combine

public final class KKReportViewController: UICollectionViewController {
    
    private let submitReportButton = UIButton()
    
    private lazy var dataSource = makeDataSource()
    
    private let targetReportedId: String
    private let reportKind: ReportKind
    private let reasonLoader: ReportReasonLoader
    private let reportSubmissionLoader: ReportSubmissionLoader
    
    @Published var shouldShowReasonTextView: Bool = false
    @Published var selectedReason: ReportReason? = nil
    @Published var otherReasonTextViewValue: String = ""
    
    private var cancellables: Set<AnyCancellable> = []
    
    public var reportSubmissionCallback: (() -> Void)?
    
    public init(
        targetReportedId: String,
        reportKind: ReportKind,
        reasonLoader: ReportReasonLoader,
        reportSubmissionLoader: ReportSubmissionLoader
    ) {
        self.targetReportedId = targetReportedId
        self.reportKind = reportKind
        self.reasonLoader = MainQueueDispatchDecorator(decoratee: reasonLoader)
        self.reportSubmissionLoader = MainQueueDispatchDecorator(decoratee: reportSubmissionLoader)
        super.init(collectionViewLayout: UICollectionViewLayout())
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        return nil
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        loadReportReasons()
        observeState()
    }
    
    public override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cell(at: indexPath)?.select()
    }
    
    public override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        cell(at: indexPath)?.deselect()
    }
    
    private func observeState() {
        $shouldShowReasonTextView
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.collectionViewLayout.prepare()
                self?.collectionView.collectionViewLayout.invalidateLayout()
            }
            .store(in: &cancellables)
        
        $selectedReason
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.handleReportButtonAppearance()
            }
            .store(in: &cancellables)
        
        $otherReasonTextViewValue
            .receive(on: DispatchQueue.main)
            .sink { [weak self] otherReason in
                self?.selectedReason?.value = otherReason
                self?.handleReportButtonAppearance()
            }
            .store(in: &cancellables)
    }
    
    @objc private func submitButtonTapped() {
        guard let reason = selectedReason else { return }
        submitReportRequest(reason)
    }
}

extension KKReportViewController: ReportCellControllerDelegate {
    func didSelectReason(_ reason: ReportReason) {
        view.endEditing(true)
        selectedReason = reason
    }
}

extension KKReportViewController: KKTextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        otherReasonTextViewValue = textView.text
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        otherReasonTextViewValue = textView.text
    }
}

// MARK: UI
private extension KKReportViewController {
    func configureUI() {
        view.backgroundColor = .white
        
        addBottomSafeAreaPaddingView(height: 24)
        configureCollectionView()
        configureSubmitReportButton()
    }
    
    func configureCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.collectionViewLayout = makeLayout()
        collectionView.dataSource = dataSource
        collectionView.register(KKReportCell.self, forCellWithReuseIdentifier: KKReportCell.identifier)
        collectionView.register(KKReportHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: KKReportHeaderView.identifier)
        collectionView.register(KKReportFooterTextView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: KKReportFooterTextView.identifier)
        
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: KKReportHeaderView.identifier, for: indexPath) as! KKReportHeaderView
                header.questionLabel.text = self?.reportHeaderText
                return header
            case UICollectionView.elementKindSectionFooter:
                let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: KKReportFooterTextView.identifier, for: indexPath) as! KKReportFooterTextView
                footer.delegate = self
                return footer
            default:
                fatalError("Header/Footer not found")
            }
        }
    }
    
    func cell(at indexPath: IndexPath) -> CellController? {
        return dataSource.itemIdentifier(for: indexPath)
    }
    
    func configureSubmitReportButton() {
        submitReportButton.setTitle(reportButtonText, for: .normal)
        submitReportButton.titleLabel?.font = .roboto(.bold, size: 14)
        
        submitReportButton.backgroundColor = .watermelon
        submitReportButton.setTitleColor(.white, for: .normal)
        submitReportButton.layer.cornerRadius = 4
        submitReportButton.translatesAutoresizingMaskIntoConstraints = false
        submitReportButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        
        let hasBottomInset = safeAreaInsets.bottom > 0
        
        view.addSubview(submitReportButton)
        NSLayoutConstraint.activate([
            submitReportButton.heightAnchor.constraint(equalToConstant: 40),
            submitReportButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: hasBottomInset ? 0 : -24),
            submitReportButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            submitReportButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    func configureHeader(in section: NSCollectionLayoutSection) {
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(100)
            ),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
    }
    
    func configureReasonTextView(in section: NSCollectionLayoutSection) {
        guard shouldShowReasonTextView else { return }
        
        let footer = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(120)
            ),
            elementKind: UICollectionView.elementKindSectionFooter,
            alignment: .bottom
        )
        footer.contentInsets.top = 20
        section.boundarySupplementaryItems += [footer]
    }
    
    func handleReportButtonAppearance() {
        
        func disableButton() {
            submitReportButton.backgroundColor = .softPeach
            submitReportButton.isEnabled = false
        }
        
        guard let reason = selectedReason else {
            return disableButton()
        }
        
        let whenOtherReasonSelected = reason.isOtherType
        let reasonNotInputted = otherReasonTextViewValue.isEmpty
        
        shouldShowReasonTextView = whenOtherReasonSelected
        submitReportButton.backgroundColor = whenOtherReasonSelected && reasonNotInputted ? .softPeach : .watermelon
        submitReportButton.isEnabled = whenOtherReasonSelected && reasonNotInputted ? false : true
    }
}

// MARK: DataSource
private extension KKReportViewController {
    func makeDataSource() -> UICollectionViewDiffableDataSource<Int, CellController> {
        return .init(collectionView: collectionView) { collectionView, indexPath, controller in
            return controller.view(collectionView, forItemAt: indexPath)
        }
    }
    
    func configureDataSource(_ reasons: [CellController]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, CellController>()
        snapshot.deleteAllItems()
        snapshot.appendSections([0])
        snapshot.appendItems(reasons)
        dataSource.apply(snapshot)
    }
    
    func loadReportReasons() {
        reasonLoader.fetch(reportKind) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(data):
                self.configureDataSource(data.reasons.map {
                    return KKReportCellController(item: $0, delegate: self)
                })
            case let .failure(error):
                // TODO: Handle error
                print(error)
            }
        }
    }
    
    func submitReportRequest(_ reason: ReportReason) {
        reportSubmissionLoader.submit(.init(
            reasonReport: reason,
            type: reportKind.rawValue,
            targetReportedId: targetReportedId
        )) { [weak self] _  in self?.reportSubmissionCallback?() }
    }
}

// MARK: Layout
private extension KKReportViewController {
    func makeLayout() -> UICollectionViewCompositionalLayout {
        return .init { [weak self] _ , _ in
            let section = NSCollectionLayoutSection.reportReasonSection
            self?.configureHeader(in: section)
            self?.configureReasonTextView(in: section)
            
            return section
        }
    }
}

// TODO: Need to test this
private extension KKReportViewController {
    var reportButtonText: String {
        switch reportKind {
        case .FEED:
            return "Lapor & Sembunyikan Postingan"
        default:
            return "Laporkan"
        }
    }
    
    var reportHeaderText: String {
        switch reportKind {
        case .FEED:
            return "Mengapa anda ingin melaporkan postingan ini?"
        default:
            return "Mengapa anda ingin melaporkan komentar ini?"
        }
    }
}

extension MainQueueDispatchDecorator: ReportReasonLoader where T == ReportReasonLoader {
    public func fetch(_ reportType: ReportKind, completion: @escaping (ReportReasonLoader.Result) -> Void) {
        decoratee.fetch(reportType, completion: { [weak self] result in
            self?.dispatch { completion(result) }
        })
    }
}

extension MainQueueDispatchDecorator: ReportSubmissionLoader where T == ReportSubmissionLoader {
    public func submit(_ req: ReportSubmissionRequest, completion: @escaping (ReportSubmissionLoader.Result) -> Void) {
        decoratee.submit(req) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
