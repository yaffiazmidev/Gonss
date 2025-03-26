//
//  TransactionCollectionViewCell.swift
//  KipasKipasNotificationiOS
//
//  Created by Rahmat Trinanda Pramudya Amar on 28/03/24.
//

import UIKit
import KipasKipasShared
import KipasKipasNotification

class TransactionCollectionViewCell: UICollectionViewCell {
    
    private let iconSize: CGFloat = 53
    
    private lazy var iconView: UIView = {
        let image = UIImageView(image: .iconTransactionItem)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.cornerRadius = iconSize / 2
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.whiteSmoke.cgColor
        view.addSubview(image)
        
        image.anchors.size.equal(.init(width: 27, height: 27))
        image.anchors.centerX.equal(view.anchors.centerX)
        image.anchors.centerY.equal(view.anchors.centerY)
        
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.numberOfLines = 0
        label.textAlignment = .left
        
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .contentGrey
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 0
        label.textAlignment = .left
        
        return label
    }()
    
    lazy var productImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 2
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.whiteSmoke.cgColor
        
        return view
    }()
    
    private lazy var contentsView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel, productImageView])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 4
        view.alignment = .leading
        
        productImageView.anchors.size.equal(.init(width: 50, height: 50))
        
        return view
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviews([iconView, contentsView])
        
        iconView.anchors.size.equal(.init(width: iconSize, height: iconSize))
        iconView.anchors.leading.equal(view.anchors.leading)
        iconView.anchors.top.equal(view.anchors.top)
        
        contentsView.anchors.leading.equal(iconView.anchors.trailing, constant: 12)
        contentsView.anchors.trailing.equal(view.anchors.trailing)
        contentsView.anchors.top.equal(view.anchors.top)
        contentsView.anchors.bottom.equal(view.anchors.bottom)
        
        return view
    }()
    
    // MARK: Function
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        productImageView.isHidden = true
        productImageView.image = nil
    }
    
    func configure(with data: NotificationTransactionItem) {
        titleLabel.text = title(from: data)
        
        let messageStringAttr = data.message.htmlToAttributedString(font: .systemFont(ofSize: 14, weight: .regular), color: .contentGrey)
        let dateAttr = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .regular), NSAttributedString.Key.foregroundColor : UIColor.placeholder]
        let dateStringAttr = NSMutableAttributedString(string: " \(data.createAt.timeAgoDisplay())", attributes: dateAttr)
        messageStringAttr.append(dateStringAttr)
        descriptionLabel.attributedText = messageStringAttr
        
        if !data.urlProductPhoto.isEmpty {
            productImageView.loadImageWithOSS(from: data.urlProductPhoto, size: .w100)
            productImageView.isHidden = false
        }
    }
    
    func title(from item: NotificationTransactionItem) -> String {
        print("\nNHEAD: =============\n")
        print("NHEAD order: \(item.orderType)\nNHEAD account: \(item.accountShopType)\nNHEAD3 status: \(item.status)\nNHEAD payment: \(item.paymentStatus)\nNHEAD shipment: \(item.shipmentStatus)\nNHEAD5 message: \(item.message)")
        
        if item.notifType == "currency_coin" {
            
//            iconImageView.image = UIImage(named: "img_coin_gold")
            
            switch item.currency.status.lowercased() {
            case "completed", "purchased":
                return "Pembelian Koin Berhasil"
            case "new", "pending":
                return "Pembelian koin sedang diproses"
            case "canceled":
                return "Pembelian di batalkan"
            default:
                return "-"
            }
            
        }
        
        if item.notifType == "currency_diamond" {
            
//            iconImageView.image = UIImage(named: "img_diamond_blue")
            
            switch item.currency.status.lowercased() {
            case "completed":
                return "Penarikan Diamond Berhasil"
            default:
                return "Penarikan Diamond sedang diproses"
            }
        }
        
        if item.isProductBanned {
            return "Produk Dibanned"
        }
        
        if item.notifType == "shop_out_of_stock_product"{
            return "Produk Habis"
        }
        
        if item.notifType == "withdraw" {
            if item.withdrawl.status == "queued" {
                return "Menunggu Proses Penarikan - GoPay"
            } else if item.withdrawl.status == "completed" {
                return "Penarikan Dana Berhasil - GoPay"
            }
        }
        
        if item.orderType == "product"{
            if item.isNotifWeightAdj {
                return "Penyesuaian Ongkir"
            }
            
            if item.accountShopType == "reseller" {
                switch item.notifType {
                case "shop_product_reseller_update_stop":
                    return "Reseller - Pemberhentian Produk"
                case "shop_product_reseller_update_info":
                    return "Reseller - Perubahan Info Produk"
                case "shop_product_commission_update":
                    return "Reseller - Perubahan Harga Produk"
                case "shop_product_reseller_update_archive":
                    return "Produk di Arsipkan"
                case "shop_order_complete_reseller":
                    return "Reseller - Order Selesai"
                default: return item.orderType.capitalized
                }
            }
            
            if item.status == "NEW" {
                if item.accountShopType == "buyer" {
                    return "Menunggu"
                } else {
                    return "Pesanan Baru"
                }
            } else if item.status == "PROCESS" {
                if item.shipmentStatus == "PACKAGING" {
                    return "Sedang Diproses"
                }
                else if item.shipmentStatus == "SHIPPING" {
                    return "Sedang Diantar"
                } else if item.shipmentStatus == "CANCELLED" {
                    return "Dibatalkan"
                } else if item.shipmentStatus == "DELIVERED" {
                    return "Pesanan Sampai"
                }
            } else if item.status == "CANCELLED" {
                if item.paymentStatus == "EXPIRED" {
                    return "Pembayaran Expired"
                } else if item.shipmentStatus == "RETURN" {
                    return "Dikembalikan"
                } else if item.paymentStatus == "RETURN" {
                    return "Dibatalkan"
                } else if item.shipmentStatus == "CANCELLED" {
                    return "Dibatalkan"
                } else {
                    return "Dibatalkan"
                }
            } else if item.status == "COMPLETE" {
                return "Pesanan Selesai"
            }
            
        } else if item.orderType == "donation" {
            switch item.notifType {
            case "donation_unpaid": return "Menunggu Pembayaran"
            case "donation_paid": return "Donasi Terkirim"
            case "donation_expired": return "Donasi Dibatalkan"
            case "donation_cancel": return "Donasi Dibatalkan"
            default: return item.orderType.capitalized
            }
        } else if item.orderType == "donation_item" {            
            switch item.notifType {
            case "donation_item_unpaid": return "Menunggu Pembayaran"
            case "donation_item_expired": return "Donasi Barang Dibatalkan"
            case "donation_item_paid": return "Donasi Barang Berhasil"
            case "donation_item_cancel": return "Donasi Barang Dibatalkan"
            default: return item.orderType.capitalized
            }
        }
        
        
        return item.paymentStatus.capitalized
    }
}

