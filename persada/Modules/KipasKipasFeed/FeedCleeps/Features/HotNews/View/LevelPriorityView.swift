import UIKit
import KipasKipasShared

final class LevelPriorityView: UIView {
    
    private let stackView = UIStackView()
    private let chartView = UIImageView()
    private let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    private func configureUI() {
        backgroundColor = .gravel
        layer.cornerRadius = 4
        
        configureStackView()
        configureChartView()
        configureLabel()
    }
    
    private func configureStackView() {
        stackView.spacing = 6
        addSubview(stackView)
        stackView.anchors.edges.pin(insets: 4)
    }
    
    private func configureChartView() {
        chartView.image = .iconChart
        
        stackView.addArrangedSubview(chartView)
        chartView.anchors.width.equal(12)
        chartView.anchors.height.equal(12)
    }
    
    private func configureLabel() {
        label.font = .roboto(.medium, size: 13)
        label.textColor = .white
        stackView.addArrangedSubview(label)
    }
    
    private func numberOfDays(from createdAt: Int) -> Int {
        let createdDate = { Date(timeIntervalSince1970: TimeInterval(createdAt / 1_000)) }
        let today = { Date() }
    
        return daysBetween(createdDate(), today())
    }
    
    private func daysBetween(_ start: Date, _ end: Date) -> Int {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 25200)!
        calendar.locale = Locale(identifier: "id_ID")
        
        let startDate = calendar.startOfDay(for: start)
        let endDate = calendar.startOfDay(for: end)
        
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return (components.day ?? 0) + 1
    }
}

// MARK: API
extension LevelPriorityView {
    func set(priority: Int, createdAt: Int) {
        label.text = "L\(priority) - D\(numberOfDays(from: createdAt))"
    }
}
