//
//  ProductDetailViewModel.swift
//  KipasKipas
//
//  Created by iOS Dev on 23/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation

enum HistoryTransactionDetailModelType {
    case tanggalPembelian
    case invoice
    case produk
    case catatan
    case penerima
    case alamat
    case pengiriman
    case pembayaran
    case total
    case pembayaranRefund
    case adjustment
    case pesananAdjustment
    case resiNumberAdjustment
    case orderNoAdjustment
    case destinationAdjustment
    case adjustmentView
    case adjustmentBottom
}

protocol HistoryTransactionDetailItem {
    var type: HistoryTransactionDetailModelType { get }
}

struct ProductDetailModel: HistoryTransactionDetailItem {
    var name: String
    var photoUrl: String
    var quantity: Int
    var productPrice: Double
    
    var type: HistoryTransactionDetailModelType {
        return .produk
    }
}
 
struct ReceiverDetailModel: HistoryTransactionDetailItem {
    var name: String
    var phoneNumber: String
    
    var type: HistoryTransactionDetailModelType {
        return .penerima
    }
}
 
struct AddressDetailModel: HistoryTransactionDetailItem {
    var label: String?
    var address: String
    var subDistrict: String?
    var city: String?
    var province: String?
    var postalCode: String?
    
    var type: HistoryTransactionDetailModelType {
        return .alamat
    }
}
 
struct ShippingDetailModel: HistoryTransactionDetailItem {
    var courier: String
    var service: String?
    
    var type: HistoryTransactionDetailModelType {
        return .pengiriman
    }
}
 
struct PaymentDetailModel: HistoryTransactionDetailItem {
    var totalHargaBarang: Double
    var penyesuaianOngkir: Int?
    
    var type: HistoryTransactionDetailModelType {
        return .pembayaran
    }
}
 
struct NotesDetailModel: HistoryTransactionDetailItem {
    var description: String
    
    var type: HistoryTransactionDetailModelType {
        return .catatan
    }
}
 
struct AmountDetailModel: HistoryTransactionDetailItem {
    var amount: Double
    
    var type: HistoryTransactionDetailModelType {
        return .total
    }
}

struct DateDetailModel: HistoryTransactionDetailItem {
    var date: Int
    
    var type: HistoryTransactionDetailModelType {
        return .tanggalPembelian
    }
}

struct InvoiceDetailModel: HistoryTransactionDetailItem {
    var noInvoice: String
    
    var type: HistoryTransactionDetailModelType {
        return .invoice
    }
}

struct PaymentRefundModel: HistoryTransactionDetailItem {
    var hargaBarang: Double?
    var shipmentInitial: Double?
    var shipmentreturn: Double?
    var shipmentCostFinal: Double?
    
    var type: HistoryTransactionDetailModelType {
        return .pembayaranRefund
    }
}

struct AdjustmentModel: HistoryTransactionDetailItem {
    var shipmentCostInitial: Double
    var shipmentCostReturn: Double
    var shipmentCostFinal: Double
    
    var type: HistoryTransactionDetailModelType {
        return .adjustment
    }
}

struct ProductAdjustmentModel: HistoryTransactionDetailItem {
    var productName: String
    var productPrice: Double
    var quantity: Int
    var photoUrl: String
    
    var type: HistoryTransactionDetailModelType {
        return .pesananAdjustment
    }
}

struct NoResiModel: HistoryTransactionDetailItem {
    var noResi: String
    
    var type: HistoryTransactionDetailModelType {
        return .resiNumberAdjustment
    }
}

struct OrderNumberModel: HistoryTransactionDetailItem {
    var orderNumber: String
    
    var type: HistoryTransactionDetailModelType {
        return .orderNoAdjustment
    }
}

struct DestinationAdjustmentModel: HistoryTransactionDetailItem {
    var destination: String
    
    var type: HistoryTransactionDetailModelType {
        return .destinationAdjustment
    }
}

struct AdjustmentRefundModel: HistoryTransactionDetailItem {
    var ongkirAwal: Int
    var kurangBayar: Int
    var totalOngkir: Int
    
    var type: HistoryTransactionDetailModelType {
        return .adjustmentView
    }
}

struct AdjustmentBottomModel: HistoryTransactionDetailItem {
    var type: HistoryTransactionDetailModelType {
        return .adjustmentBottom
    }
}