// MARK: - Private Helper
private extension TransactionCollectionViewCell {
    func configUI() {
        backgroundColor = .white
        
        addSubview(containerView)
        
        containerView.anchors.leading.equal(anchors.leading, constant: 16)
        containerView.anchors.trailing.equal(anchors.trailing, constant: -16)
        containerView.anchors.top.equal(anchors.top, constant: 8)
        containerView.anchors.bottom.equal(anchors.bottom, constant: -8)
    }
}

fileprivate extension String {
    func htmlToAttributedString(font: UIFont, color: UIColor) -> NSMutableAttributedString {
        // Define regular expression patterns for bold tags
        let boldPattern = "<b>(.*?)</b>"
        
        // Create a mutable attributed string with the original text
        let attrStr = NSMutableAttributedString(string: self)
        
        // Apply the provided font and color to the entire attributed string
        let range = NSRange(location: 0, length: attrStr.length)
        attrStr.addAttribute(.font, value: font, range: range)
        attrStr.addAttribute(.foregroundColor, value: color, range: range)
        
        // Apply bold styling to text within <b> tags and remove <b> tags
        do {
            let regex = try NSRegularExpression(pattern: boldPattern, options: .caseInsensitive)
            var offset = 0 // Offset to adjust for changes in string length due to tag removal
            regex.enumerateMatches(in: self, options: [], range: NSRange(location: 0, length: attrStr.length)) { match, _, _ in
                if let matchRange = match?.range {
                    let adjustedRange = NSRange(location: matchRange.location - offset, length: matchRange.length)
                    
                    // Apply bold font to text within <b> tags
                    attrStr.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: font.pointSize), range: adjustedRange)
                    
                    // Remove <b> tags
                    attrStr.deleteCharacters(in: NSRange(location: matchRange.location - offset, length: 3)) // Remove <b>
                    attrStr.deleteCharacters(in: NSRange(location: matchRange.location + matchRange.length - offset - 7, length: 4)) // Remove </b>
                    
                    offset += 7 // Adjust offset for the removed tags
                }
            }
        } catch {
            // Handle regex pattern error
            print("Error creating regex: \(error)")
        }
        
        return attrStr
    }
}
