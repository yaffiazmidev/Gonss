//
//  VerifyIdentityGuidelineCVC.swift
//  KipasKipasVerificationIdentityiOS
//
//  Created by DENAZMI on 02/06/24.
//

import UIKit

class VerifyIdentityGuidelineCVC: UICollectionViewCell {

    @IBOutlet weak var sampleImageView: UIImageView!
    @IBOutlet weak var titleIconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var point1Label: UILabel!
    @IBOutlet weak var point2Label: UILabel!
    @IBOutlet weak var point3Label: UILabel!
    @IBOutlet weak var point4Label: UILabel!
    @IBOutlet weak var point1ContainerStackLabel: UIStackView!
    @IBOutlet weak var point2ContainerStackLabel: UIStackView!
    @IBOutlet weak var point3ContainerStackLabel: UIStackView!
    @IBOutlet weak var point4ContainerStackLabel: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        sampleImageView.image = nil
        titleIconImageView.image = nil
        titleLabel.text = nil
        point1Label.text = nil
        point2Label.text = nil
        point3Label.text = nil
        point4Label.text = nil
        point1ContainerStackLabel.isHidden = true
        point2ContainerStackLabel.isHidden = true
        point3ContainerStackLabel.isHidden = true
        point4ContainerStackLabel.isHidden = true
    }
    
    func configure(with item: GuidelineItem) {
        titleLabel.text = item.title
        sampleImageView.image = item.image
        titleIconImageView.image = item.titleIcon
        setupPoints(with: item.points)
    }
    
    private func setupPoints(with items: [String]) {
        let labels = [point1Label, point2Label, point3Label, point4Label]
        let containers = [point1ContainerStackLabel, point2ContainerStackLabel, point3ContainerStackLabel, point4ContainerStackLabel]
        
        for (index, _) in containers.prefix(containers.count).enumerated() {
            containers[index]?.isHidden = true
        }
        
        for (index, point) in items.prefix(labels.count).enumerated() {
            labels[index]?.text = point
            containers[index]?.isHidden = false
        }
    }
}
