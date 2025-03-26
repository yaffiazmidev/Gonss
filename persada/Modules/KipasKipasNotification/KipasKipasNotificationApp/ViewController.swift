import UIKit
import KipasKipasNotification
import KipasKipasShared

public class ViewController: UIViewController {

    public var activitiesLoader: NotificationActivitiesLoader?
    public var profileStoryLoader: NotificationProfileStoryLoader?
    public var followersLoader: NotificationFollowersLoader?
    public var systemNotifLoader: NotificationSystemLoader?
    public var transactionLoader: NotificationTransactionLoader?
    public var suggestionAccountLoader: NotificationSuggestionAccountLoader?
    public var storyLoader: NotificationStoryLoader?
    public var activitiesDetailLoader: NotificationActivitiesDetailLoader?
    
    let buttonActivities = UIButton()
    let buttonActivitiesDetail = UIButton()
    let buttonProfile = UIButton()
    let buttonFollowers = UIButton()
    let buttonSystemNotif = UIButton()
    let buttonTransaction = UIButton()
    let buttonSuggestion = UIButton()
    let containerStack = UIStackView()
    public var id: String = ""
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        
        configureContainerStack()
    }
    
    func configureContainerStack() {
        view.addSubview(containerStack)
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        containerStack.axis = .vertical
        containerStack.backgroundColor = .white
        containerStack.distribution = .fillEqually
        containerStack.alignment = .fill
        containerStack.anchors.height.equal(400)
        containerStack.anchors.width.equal(250)
        containerStack.anchors.centerX.equal(view.anchors.centerX)
        containerStack.anchors.centerY.equal(view.anchors.centerY)
        
        configureButtonProfile()
        configureButtonFollowers()
        configureButtonActivities()
        configureButtonActivitiesDetail()
        configureButtonSystemNotif()
        configureButtonTransaction()
        configureButtonSuggestion()
    }

    func configureButtonActivities() {
        containerStack.addArrangedSubview(buttonActivities)
        buttonActivities.translatesAutoresizingMaskIntoConstraints = false
        buttonActivities.setTitle("Activities", for: .normal)
        buttonActivities.backgroundColor = .blue
        buttonActivities.addTarget(self, action: #selector(handleActivitiesButton), for: .touchUpInside)
    }
    
    func configureButtonProfile() {
        containerStack.addArrangedSubview(buttonProfile)
        buttonProfile.translatesAutoresizingMaskIntoConstraints = false
        buttonProfile.setTitle("Profile", for: .normal)
        buttonProfile.backgroundColor = .blue
        buttonProfile.addTarget(self, action: #selector(handleProfileStoryButton), for: .touchUpInside)
    }
    
    func configureButtonFollowers() {
        containerStack.addArrangedSubview(buttonFollowers)
        buttonFollowers.translatesAutoresizingMaskIntoConstraints = false
        buttonFollowers.setTitle("Followers", for: .normal)
        buttonFollowers.backgroundColor = .blue
        buttonFollowers.addTarget(self, action: #selector(handleFollowersButton), for: .touchUpInside)
    }
    
    func configureButtonSystemNotif() {
        containerStack.addArrangedSubview(buttonSystemNotif)
        buttonSystemNotif.translatesAutoresizingMaskIntoConstraints = false
        buttonSystemNotif.setTitle("System Notification", for: .normal)
        buttonSystemNotif.backgroundColor = .blue
        buttonSystemNotif.addTarget(self, action: #selector(handleSystemNotifButton), for: .touchUpInside)
    }
    
    func configureButtonTransaction() {
        containerStack.addArrangedSubview(buttonTransaction)
        buttonTransaction.translatesAutoresizingMaskIntoConstraints = false
        buttonTransaction.setTitle("Transacation", for: .normal)
        buttonTransaction.backgroundColor = .blue
        buttonTransaction.addTarget(self, action: #selector(handleTransactionButton), for: .touchUpInside)
    }
    
    func configureButtonSuggestion() {
        containerStack.addArrangedSubview(buttonSuggestion)
        buttonSuggestion.translatesAutoresizingMaskIntoConstraints = false
        buttonSuggestion.setTitle("Suggestion", for: .normal)
        buttonSuggestion.backgroundColor = .blue
        buttonSuggestion.addTarget(self, action: #selector(handleSuggestionButton), for: .touchUpInside)
    }
    
    func configureButtonActivitiesDetail() {
        containerStack.addArrangedSubview(buttonActivitiesDetail)
        buttonActivitiesDetail.translatesAutoresizingMaskIntoConstraints = false
        buttonActivitiesDetail.setTitle("Activities Detail", for: .normal)
        buttonActivitiesDetail.backgroundColor = .blue
        buttonActivitiesDetail.addTarget(self, action: #selector(handleActivitiesDetailButton), for: .touchUpInside)
    }
    
    @objc func handleActivitiesButton() {
        let request = NotificationActivitiesRequest(page: 0, size: 10)
        activitiesLoader?.load(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let items):
                print("items \(items)")
            case .failure(let error):
                print("error \(error)")
            }
        }
    }
    
    @objc func handleActivitiesDetailButton() {
        let request = NotificationActivitiesDetailRequest(page: 0, size: 10, actionType: "", targetType: "", targetId: "", targetAccountId: "")
        activitiesDetailLoader?.load(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let items):
                print("items \(items)")
            case .failure(let error):
                print("error \(error)")
            }
        }
    }
    
    @objc func handleProfileStoryButton() {
        let request = NotificationProfileStoryRequest(id: self.id)
        profileStoryLoader?.load(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let items):
                print("items \(items)")
            case .failure(let error):
                print("error \(error)")
            }
        }
    }
    
    @objc func handleFollowersButton() {
        let request = NotificationFollowersRequest(page: 0, size: 10)
        followersLoader?.load(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let items):
                print("items \(items)")
            case .failure(let error):
                print("error \(error)")
            }
        }
    }
    
    @objc func handleStoryButton() {
        let request = NotificationStoryRequest(page: 0, size: 10)
        storyLoader?.load(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let items):
                print("items \(items)")
            case .failure(let error):
                print("error \(error)")
            }
        }
    }
    
    @objc func handleSystemNotifButton() {
        let request = NotificationSystemRequest(page: 0, size: 10, types: "")
        systemNotifLoader?.load(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let items):
                print("items \(items)")
            case .failure(let error):
                print("error \(error)")
            }
        }
    }
    
    @objc func handleSuggestionButton() {
        let request = NotificationSuggestionAccountRequest(page: 0, size: 10)
        suggestionAccountLoader?.load(request: request, completion: { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let items):
                print("items \(items)")
            case .failure(let error):
                print("error \(error)")
            }
        })
    }
    
    @objc func handleTransactionButton() {
        let request = NotificationTransactionRequest(page: 0, size: 10, types: "")
        transactionLoader?.load(request: request, completion: { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let items):
                print("items \(items)")
            case .failure(let error):
                print("error \(error)")
            }
        })
    }
}

