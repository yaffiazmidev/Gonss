import UIKit
import KipasKipasShared
import KipasKipasDonateStuff

final class DonationItemPaymentViewAdapter: ResourceView, ResourceLoadingView {
    
    private typealias Item = CollectionCellController
    private typealias Section = CollectionSectionController
    private typealias ViewModel = DonationItemPaymentViewModel
    
    weak var controller: DonationItemPaymentViewController?
    
    private let imageLoader: ImageResourceLoader
    private let showInitiatorProfile: Closure<String>
    
    init(
        imageLoader: ImageResourceLoader,
        showInitiatorProfile: @escaping Closure<String>
    ) {
        self.imageLoader = imageLoader
        self.showInitiatorProfile = showInitiatorProfile
    }
    
    func display(view viewModel: DonationItemPaymentViewModel) {
        controller?.display(
            sections: [
                makeHeaderSection(viewModel),
                makeInitiatorSection(viewModel),
                makeDividerSection(),
                makeProductSection(viewModel),
                makeDividerSection(),
                makeTransactionDetailSection(viewModel),
                makeDividerSection(),
                makePaymentMethodSection(viewModel)
            ], 
            paymentURL: URL(string: viewModel.paymentURL),
            isWaitingForPayment: viewModel.status.paymentStatus == .WAIT
        )
    }
    
    func display(loading viewModel: ResourceLoadingViewModel) {
        controller?.displayLoading(
            sections: DonationItemPaymentSection.skeletons,
            isLoading: viewModel.isLoading
        )
    }
}

// MARK: Section Factory
extension DonationItemPaymentViewAdapter {
    private func makeHeaderSection(_ viewModel: ViewModel) -> Section {
        let view = DonationItemPaymentHeaderCellController(viewModel: viewModel.status)
        let item = Item(view)
        return Section(
            cellControllers: [item],
            sectionType: DonationItemPaymentSection.header.rawValue
        )
    }
    
    private func makeInitiatorSection(_ viewModel: ViewModel) -> Section {
        let adapter = ImagePresentationAdapter<DonationItemPaymentInitiatorCellController>(loader: imageLoader)
        
        let view = DonationItemPaymentInitiatorCellController(
            viewModel: viewModel.initiator,
            imageAdapter: adapter, 
            showInitiatorProfile: showInitiatorProfile
        )
        
        adapter.presenter = LoadResourcePresenter(
            view: view,
            transformer: UIImage.tryMake
        )
        let item = Item(view)
        
        return Section(
            cellControllers: [item],
            sectionType: DonationItemPaymentSection.initiator.rawValue
        )
    }
    
    private func makeProductSection(_ viewModel: ViewModel) -> Section {
        let adapter = ImagePresentationAdapter<DonationItemPaymentProductCellController>(loader: imageLoader)
        
        let headerView = CollectionHeaderFooterCellController(text: "Barang", height: 35)
        let view = DonationItemPaymentProductCellController(
            viewModel: viewModel.product,
            imageAdapter: adapter
        )
        
        adapter.presenter = LoadResourcePresenter(
            view: view,
            transformer: UIImage.tryMake
        )
        
        let item = Item(view)
        let header = Item(headerView)
        
        return Section(
            cellControllers: [header, item],
            sectionType: DonationItemPaymentSection.product.rawValue
        )
    }
    
    private func makeTransactionDetailSection(_ viewModel: ViewModel) -> Section {
        let transaction = viewModel.transaction
        
        let header = CollectionHeaderFooterCellController(text: "Detail Transaksi", height: 35)
        
        let subtotal = DonationItemPaymentSummaryCellController(
            title: "Subtotal",
            detail: transaction.subtotal.inRupiah()
        )
        let shippingFee = DonationItemPaymentSummaryCellController(
            title: "Biaya Kirim",
            detail: transaction.shippingFee.inRupiah()
        )
        let adminFee = DonationItemPaymentSummaryCellController(
            title: "Biaya Admin",
            detail: transaction.adminFee.inRupiah()
        )
        let total = DonationItemPaymentSummaryCellController(
            title: "Total",
            detail: transaction.subtotal.inRupiah(),
            style: .bold
        )
        let footer = CollectionHeaderFooterCellController(height: 6)
        
        return Section(
            cellControllers: [
                Item(header),
                Item(subtotal),
                Item(shippingFee),
                Item(adminFee),
                Item(total),
                Item(footer)
            ],
            sectionType: DonationItemPaymentSection.summary.rawValue
        )
    }
    
    private func makePaymentMethodSection(_ viewModel: ViewModel) -> Section {
        let method = viewModel.method
        
        let header = CollectionHeaderFooterCellController(text: "Detail Pembayaran", height: 35)
        
        let transactionNo = DonationItemPaymentSummaryCellController(
            title: "Nomor Transaksi",
            detail: method.transactionNumberDesc,
            isCopyable: method.hasNoPaymentMethod == false
        )
        let transactionDate = DonationItemPaymentSummaryCellController(
            title: "Tanggal Transaksi",
            detail: method.transactionDateDesc
        )
        let transactionMethod = DonationItemPaymentSummaryCellController(
            title: "Metode Pembayaran",
            detail: method.bankNameDesc
        )
        
        let footer = CollectionHeaderFooterCellController(height: 6)
        
        var sections = [
                Item(header),
                Item(transactionDate),
                Item(transactionMethod),
                Item(footer)
        ]
        
        if method.transactionNumber != nil {
            sections.insert(Item(transactionNo), at: 1)
        }
        
        return Section(
            cellControllers: sections,
            sectionType: DonationItemPaymentSection.summary.rawValue
        )
    }
    
    private func makeDividerSection(
        color: UIColor = .alabaster,
        height: CGFloat = 8
    ) -> Section {
        let view = Divider(color: color, height: height)
        let item = Item(view)
        
        return Section(
            cellControllers: [item],
            sectionType: DonationItemPaymentSection.divider.rawValue
        )
    }
}
