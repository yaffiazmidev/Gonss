//
//  InformationHistoryLabelTableViewCell.swift
//  KipasKipas
//
//  Created by iOS Dev on 21/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class InformationHistoryLabelTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    
    var catatan: HistoryTransactionDetailItem? {
        didSet {
            guard let catatan = catatan as? NotesDetailModel else { return }
            titleLabel.text = "Catatan"
            captionLabel.text = catatan.description
        }
    }
    
    var penerima: HistoryTransactionDetailItem? {
        didSet {
            guard let penerima = penerima as? ReceiverDetailModel else { return }
            titleLabel.text = "Penerima"
            captionLabel.text = "\(penerima.name)\n\(penerima.phoneNumber)"
        }
    }
    
    var alamat: HistoryTransactionDetailItem? {
        didSet {
            guard let alamat = alamat as? AddressDetailModel else { return }
            titleLabel.text = "Alamat"
            captionLabel.text = "\(alamat.label ?? ""), \(alamat.address), Kecamatan \(alamat.subDistrict ?? ""), \(alamat.city ?? ""), Provinsi \(alamat.province ?? ""), Kode Pos: \(alamat.postalCode ?? "")"
        }
    }
    
    var pengiriman: HistoryTransactionDetailItem? {
        didSet {
            guard let pengiriman = pengiriman as? ShippingDetailModel else { return }
            titleLabel.text = "Pengiriman"
            captionLabel.text = "\(pengiriman.courier) \(pengiriman.service ?? "")"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
