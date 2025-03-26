import UIKit
import KipasKipasShared

public class NotificationSystemSettingItemCell: UICollectionViewCell {
    
    private(set) lazy var iconTypes: UIImageView = UIImageView()
    private(set) lazy var titleLbl: UILabel = UILabel()
    private(set) lazy var iconArrow: UIImageView = UIImageView()
    private(set) lazy var iconTypesContainerView: UIView = UIView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        contentView.backgroundColor = .white
        configureIconTypes()
        configureIconArrow()
        configureTitleLabel()
    }
    
    private func configureIconTypes() {
        contentView.addSubview(iconTypesContainerView)
        iconTypesContainerView.frame = CGRect(x: 16, y: 0, width: 40, height: 40)
        iconTypesContainerView.backgroundColor = .whiteSmoke
        iconTypesContainerView.layer.cornerRadius = 20
        
        iconTypesContainerView.addSubview(iconTypes)
        iconTypes.frame = .init(x: 10, y: 10, width: 20, height: 20)
        iconTypes.contentMode = .scaleAspectFit
        iconTypes.backgroundColor = .clear
    }
    
    private func configureIconArrow() {
        contentView.addSubview(iconArrow)
        iconArrow.frame = CGRect(
            x: self.bounds.width - 50,
            y: CGRectGetMidY(self.bounds) - 10,
            width: 12,
            height: 12
        )
        iconArrow.image = UIImage(systemName: "chevron.right")?.withTintColor(.contentGrey, renderingMode: .alwaysOriginal)
        iconArrow.contentMode = .scaleAspectFit
    }
    
    private func configureTitleLabel() {
        contentView.addSubview(titleLbl)
        titleLbl.frame = CGRect(x: iconTypesContainerView.bounds.width + 24, y: 0, width: 200, height: 40)
        titleLbl.font = .roboto(.regular, size: 15)
        titleLbl.textColor = .black
    }
    func configure(types: String) {
        if types == "account" {
            iconTypes.image = .iconUpdateSolidBlack
            titleLbl.text = "Akun Update"
        } else if types == "live" {
            iconTypes.image = .iconLiveSolidBlack
            titleLbl.text = types.uppercased()
        } else if types == "hotroom" {
            iconTypes.image = .iconSosialSolidBlack
            titleLbl.text = "Sosial"
        }
    }
}
