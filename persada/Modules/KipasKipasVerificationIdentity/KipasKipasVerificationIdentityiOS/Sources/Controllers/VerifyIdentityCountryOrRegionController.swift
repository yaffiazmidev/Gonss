import UIKit
import KipasKipasShared
import KipasKipasVerificationIdentity

public class VerifyIdentityCountryOrRegionController: KKBottomSheetController {
    
    private lazy var mainView: VerifyIdentityCountryOrRegionView = {
        let view = VerifyIdentityCountryOrRegionView()
        return view
    }()
    
    private let countries: [VerifyIdentityCountryItem]
    private let regions: [String]
    
    var didSelectedCountry: ((VerifyIdentityCountryItem) ->Void)?
    
    public init(
        title: String = "",
        configure: KKBottomSheetConfigureItem? = nil,
        countries: [VerifyIdentityCountryItem] = [],
        regions: [String] = []
    ) {
        self.countries = countries
        self.regions = regions
        super.init(title: title, configure: configure)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        mainView.regions = regions
        mainView.countries = countries
        mainView.didSelectedCountry = { [weak self] item in
            guard let self = self else { return }
            self.handleSelectedCountry(item: item)
        }
    }
    
    public override func loadView() {
        super.loadView()
        layerView = mainView
        canSlideUp = false
        viewHeight = view.frame.height - 139
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func handleSelectedCountry(item: VerifyIdentityCountryItem) {
        animateDismissView { [weak self] in
            guard let self = self else { return }
            self.didSelectedCountry?(item)
        }
    }
}
