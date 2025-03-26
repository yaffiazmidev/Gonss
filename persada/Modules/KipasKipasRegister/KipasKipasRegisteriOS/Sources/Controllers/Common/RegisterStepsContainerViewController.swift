import UIKit
import KipasKipasShared

public class RegisterStepsContainerViewController: KKPageViewController {
    
    private let fakeNavbar = FakeNavBar()
    
    private var currentStep: StepsController?
    
    private let steps: [StepsController]
    private let data: RegisterData
    
    public var register: Closure<RegisterData>?
    
    public init(
        steps: [StepsController],
        data: RegisterData
    ) {
        self.steps = steps
        self.data = data
        super.init()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        isScrollEnabled = false
        
        configureFakeNavbar()
        setInitialData()
    }
    
    private func setInitialData() {
        if let initialStep = steps.first {
            initialStep.storedData = data

            setViewControllers(
                [initialStep],
                direction: .forward,
                animated: true,
                completion: nil
            )
            
            currentStep = initialStep
        }
        
        for step in steps {
            step.delegate = self
        }
    }
    
    private func currentIndex(of step: StepsController) -> Int? {
        return steps.firstIndex(of: step)
    }
    
    private func step(for index: Int) -> StepsController {
        return steps[index]
    }
    
    private func goToNext(step: StepsController) {
        DispatchQueue.main.async {
            self.setViewControllers([step], direction: .forward, animated: true, completion: nil)
        }
    }
    
    private func goToPrevious(step: StepsController) {
        DispatchQueue.main.async {
            self.setViewControllers([step], direction: .reverse, animated: true, completion: nil)
        }
    }
    
    @objc private func didTapBack() {
        if let step = currentStep {
            backTo(step: step)
        }
    }
}

// MARK: RegistrationStepDelegate
extension RegisterStepsContainerViewController: RegistrationStepDelegate {
    func complete(step: StepsController) {
        guard let currentIndex = currentIndex(of: step) else {
            return
        }
        
        let nextIndex = currentIndex + 1
        
        guard nextIndex < steps.count else {
            /// Register when reached the last step
            register?(step.storedData)
            step.setLoading(true)
            return
        }
        
        let nextStep = self.step(for: nextIndex)
        nextStep.storedData = step.storedData
        
        goToNext(step: nextStep)
        currentStep = nextStep
    }
    
    private func backTo(step: StepsController) {
        guard let currentIndex = currentIndex(of: step), currentIndex > 0 else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        let previousStep = self.step(for: currentIndex - 1)
        goToPrevious(step: previousStep)
        currentStep = previousStep
    }
}

// MARK: UI
private extension RegisterStepsContainerViewController {
    func configureFakeNavbar() {
        fakeNavbar.titleLabel.text = "Daftar"
        fakeNavbar.isUsingSafeArea = true
        fakeNavbar.titleLabel.font = .roboto(.medium, size: 18)
        fakeNavbar.titleLabel.textColor = .night
        fakeNavbar.backgroundColor = .white
        fakeNavbar.height = 41
        fakeNavbar.separatorView.backgroundColor = .clear
        fakeNavbar.leftButton.tintColor = .night
        fakeNavbar.leftButton.setImage(UIImage.System.chevronLeft)
        fakeNavbar.leftButton.anchors.width.equal(41)
        fakeNavbar.leftButton.anchors.height.equal(41)
        
        fakeNavbar.leftButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        
        view.addSubview(fakeNavbar)
    }
}
