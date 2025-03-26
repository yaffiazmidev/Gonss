//
//  NotificationTransactionDetailView.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 10/05/24.
//

import UIKit
import KipasKipasNotification

protocol INotificationTransactionDetailView: AnyObject {
    func didClickBackButton()
}

class NotificationTransactionDetailView: UIView {

    @IBOutlet weak var containerView: UIView!
    
    // MARK: NAVBAR
    @IBOutlet weak var backButtonContainerStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    weak var delegate: INotificationTransactionDetailView?
    
    var item: NotificationTransactionDetailItem? {
        didSet { setupView(with: item) }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubViews()
        setupComponent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubViews()
    }
    
    private func initSubViews() {
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: Bundle(for: type(of: self)))
        nib.instantiate(withOwner: self, options: nil)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        addConstraints()
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: containerView.topAnchor),
            bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])
    }
    
    func setupComponent() {
        overrideUserInterfaceStyle = .light
        handleOnTapView()
    }
    
    func handleOnTapView() {
        let onTapBackButtonGesture = UITapGestureRecognizer(target: self, action: #selector(handleOnTapBackButton))
        backButtonContainerStackView.isUserInteractionEnabled = true
        backButtonContainerStackView.addGestureRecognizer(onTapBackButtonGesture)
    }
}

extension NotificationTransactionDetailView {
    @objc func handleOnTapBackButton() {
        delegate?.didClickBackButton()
    }
}

extension NotificationTransactionDetailView {
    
    func setupView(with item: NotificationTransactionDetailItem?) {
        guard let item = item else { return }
        titleLabel.text = item.titleNavbar()
    }
    
    func title(from item: NotificationTransactionDetailItem) -> String {
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
        }
        
        return item.paymentStatus.capitalized
    }
}
