import UIKit
import Combine
import KipasKipasShared

public final class BirthdayPickerViewController: StepsController {
    
    private let birthdayPickerView = BirthdayPickerView()
    private let datePicker = KKDateWheelsPickerView()
    
    private let today = Date()

    private lazy var dateOutputFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private var cancellables: Set<AnyCancellable> = []
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        observe()
    }
    
    private func observe() {
        datePicker.onDateChanged = { [weak self] date in
            guard let self else { return }
            storedData.birthDate = dateOutputFormatter.string(from: date.selectedDate)
            birthdayPickerView.setDateText(date.formattedDate)
        }
        
        birthdayPickerView.nextButton
            .tapPublisher
            .sink { [weak self] in
                guard let self = self else { return }
                delegate?.complete(step: self)
            }
            .store(in: &cancellables)
    }
}

private extension BirthdayPickerViewController {
    func configureUI() {
        view.backgroundColor = .white
        
        configureSpacer()
        configureBirthdayPickerView()
        configureDatePicker()
    }
    
    func configureSpacer() {
        scrollContainer.addArrangedSubViews(spacer(32))
    }
    
    func configureBirthdayPickerView() {
        birthdayPickerView.backgroundColor = .clear
        scrollContainer.addArrangedSubViews(birthdayPickerView)
    }
    
    func configureDatePicker() {
        view.addSubview(datePicker)
        datePicker.anchors.height.equal(280)
        datePicker.anchors.edges.pin(axis: .horizontal)
        datePicker.anchors.bottom.equal(view.safeAreaLayoutGuide.anchors.bottom)
    }
}
