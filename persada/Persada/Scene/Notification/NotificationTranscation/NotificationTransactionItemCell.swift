//
//  NotificationTransactionItemCell.swift
//  KipasKipas
//
//  Created by movan on 13/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class NotificationTransactionItemCell: UITableViewCell {
	
	private enum ViewTrait {
		static let padding: CGFloat = 8
	}
	
	lazy var iconImageView: UIImageView = {
		let imageView = UIImageView()
		let placeholderImage = UIImage(named: "placeholderUserImage")
		imageView.backgroundColor = .whiteSnow
		imageView.layer.cornerRadius = 4
		imageView.clipsToBounds = true
		imageView.image = placeholderImage
		return imageView
	}()
	
	lazy var titleLabel: UILabel = {
		let label: UILabel = UILabel()
		label.textColor = .black
		label.font = UIFont.Roboto(.bold, size: 14)
        label.numberOfLines = 0
		return label
	}()
	
	lazy var subtitleLabel: UILabel = {
		let label: UILabel = UILabel()
		label.textColor = .contentGrey
		label.font = UIFont.Roboto(.regular, size: 12)
		label.numberOfLines = 0
		return label
	}()
	
	lazy var dateLabel: UILabel = {
		let label: UILabel = UILabel()
		label.textAlignment = .right
		label.textColor = .placeholder
		label.font = UIFont.Roboto(.medium, size: 12)
		return label
	}()
	
	lazy var containerView: UIView = {
		let view: UIView = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.layer.masksToBounds = false
		view.layer.cornerRadius = 8
		view.backgroundColor = .secondaryLowTint
		return view
	}()

	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		backgroundColor = .clear
		layer.cornerRadius = 8
        selectionStyle = .none

		
		addSubview(containerView)
		
		[iconImageView, titleLabel, subtitleLabel, dateLabel].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			containerView.addSubview($0)
		}
		
		iconImageView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, paddingTop: 8, paddingLeft: 8, width: 35, height: 35)
		
		dateLabel.anchor(top: containerView.topAnchor, right: containerView.rightAnchor, paddingTop: 8, paddingRight: 8, height: 20)
		
		titleLabel.anchor(top: containerView.topAnchor, left: iconImageView.rightAnchor, right: dateLabel.leftAnchor, paddingTop: 7, paddingLeft: 8, paddingRight: 8, height: 20)

		subtitleLabel.anchor(top: titleLabel.bottomAnchor, left: iconImageView.rightAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 4, paddingLeft: 8, paddingBottom: 8, paddingRight: 8)
		
		containerView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingBottom: 4)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 100.0, left: 100.0, bottom: 10.0, right: 10.0))

        titleLabel.sizeToFit()
	}
	
	override func awakeFromNib() {
				 super.awakeFromNib()
		layoutMargins = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
		 }
    
    func setUpCell(item : NotificationTransaction?){
        titleLabel.text = getHeader(item: item)
        subtitleLabel.setHTMLFromString(text: getMessageLabel(item: item))
        if item?.notifType == "withdraw" {
            if item?.withdrawl?.status == "queued" {
                iconImageView.backgroundColor = .systemBlue
                iconImageView.image = UIImage(named: .get(.iconProcWithdrawGopay))!
            } else {
                iconImageView.backgroundColor = .success
                iconImageView.image = UIImage(named: .get(.iconCompletedWithdrawGopay))!
            }
        } else {
            if item?.notifType == "currency_coin" || item?.notifType == "currency_diamond" {
                iconImageView.image = UIImage(named: item?.notifType == "currency_diamond" ? "img_diamond_blue" : "img_coin_gold")
            } else {
                iconImageView.loadImage(at: item?.urlProductPhoto ?? "")
            }
        }
        guard let date = TimeFormatHelper.soMuchTimeAgoNew(date: item?.createAt ?? 1000) else { return }
        dateLabel.text = date
        if item?.isRead ?? false {
            containerView.backgroundColor = .clear
        } else {
            titleLabel.textColor = .black
            containerView.backgroundColor = UIColor(hexString: "#F6FBFF")
        }
        
    }
    
    func getMessageLabel(item : NotificationTransaction?) -> String {
        if item?.status == "CANCELLED" && item?.paymentStatus == nil  && item?.shipmentStatus == nil {
            return "Pembayaran gagal, pesanan dibatalkan."
        }
        return item?.message ?? "\n"
    }
    
    func getHeader(item : NotificationTransaction?) -> String {
        print("\nNHEAD: =============\n")
        print("NHEAD order: \(item?.orderType ?? "")\nNHEAD account: \(item?.accountShopType ?? "")\nNHEAD3 status: \(item?.status ?? "")\nNHEAD payment: \(item?.paymentStatus ?? "")\nNHEAD shipment: \(item?.shipmentStatus ?? "")\nNHEAD5 message: \(item?.message ?? "")")
        
        if item?.notifType == "currency_coin" {
            
            iconImageView.image = UIImage(named: "img_coin_gold")
            
            switch item?.currency?.status?.lowercased() {
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
        
        if item?.notifType == "currency_diamond" {
            
            iconImageView.image = UIImage(named: "img_diamond_blue")
            
            switch item?.currency?.status?.lowercased() {
            case "completed":
                return "Penarikan Diamond Berhasil"
            default:
                return "Penarikan Diamond sedang diproses"
            }
        }
        
        if item?.isProductBanned ?? false {
            return .get(.produkDibanned)
        }
        if item?.notifType == "shop_out_of_stock_product"{
            return .get(.produkHabis)
        }
        
        if item?.notifType == "withdraw" {
           if item?.withdrawl?.status == "queued" {
               return "Menunggu Proses Penarikan - GoPay"
           } else if item?.withdrawl?.status == "completed" {
               return "Penarikan Dana Berhasil - GoPay"
           }
       }
        
        if item?.orderType == "product"{
            if item?.isNotifWeightAdj ?? false {
                return .get(.penyesuaianOngkir)
            }
            
            if item?.accountShopType == "reseller" {
                switch item?.notifType {
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
                default: return item?.orderType?.capitalized ?? ""
                }
            }
            
            if item?.status == "NEW" {
                if item?.accountShopType == "buyer" {
                    return .get(.menunggu)
                } else {
                    return .get(.pesananBaru)
                }
            } else if item?.status == "PROCESS" {
                if item?.shipmentStatus == "PACKAGING" {
                    return .get(.sedangDiproses)
                }
                else if item?.shipmentStatus == "SHIPPING" {
                    return .get(.sedangDiantar)
                } else if item?.shipmentStatus == "CANCELLED" {
                    return .get(.dibatalkan)
                } else if item?.shipmentStatus == "DELIVERED" {
                    return .get(.pesananSampai)
                }
            } else if item?.status == "CANCELLED" {
                if item?.paymentStatus == "EXPIRED" {
                    return .get(.pembayaranExpired)
                } else if item?.shipmentStatus == "RETURN" {
                    return .get(.dikembalikan)
                } else if item?.paymentStatus == "RETURN" {
                    return .get(.dibatalkan)
                } else if item?.shipmentStatus == "CANCELLED" {
                    return .get(.dibatalkan)
                } else {
                    return .get(.dibatalkan)
                }
            } else if item?.status == "COMPLETE" {
                return .get(.pesananSelesai)
            }
            
        }else if item?.orderType == "donation" {
            switch item?.notifType {
            case "donation_unpaid": return "Menunggu Pembayaran"
            case "donation_paid": return "Donasi Terkirim"
            case "donation_expired": return "Donasi Dibatalkan"
            default: return item?.orderType?.capitalized ?? ""
            }
        }
        
        return item?.paymentStatus?.capitalized ?? ""
    }
}
