import UIKit
import KipasKipasShared
import KipasKipasDonateStuff

final class DonationItemCheckoutViewAdapter {
    
    private typealias Item = CollectionCellController
    private typealias Section = CollectionSectionController
    
    private weak var viewController: DonationItemCheckoutViewController?
    
    private let imageLoader: ImageResourceLoader
    private let viewModel: DonationItemDetailViewModel
    private let quantity: Int
    
    init(
        imageLoader: ImageResourceLoader,
        viewController: DonationItemCheckoutViewController,
        viewModel: DonationItemDetailViewModel,
        quantity: Int
    ) {
        self.imageLoader = imageLoader
        self.viewController = viewController
        self.viewModel = viewModel
        self.quantity = quantity
    }
    
    func display() {
        viewController?.display(sections: [
            makeProductSection(),
            makeDividerSection(),
            makeAddressSection(),
            makeDividerSection(),
            makeDividerSection(color: .white),
            makeSummarySection(),
            makeDividerSection(color: .white)
        ])
    }
}

// MARK: Section factory
private extension DonationItemCheckoutViewAdapter {
    private func makeProductSection() -> Section {
        let model = viewModel.info
        let adapter = ImagePresentationAdapter<DonationItemCheckoutProductCellController>(loader: imageLoader)
        let view = DonationItemCheckoutProductCellController(
            viewModel: model,
            imageAdapter: adapter
        )
        adapter.presenter = LoadResourcePresenter(
            view: view,
            transformer: UIImage.tryMake
        )
        let item = Item(id: model.itemId, view)
        return Section(
            cellControllers: [item],
            sectionType: DonationItemCheckoutSection.product.rawValue
        )
    }
    
    private func makeAddressSection() -> Section {
        let stakeholder = viewModel.stakeholder
        
        let items: [Item] = [viewModel.stakeholder].map { model in
            let view = DonationItemCheckoutAddressCellController(viewModel: model)
            return Item(view)
        }
        
        let hasAddress = stakeholder.shippingAddress.isEmpty == false
        
        return Section(
            cellControllers: hasAddress ? items : [],
            sectionType: DonationItemCheckoutSection.address.rawValue
        )
    }
    
    private func makeSummarySection() -> Section {
        typealias Cell = DonationItemCheckoutSummaryCellController
        
        let detail = viewModel.info
        let totalPrice = detail.itemPrice.multiply(by: quantity).inRupiah()
        
        let productPrice = Cell(
            title: "Harga Produk",
            detail: "\(quantity)x \(detail.itemPriceDesc)"
        )
        let subtotal = Cell(
            title: "Subtotal",
            detail: totalPrice
        )
        let shippingFee = Cell(
            title: "Biaya Kirim",
            detail: "Rp0"
        )
        let adminFee = Cell(
            title: "Biaya Admin",
            detail: "Rp0"
        )
        let total = Cell(
            title: "Total",
            detail: totalPrice,
            style: .bold
        )
        
        return Section(
            cellControllers: [
                Item(productPrice),
                Item(subtotal),
                Item(shippingFee),
                Item(adminFee),
                Item(total)
            ],
            sectionType: DonationItemCheckoutSection.summary.rawValue
        )
    }
    
    private func makeDividerSection(
        color: UIColor = .alabaster,
        height: CGFloat = 4
    ) -> Section {
        let view = CollectionDividerCellController(color: color, height: height)
        let item = Item(view)
        return Section(
            cellControllers: [item],
            sectionType: DonationItemCheckoutSection.divider.rawValue
        )
    }
}
