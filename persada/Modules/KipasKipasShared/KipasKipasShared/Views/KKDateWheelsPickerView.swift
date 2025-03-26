import UIKit

public class KKDateWheelsPickerView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    private enum Component: Int {
        case day
        case month
        case year
    }
    
    public struct SelectedDateOutput {
        public let selectedDate: Date
        public let formattedDate: String
    }
    
    private let pickerView = UIPickerView()
    private let calendar = Calendar.current
    private var components = DateComponents()
    
    public private(set) lazy var dateOutputFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "id-ID")
        return formatter
    }()
    
    private var dayDataSource: Day {
        return .init(
            calendar: calendar,
            components: components
        )
    }
    
    private var monthDataSource: Month {
        return Month()
    }
    
    public var maximumDate = Date()
    
    public var onDateChanged: ((SelectedDateOutput) -> Void)?
    
    private var years: [Int] {
        return Array(1900...2100)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        overrideUserInterfaceStyle = .light
        configurePickerView()
        setDefault()
    }
    
    private func configurePickerView() {
        pickerView.delegate = self
        pickerView.dataSource = self
        
        addSubview(pickerView)
        pickerView.anchors.edges.pin()
    }
    
    private func setDefault() {
        let currentDate = Date()
        components = calendar.dateComponents([.day, .month, .year], from: currentDate)
        
        if let day = components.day, let month = components.month, let year = components.year {
            selectRow(dayDataSource.middleDay + (day - 1), inComponent: .day)
            selectRow(monthDataSource.middleMonth + (month - 1), inComponent: .month)
            selectRow(year - 1900, inComponent: .year)
        }
        
        pickerView.reloadAllComponents()
        
        if let selectedDate = calendar.date(from: components) {
            dateDidChanged(selectedDate)
        }
    }
    
    private func selectRow(
        _ row: Int,
        inComponent component: Component,
        animated: Bool = true
    ) {
        pickerView.selectRow(row, inComponent: component.rawValue, animated: animated)
    }
    
    private func adjustSelectedDay() {
        if let day = components.day {
            let maxDay = dayDataSource.validDays.last ?? 1
            let minDay = min(day, maxDay)
            
            let isValidDay = dayDataSource.isValidDay(day)
            let validDay = isValidDay ? minDay : maxDay
            
            components.day = validDay
            
            selectRow(
                dayDataSource.middleDay + validDay - 1,
                inComponent: .day,
                animated: !isValidDay
            )
        }
    }
    
    private func dateDidChanged(_ newDate: Date) {
        onDateChanged?(.init(
            selectedDate: newDate,
            formattedDate: dateOutputFormatter.string(from: newDate)
        ))
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return dayDataSource.infiniteDaysCount
        case 1:
            return monthDataSource.infiniteMonthsCount
        case 2:
            return years.count
        default:
            return 0
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let label: UILabel = view as? UILabel ?? {
            let label = UILabel()
            if #available(iOS 10.0, *) {
                label.font = .preferredFont(forTextStyle: .title2, compatibleWith: traitCollection)
                label.adjustsFontForContentSizeCategory = true
            } else {
                label.font = .preferredFont(forTextStyle: .title2)
            }
            label.textAlignment = .center
            return label
        }()
        
        switch component {
        case 0:
            guard let day = dayDataSource.day(at: row) else { return label }
            label.text = "\(day)"
            label.alpha = dayDataSource.isValidDay(day) ? 1 : 0.25
            
        case 1:
            guard let month = monthDataSource.month(at: row),
                  let date = calendar.date(from: DateComponents(year: 2000, month: month)) else {
                return label
            }
            
            let monthFormatter = DateFormatter()
            monthFormatter.dateFormat = "MMMM"
            monthFormatter.locale = Locale(identifier: "id-ID")
            
            label.text = monthFormatter.string(from: date)
            
        case 2:
            guard let year = years[safe: row] else { return label }
            label.text = "\(year)"
            
        default:
            break
        }
        
        return label
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            let day = dayDataSource.day(at: row)
            components.day = day
            
        case 1:
            guard let month = monthDataSource.month(at: row) else { return }
            components.month = month
            pickerView.reloadComponent(0) // Reload days when month changes
            
        case 2:
            if let year = years[safe: row] {
                components.year = year
                pickerView.reloadComponent(0) // Reload days when year changes
                pickerView.reloadComponent(1) // Reload months when year changes
            }
            
        default:
            break
        }
        
        adjustSelectedDay()
        
        // Check if selected date is beyond today and reset to today if needed
        guard let selectedDate = calendar.date(from: components) else { return }
        
        if selectedDate > maximumDate {
            setDefault()
        } else {
            dateDidChanged(selectedDate)
        }
    }
}

private extension KKDateWheelsPickerView {
    struct Day {
        private let calendar: Calendar
        private let components: DateComponents
        
        var days: [Int] {
            return Array(1...31)
        }
        
        var validDays: [Int] {
            guard let month = components.month, let year = components.year else { return [] }
            guard let date = calendar.date(from: .init(year: year, month: month)),
                  let range = calendar.range(of: .day, in: .month, for: date) else {
                return []
            }
            return Array(range)
        }
        
        func isValidDay(_ day: Int) -> Bool {
            return validDays.contains(day) == true
        }
        
        var infiniteDaysCount: Int {
            return days.count * 1000
        }
        
        var middleDay: Int {
            return infiniteDaysCount / 2
        }
        
        init(
            calendar: Calendar,
            components: DateComponents
        ) {
            self.calendar = calendar
            self.components = components
        }
        
        func day(at row: Int) -> Int? {
            return days[safe: row % days.count]
        }
    }
    
    struct Month {
        var months: [Int] {
            return Array(1...12)
        }
        
        var infiniteMonthsCount: Int {
            return months.count * 1000
        }
        
        var middleMonth: Int {
            return infiniteMonthsCount / 2
        }
        
        func month(at row: Int) -> Int? {
            return months[safe: row % months.count]
        }
    }
}
