import UIKit
import KipasKipasShared

protocol RegistrationStepDelegate: AnyObject {
    func complete(step: StepsController)
}

public class StepsController: UIViewController {
    weak var delegate: RegistrationStepDelegate?
    
    var storedData = RegisterData()
    
    let scrollContainer = ScrollContainerView()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureScrollContainer()
    }
    
    private func configureScrollContainer() {
        scrollContainer.paddingLeft = 32
        scrollContainer.paddingRight = 32
        
        view.addSubview(scrollContainer)
        scrollContainer.anchors.top.pin(to: view.safeAreaLayoutGuide, inset: 32)
        scrollContainer.anchors.edges.pin(to: view, axis: .horizontal)
        scrollContainer.anchors.bottom.pin()
    }
    
    func setLoading(_ isLoading: Bool) {
        fatalError("Override")
    }
}
