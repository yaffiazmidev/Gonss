//
//  ProfileMenuViewController.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 10/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import UIKit
import OneSignal
import RxSwift
import RxCocoa
import KipasKipasNetworking
import KipasKipasPaymentInAppPurchase
import MessageUI
import FeedCleeps
import KipasKipasShared
import KipasKipasDonationCart

protocol ProfileMenuDisplayLogic where Self: UIViewController {
    
    func displayLogout(result: ResultData<DefaultResponse>)
}

class ProfileMenuViewController: UIViewController, Displayable, ProfileMenuDisplayLogic, AlertDisplayer{
    
    private let mainView: ProfileMenuView
    private var interactor: ProfileMenuInteractable!
    private var router: ProfileMenuRouting!
    private var presenter: ProfileMenuPresenter!
    private var menus: [ProfileSettings]!
    let disposeBag = DisposeBag()
    private let hud = CPKProgressHUD.progressHUD(style: .loading(text: nil))
    private let checker = FeedbackCheckerFactory.create()
    private var isExpandedLottery = false

    required init(mainView: ProfileMenuView, dataSource: ProfileMenuModel.DataSource) {
        self.mainView = mainView
        
        super.init(nibName: nil, bundle: nil)
        interactor = ProfileMenuInteractor(viewController: self, dataSource: dataSource)
        router = ProfileMenuRouter(self)
        presenter = ProfileMenuPresenter(self)
        menus = interactor.dataSource.items
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            mainView.versionLabel.text = "Version" + version
        }
        
        setupObservers()
        createRedDotObserver()
    }
    
    override func loadView() {
        view = mainView
        view.backgroundColor = .white
        mainView.table.register(ProfileMenuTableViewCell.self, forCellReuseIdentifier: "cell")
        mainView.table.delegate = self
        mainView.table.dataSource = self
        mainView.table.separatorStyle = .none
        setupNav()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
    }
    
    func setupNav(){
			self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: .get(.arrowleft)), style: .plain, target: self, action: #selector(self.back))
    }
    
    @objc func back(){
			let validId = self.interactor.dataSource.id
			let showNavBar = self.interactor.dataSource.showNavBar
			router.routeTo(.dismiss(id: validId, showNavBar: showNavBar))
    }
    
    
    // MARK: - ProfileMenuDisplayLogic
    func displayLogout(result: ResultData<DefaultResponse>) {
        self.displayLogoutResponse(data: result)
    }
    
    func setupObservers() {
        presenter.loadingState.drive(onNext: { [weak self] isLoading in
            if isLoading {
                guard let view = self?.view else { return }
                self?.hud.show(in: view)
                return
            } else {
                self?.hud.dismiss()
            }
        }).disposed(by: disposeBag)
    }
}


// MARK: - ProfileMenuViewDelegate
extension ProfileMenuViewController: ProfileMenuViewDelegate {
    
    func sendDataBackToParent(_ data: Data) {
        //usually this delegate takes care of users actions and requests through UI
        
        //do something with the data or message send back from mainView
    }
}

