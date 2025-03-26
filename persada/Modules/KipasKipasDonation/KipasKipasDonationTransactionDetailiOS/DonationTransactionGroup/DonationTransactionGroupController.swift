import UIKit
import KipasKipasShared
import KipasKipasDonationTransactionDetail

public class DonationTransactionGroupController: UIViewController {
    private let mainView: DonationTransactionGroupView
    private var data: DonationTransactionDetailGroupItem
    
    public init(items: DonationTransactionDetailGroupItem) {
        self.mainView = DonationTransactionGroupView()
        self.data = items
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func loadView() {
        super.loadView()
        view = mainView
        configureTableView()
        configureAction()
    }
    
    private func configureTableView() {
        mainView.collectionView.delegate = self
        mainView.collectionView.dataSource = self
        mainView.collectionView.register(DonationTransactionGroupCell.self, forCellWithReuseIdentifier: "cellId")
    }
    
    private func configureAction() {
        mainView.handleTapClose = { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true)
        }
    }
}

extension DonationTransactionGroupController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data.donations.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! DonationTransactionGroupCell
        let item = self.data.donations[indexPath.row]
        cell.configure(name: item.title, price: item.amount.toCurrency(), urlString: item.urlPhoto)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 8, bottom: 8, right: 8)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = collectionView.frame.size
        size.height = 83
        return size
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
