import UIKit
import KipasKipasDirectMessage
import KipasKipasShared
import Foundation


protocol IBalanceMianViewController:AnyObject {
     func displayError(message: String)
    func displayBalanceDetail(data:RemoteBalanceCurrencyDetail)
    func displayBalanceGrade(data:RemoteBalancePointsData)
}

public class BalanceMianViewController: UIViewController,NavigationAppearance {
     
    private lazy var mainView: BalanceMianView = {
        let view = BalanceMianView().loadViewFromNib() as! BalanceMianView
        view.delegate = self
        return view
    }()
    
    var interactor: IBalanceMianInteractor!
    var router: IBalanceMianRouter!
    
    public override func loadView() {
        view = mainView
    }
    
    public init() {
        super.init(nibName: "BalanceMianViewController", bundle: SharedBundle.shared.bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
//        DispatchQueue.main.async { KKDefaultLoading.shared.show() }
        
//        interactor.requestBalanceGrade() 
 
    }
    
    private func setupNavigationBar() {
        bindNavBar()
        let navColor = UIColor(hexString: "#F5F5F5")
        setupNavigationBar( color: navColor)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) 
        setupNavigationBar()
        interactor.requestBalanceDetsil()
          
        let hasSet = UserDefaults.standard.object(forKey: "BalancePopView")
        guard let isSet = hasSet as? Bool ,isSet == true else {
            let view = BalancePopView()
            appWindow?.addSubview(view)
            view.anchors.edges.pin()
            return
        }
    }
    
}


extension BalanceMianViewController:BalanceMianViewDelegate {
    
    func didTapCoinPurchase(){
        router.navigateToCoinPurchase()
    }
    
    func didTapDiamondWithdrawal(){
        router.navigateToDiamondWithdrawal()
    }
    
    func didTapShowMsg(){
        showToast(with: "Kami sedang menyempurnakan fitur lni!")
    }
    
    func didTapVerifyCard() {
        let verifIdentityStatus = mainView.data?.verifIdentityStatus ?? ""
        
        if verifIdentityStatus == "rejectred" || verifIdentityStatus == "revision" {
            router.navigateToVerifyIdentityStatus()
        } else {
            didTapVerifyButton()
        }
    }
    
    func didTapVerifyButton() {
        router.navigateToVerifyIdentity(by: mainView.data?.verifIdentityStatus ?? "")
    }
    
    func didTapViewBalance() {
        let vc = CustomPopUpViewController(
            title: "Fitur sedang dalam proses pengembangan.",
            description: "Kami sedang menyempurnakan fitur ini, bersiaplah untuk pengalaman terbaik.",
            iconImage: .imgProgress,
            iconHeight: 99
        )
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: false)
    }
}

extension BalanceMianViewController:IBalanceMianViewController{
    func displayBalanceDetail(data: KipasKipasDirectMessage.RemoteBalanceCurrencyDetail) {
//        KKDefaultLoading.shared.hide()
        self.mainView.data = data
    }
    
    func displayError(message: String) {
//        KKDefaultLoading.shared.hide()
        self.presentAlert(title: "Error", message: message)
    }
    
    func displayBalanceGrade(data:RemoteBalancePointsData){
//        KKDefaultLoading.shared.hide()
        self.mainView.gradedata = data
    }
    
    
}