extension ProfileMenuViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isExpandedLottery {
            return interactor.dataSource.items.count
        } else {
            return interactor.dataSource.items.filter({ $0.isLotteryExpand }).count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ProfileMenuTableViewCell
        let menuItems = interactor.dataSource.items
        let showingItems = isExpandedLottery ? menuItems : menuItems.filter({ $0.isLotteryExpand })
        let item = showingItems[indexPath.row]
        let valueSplit = item.rawValue.components(separatedBy: "::")
        let imageName = valueSplit[1]
        let text = valueSplit[0]
        cell.setup()
        if item == .lottery {
            let imageLotteryConfiguration = UIImage.SymbolConfiguration(pointSize: 17, weight: .regular, scale: .small)
            let imageLottery = UIImage(systemName: imageName, withConfiguration: imageLotteryConfiguration)?.withTintColor(.contentGrey, renderingMode: .alwaysOriginal)
            cell.iconImage.image = imageLottery
            cell.iconImage.contentMode = .center
        } else {
            cell.iconImage.image = UIImage(named: imageName)
            cell.iconImage.contentMode = .scaleAspectFit
        }
        
        if item == .accessOrPermission {
            let myString = NSMutableAttributedString(string: text)
            let myAttribute = [NSAttributedString.Key.font: UIFont.Roboto(size: 11), NSAttributedString.Key.foregroundColor: UIColor.grey]
            myString.append(NSMutableAttributedString(string: "\nSetting Push Notification, Akses Galeri", attributes: myAttribute))
            cell.title.attributedText = myString
        } else {
            cell.title.text = text
        }
        
        
        if valueSplit[1] == "divider" {
            cell.title.isHidden = true
            cell.redDot.isHidden = true
            cell.iconImage.isHidden = true
            cell.fullImage.isHidden = false
            cell.isUserInteractionEnabled = false
        }
        else {
            cell.title.isHidden = false
            cell.iconImage.isHidden = false
            if text == "Pengaturan Akun" && getEmail().isEmpty {
                cell.redDot.isHidden = false
            } else {
                cell.redDot.isHidden = true
            }
            if text == "Kirim Feedback" {
                //openEmail()
                checkFeedback(cell: cell)
            }
            cell.fullImage.isHidden = true
            cell.isUserInteractionEnabled = true
        }
        return cell
    }
    
    
    
    private func checkFeedback(cell: ProfileMenuTableViewCell) {
        checker.check { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success(item):
                if !item.hasFeedback {
                    cell.redDot.isHidden = false
                } else {
                    cell.redDot.isHidden = true
                }
            case .failure:
                cell.redDot.isHidden = true
            }
        }
    }
    
    func createRedDotObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(updateRedDot(notification:)), name: .notificationUpdateEmail, object: nil)
    }
    
    @objc
    func updateRedDot(notification : NSNotification){
        mainView.table.reloadData()
    }
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch  menus[indexPath.row] {
            
        case .accountSetting: router.routeTo(.navigateToProfileSettingAccount)
            
        case .tnc: router.routeTo(.navigateToTnC)
            
        case .changeProfile: router.routeTo(.navigateToProfileEdit(id: interactor.dataSource.id))
            
        case .myAccount: router.routeTo(.navigateToRekeningSaya)
            
        case .myAddress: router.routeTo(.navigateToMyAddress)
            
            //        case .verifiedRequest: print("not implemented yet")
            
        case .divider: print("not implemented yet")
            
				case .setDiamond: router.routeTo(.navigateToSetDiamond)
        case .topUpCoin: router.routeTo(.navigateToTopUpCoin)
        case .fundraising: router.routeTo(.navigateToFundraising)
        
        case .accessOrPermission: navigateToNotificationSetting()
            
            //        case .applicationSetting: print("not implemented yet")
            
        case .privacy: router.routeTo(.navigateToPrivacyPolicy)
            
        case .logout: self.logout()
            
        case .sendFeedback: navigateToFeedback()
            
        case .badge: showDonationRankAndBadge?(interactor.dataSource.id)
            
            //        case .blankSpace: print("not implemented yet")
            
            //        case .sendFeedback: print("not implemented yet")
        case .sendLogs:
            //openEmail()
            showOpenLogDialog()
        case .withdrawDiamond:
            router.routeTo(.navigateToWithdrawDiamondDiamond)
        case .lottery:
            isExpandedLottery.toggle()
            tableView.reloadData()
        case .lotteryInitiation:
            handleOpenLottery(with: "reward")
        case .lotteryHistory:
            handleOpenLottery(with: "lotteryList")
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func handleOpenLottery(with path: String) {
        let token = getToken() ?? ""
        let vc = KKDefaultWebViewController(url: "https://lottery.kipas-dev.com/#/\(path)?Authorization=\(token)")
        vc.setupNavigationBar(backIndicator: .iconChevronLeft)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToNotificationSetting(){
        let controller = NotificationPreferencesUIFactory.create()
        navigationController?.displayShadowToNavBar(status: true)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func navigateToFeedback() {
        
        let controller = FeedbackUIFactory.create { [weak self] in
            guard let self = self else { return }
            let dialog = SuccessFeedbackDialogViewController()
            dialog.modalPresentationStyle = .overFullScreen
            self.present(dialog, animated: true)
        }
        navigationController?.displayShadowToNavBar(status: true)
        navigationController?.pushViewController(controller, animated: true)
    }
    
}
// MARK: - Private Zone
private extension ProfileMenuViewController {
    
    func logout() {
        displayAlert(
            with: "Apakah kamu yakin ingin keluar dari akun Kipaskipas ini?",
            message: "", 
            actions: [
                UIAlertAction(title: "Batalkan", style: .default),
                UIAlertAction(title: "Keluar", style: .default) { [weak self] _ in
                    self?.presenter.logout()
                }
            ]
        )
    }
    
    func displayDoSomething(_ viewModel: NSObject) {
        print("Use the mainView to present the viewModel")
        //example of using router
        router.routeTo(.xScene(xData: 22))
    }
    
    func displayLogoutResponse(data: ResultData<DefaultResponse>) {
        switch data {
        case .failure( _):
            displayAlert(with: String.get(.warning), message: String.get(.noInternet), actions: [UIAlertAction(title: String.get(.ok), style: .cancel)] )
        case .success:
            KKFeedCache.instance.clear()
            DataCache.instance.cleanAll()
            InAppPurchasePendingManager.instance.destroy()
            KKFeedLike.instance.reset()
            interactor.logoutCallFeature()
            
            DonationCartManager.instance.logout()
            logoutIM?()
            // Removing External User Id with Callback Available in SDK Version 2.13.1+
            OneSignal.removeExternalUserId({ results in
                // The results will contain push and email success statuses
                print("External user id update complete with results: ", results!.description)
                // Push can be expected in almost every situation with a success status, but
                // as a pre-caution its good to verify it exists
                if let pushResults = results!["push"] {
                    print("Remove external user id push status: ", pushResults)
                }
                // Verify the email is set or check that the results have an email success status
                if let emailResults = results!["email"] {
                    print("Remove external user id email status: ", emailResults)
                }
            })
            
            DispatchQueue.main.async {
                StorySimpleCache.instance.saveStories(stories: [])
                removeToken()  
                self.clearNotifsNav()
                let mainTabController = MainTabController()
                mainTabController.notifsNavigate?.configureNotif()
                self.view.window?.switchRootViewController(mainTabController, animated: false)
            }
        }
    }
    
    
     func clearNotifsNav(){
        if let tab = self.view.window?.rootViewController, tab is MainTabController {
             let mainTab = tab as? MainTabController
             mainTab?.notifsNavigate?.cleanNotif()
             mainTab?.notifsNavigate = nil
         }
     }
}

extension ProfileMenuViewController: MFMailComposeViewControllerDelegate  {
    func mailComposeController(_ didFinishWithcontroller: MFMailComposeViewController, 
                               didFinishWith result: MFMailComposeResult,
                               error: Error?){
        if(result == .sent){
            removeKKLog()
        }

      self.dismiss(animated: true, completion: nil)
    }

    func openEmail(){
        
        var fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            
            if( MFMailComposeViewController.canSendMail() ) {
                let mailComposer = MFMailComposeViewController()
                mailComposer.mailComposeDelegate = self
                

                let df = DateFormatter()
                df.dateFormat = "dd MMM - HH:mm"
                let dateNow = df.string(from: Date())
                
                let username = getUsername()
                
                //Set the subject and message of the email
                mailComposer.setToRecipients(["log@koanba.com"])
                mailComposer.setSubject("Kipas Log \(dateNow) - \(username)")
                mailComposer.setMessageBody("Check Log in attachments", isHTML: false)
                
                if let logKK = getKKLog() {
                    
                    let dfLog = DateFormatter()
                    dfLog.dateFormat = "ddMM-HHmm"
                    let dateNowLog = dfLog.string(from: Date())
                    //let logFileName = "\(logKK.absoluteString.suffix(9))-\(dateNowLog)"
                    let logFileName = "KKLog-\(dateNowLog).log"
                    
                    let logData = try Data(contentsOf: logKK)
                    mailComposer.addAttachmentData(logData, mimeType: "text/plain",
                                                   fileName: logFileName)
                }

                if let logTencents = getTencentLogs(){
                    try logTencents.forEach { log in
                        
                        let logData = try Data(contentsOf: log)
                        mailComposer.addAttachmentData(logData, mimeType: "text/plain",
                                                       fileName: String(log.absoluteString.suffix(27)))
                    }
                }
                
                self.present(mailComposer, animated: true, completion: nil)
            } else {
                displayAlert(with: String.get(.warning), 
                             message: String.get(.noMailAccount),
                             actions: [UIAlertAction(title: String.get(.ok), style: .cancel)] )

            }
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
        
    }

    func getTencentLogs() -> [URL]? {
        var logs = [URL]()
        var fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]

        let logPath = documentsURL.appendingPathComponent("log").absoluteURL

        let dfFilter = DateFormatter()
        dfFilter.dateFormat = "MMdd"
        let dateFilter = dfFilter.string(from: Date())

        do {
            
            var fileUrlStrings = [String]()
            let fileURLs = try fileManager.contentsOfDirectory(at: logPath, includingPropertiesForKeys: nil)
            fileURLs.forEach { fileURL in
                print("*** file : ", fileURL.absoluteString.suffix(27), "dateFilter:",dateFilter)
                if(fileURL.absoluteString.lowercased().contains("liteav")){
                    if(fileURL.absoluteString.lowercased().contains("\(dateFilter)-")){
                        fileUrlStrings.append(fileURL.absoluteString)
                    }
                }
            }
            
            let sortedfileUrlStrings = fileUrlStrings.sorted { $0 < $1 }
            sortedfileUrlStrings.forEach { urlString in
                if let fileUrl = URL(string: urlString) {
                    logs.append(fileUrl)
                }
            }
        }
        catch { print("error") }
        
        return logs
    }
    
    func getKKLog() -> URL? {
        var logData = URL(string: "")
        do {
            var fileManager = FileManager.default
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let logPathRoot = documentsURL.absoluteURL
            let fileURLRoots = try fileManager.contentsOfDirectory(at: logPathRoot, includingPropertiesForKeys: nil)
            fileURLRoots.forEach { fileURLRoot in
                if(fileURLRoot.absoluteString.lowercased().contains("kklog.log")){
                    logData = fileURLRoot
                }
            }
        }
        catch { 
            print("getKKLog : error", error)
        }
        return logData
    }
    
    func removeKKLog(){
        do {
            var fileManager = FileManager.default
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let logPathRoot = documentsURL.absoluteURL
            let fileURLRoots = try fileManager.contentsOfDirectory(at: logPathRoot, includingPropertiesForKeys: nil)
            try fileURLRoots.forEach { fileURLRoot in
                if(fileURLRoot.absoluteString.lowercased().contains("kklog.log")){
                    try FileManager.default.removeItem(atPath: fileURLRoot.path)
                }
            }
        }
        catch {
            print("removeKKLoog : error", error)
        }
    }
    
    private func showOpenLogDialog() {
        
        var titleDialog = "Choose Send Logs"
        let alert = UIAlertController(title: titleDialog, message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Share Files", style: .default , handler:{ [weak self] (UIAlertAction) in
            guard self != nil else { return }
            self?.openShareLog()
        }))

        alert.addAction(UIAlertAction(title: "Send Email", style: .default , handler:{ [weak self] (UIAlertAction) in
            guard self != nil else { return }
            self?.openEmail()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel , handler:{ (UIAlertAction) in
        }))

        self.present(alert, animated: true)
    }

    
    func openShareLog(){
        var filesToShare = [Any]()
            
        if let logKK = getKKLog() {
            filesToShare.append(logKK)
            let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
            
            activityViewController.completionWithItemsHandler = {  [weak self] activityType, completed, returnedItems, activityError in
                guard self != nil else { return }

                if(completed){
                    self?.removeKKLog()
                }
                
                if((activityError) != nil){
                    print("*** share error")
                }
            }
            self.present(activityViewController, animated: true, completion: nil)
        }
    }

}
