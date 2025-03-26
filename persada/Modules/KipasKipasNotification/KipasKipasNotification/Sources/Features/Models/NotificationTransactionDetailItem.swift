//
//  NotificationTransactionDetailswift
//  KipasKipasNotification
//
//  Created by DENAZMI on 10/05/24.
//

import Foundation

public struct NotificationTransactionDetailItem: Equatable {
    public let id, orderType, status, paymentStatus, notifType: String
    public let shipmentStatus: String
    public let accountShopType: String
    public let accountDonationType: String
    public let account: NotificationSuggestionAccountItem
    public let orderID: String
    public let createAt: Int
    public let message: String
    public let urlProductPhoto: String
    public var isRead, isNotifWeightAdj, isProductBanned: Bool
    public let productID: String
    public let withdrawType: String
    public let withdrawl: NotificationWithdrawl
    public let currency: NotificationTransactionItemCurrency
    public let groupOrderId: String?
    
    public static func == (lhs: NotificationTransactionDetailItem, rhs: NotificationTransactionDetailItem) -> Bool {
        return lhs.id == rhs.id
    }
}

extension NotificationTransactionDetailItem {
    
    
    public func titleNavbar() -> String {
        print("\nNHEAD: =============\n")
        print("NHEAD notifType: \(notifType) NHEAD order: \(orderType)\nNHEAD account: \(accountShopType)\nNHEAD3 status: \(status)\nNHEAD payment: \(paymentStatus)\nNHEAD shipment: \(shipmentStatus)\nNHEAD5 message: \(message)")
        
        if notifType == "currency_coin" {
            
//            iconImageView.image = UIImage(named: "img_coin_gold")
            
            switch currency.status.lowercased() {
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
        
        if notifType == "currency_diamond" {
            
//            iconImageView.image = UIImage(named: "img_diamond_blue")
            
            switch currency.status.lowercased() {
            case "completed":
                return "Penarikan Diamond Berhasil"
            default:
                return "Penarikan Diamond sedang diproses"
            }
        }
        
        if isProductBanned {
            return "Produk Dibanned"
        }
        
        if notifType == "shop_out_of_stock_product"{
            return "Produk Habis"
        }
        
        if notifType == "withdraw" {
            if withdrawl.status == "queued" {
                return "Menunggu Proses Penarikan - GoPay"
            } else if withdrawl.status == "completed" {
                return "Penarikan Dana Berhasil - GoPay"
            }
        }
        
        if orderType == "product"{
            if isNotifWeightAdj {
                return "Penyesuaian Ongkir"
            }
            
            if accountShopType == "reseller" {
                switch notifType {
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
                default: return orderType.capitalized
                }
            }
            
            if status == "NEW" {
                if accountShopType == "buyer" {
                    return "Menunggu"
                } else {
                    return "Pesanan Baru"
                }
            } else if status == "PROCESS" {
                if shipmentStatus == "PACKAGING" {
                    return "Sedang Diproses"
                }
                else if shipmentStatus == "SHIPPING" {
                    return "Sedang Diantar"
                } else if shipmentStatus == "CANCELLED" {
                    return "Dibatalkan"
                } else if shipmentStatus == "DELIVERED" {
                    return "Pesanan Sampai"
                }
            } else if status == "CANCELLED" {
                if paymentStatus == "EXPIRED" {
                    return "Pembayaran Expired"
                } else if shipmentStatus == "RETURN" {
                    return "Dikembalikan"
                } else if paymentStatus == "RETURN" {
                    return "Dibatalkan"
                } else if shipmentStatus == "CANCELLED" {
                    return "Dibatalkan"
                } else {
                    return "Dibatalkan"
                }
            } else if status == "COMPLETE" {
                return "Pesanan Selesai"
            }
            
        } else if orderType == "donation" {
            switch notifType {
            case "donation_unpaid": return "Menunggu Pembayaran"
            case "donation_paid": return "Donasi Terkirim"
            case "donation_expired": return "Donasi Dibatalkan"
            case "donation_cancel": return "Donasi Dibatalkan"
            default: return orderType.capitalized
            }
        }
        
        return paymentStatus.capitalized
    }
}
