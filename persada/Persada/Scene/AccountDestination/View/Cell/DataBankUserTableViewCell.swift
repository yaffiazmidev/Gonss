//
//  DataBankUserTableViewCell.swift
//  KipasKipas
//
//  Created by iOS Dev on 29/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class DataBankUserTableViewCell: UITableViewCell {
    @IBOutlet weak var noRekLabel: UILabel!
    @IBOutlet weak var namaPemilikLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    
    @IBOutlet weak var bankNameLabel: UILabel!
    private let checked = UIImage(named: "iconRadioButtonChecked")
    private let unchecked = UIImage(named: "iconRadioButtonUncheck")
    
    var data: AccountDestinationModel? {
        didSet {
            guard let data = data else { return }
            bankNameLabel.text = data.namaBank
            noRekLabel.text = data.noRek
            namaPemilikLabel.text = data.nama
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public func isSelected(_ selected: Bool) {
        setSelected(selected, animated: false)
        let image = selected ? checked : unchecked
        iconImage.image = image
    }
    
    
    
}
