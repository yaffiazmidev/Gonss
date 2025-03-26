//
//  MyBankAccountCell.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 11/10/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class MyBankAccountCell: UITableViewCell {

    @IBOutlet weak var rekDigunakanLabel: UILabel!
    @IBOutlet weak var namaBankLabel: UILabel!
    @IBOutlet weak var noRekLabel: UILabel!
    @IBOutlet weak var namaPemilikLabel: UILabel!
    
    private let checked = UIImage(named: "iconRadioButtonChecked")
    private let unchecked = UIImage(named: "iconRadioButtonUncheck")
    
    var data: AccountDestinationModel? {
        didSet {
            guard let data = data else { return }
            namaBankLabel.text = data.namaBank
            noRekLabel.text = data.noRek
            namaPemilikLabel.text = data.nama
//            rekDigunakanLabel.isHidden = data.isSelected == true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
