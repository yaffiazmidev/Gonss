import UIKit

final class LocationDonationCell: UITableViewCell {
    
    private(set) var locationLabel = UILabel()
    private let lineView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: UI
private extension LocationDonationCell {
    func configureUI() {
        contentView.backgroundColor = .white

        configureLocationLabel()
        configureLineView()
    }
    
    func configureLocationLabel() {
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.textColor = UIColor(red: 0.29, green: 0.29, blue: 0.29, alpha: 1)
        locationLabel.font = .Roboto(.medium, size: 12)
        
        contentView.addSubview(locationLabel)
        NSLayoutConstraint.activate([
            locationLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            locationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            locationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14)
        ])
    }
    
    func configureLineView() {
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.backgroundColor = UIColor(red: 0.733, green: 0.733, blue: 0.733, alpha: 1)
        
        contentView.addSubview(lineView)
        NSLayoutConstraint.activate([
            lineView.heightAnchor.constraint(equalToConstant: 1),
            lineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            lineView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            lineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14)
        ])
    }
}
