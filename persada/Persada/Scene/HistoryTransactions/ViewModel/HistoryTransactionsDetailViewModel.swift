//
//  HistoryTransactionDetailViewModel.swift
//  KipasKipas
//
//  Created by iOS Dev on 23/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class HistoryTransactionDetailViewModel {
    var title: String {
        switch type {
        case .transaction, .commission, .reseller:
            return "Detail Riwayat Transaksi"
        default:
            return "Detail Refund"
        }
    }
    
    var data = BehaviorRelay<[HistoryTransactionDetailItem]>(value: [])
    var errorMessage = BehaviorRelay<String?>(value: nil)
    var isLoading = BehaviorRelay<Bool?>(value: nil)
    var isDetailPenyesuaian = BehaviorRelay<Bool>(value: false)
    
    var operation: HistoryTransactionOperation
    
    var orderId: String?
    var type: TypeHistoryTransaction = .transaction
    
    init(operation: HistoryTransactionOperation = HistoryTransactionOperation()) {
        self.operation = operation
    }
    
    func fetchDataTransaction() {
        guard let orderId = orderId else { return }
        let request = HistoryTransactionDetailRequest(type: type, orderId: orderId)
        self.isLoading.accept(true)
        
        operation.detailTransaction(request: request, completion: { result in
            switch result {
            case .success(let data):
                
                var cell: [HistoryTransactionDetailItem] = []
                cell.append(DateDetailModel(date: data.orderDetail?.createAt ?? 0))
                cell.append(InvoiceDetailModel(noInvoice: data.noInvoice ?? ""))
                cell.append(ProductDetailModel(name: data.orderDetail?.productName ?? "",
                                                   photoUrl: data.orderDetail?.urlProductPhoto ?? "",
                                                   quantity: data.orderDetail?.quantity ?? 0,
                                                   productPrice: data.orderDetail?.productPrice ?? 0))
                cell.append(NotesDetailModel(description: data.orderShipment?.notes ?? "-"))
                cell.append(ReceiverDetailModel(name: data.orderShipment?.destinationReceiverName ?? "",
                                                    phoneNumber: data.orderShipment?.destinationPhoneNumber ?? ""))
                cell.append(AddressDetailModel(label: data.orderShipment?.originLabel ?? "", address: data.orderShipment?.destinationDetail ?? "",
                                                   subDistrict: data.orderShipment?.destinationSubDistrict ?? "",
                                                   city: data.orderShipment?.destinationCity,
                                                   province: data.orderShipment?.destinationProvince, postalCode: data.orderShipment?.originPostalCode ?? ""))
                cell.append(ShippingDetailModel(courier: data.orderShipment?.courier ?? "",
                                                    service: data.orderShipment?.service ?? ""))
                
                let productPrice = data.orderDetail?.productPrice ?? 0
                let quantity = Double(data.orderDetail?.quantity ?? 0)
                let penyesuaianOngkir = Double(data.orderShipment?.differentCost ?? 0)
                
                cell.append(PaymentDetailModel(totalHargaBarang: productPrice * quantity, penyesuaianOngkir: data.orderShipment?.differentCost ?? nil))
                cell.append(AmountDetailModel(amount: productPrice * quantity - penyesuaianOngkir))
                
                self.isLoading.accept(false)
                self.data.accept(cell)
        
            case .failure(_):
                self.errorMessage.accept("Error Network")
                self.isLoading.accept(false)
                
            case .error:
                self.errorMessage.accept("Error Network")
                self.isLoading.accept(false)
            }
            
        })
    }
    
    func fetchDataRefund() {
        guard let orderId = orderId else { return }
        let request = HistoryTransactionDetailRequest(type: type, orderId: orderId)
        isLoading.accept(true)
        
        operation.detailRefund(request: request, completion: { result in
            switch result {
            case .success(let data):
                
                var cell: [HistoryTransactionDetailItem] = []
                cell.append(DateDetailModel(date: data.createAt ?? 0))
                cell.append(InvoiceDetailModel(noInvoice: data.noInvoice ?? ""))
                cell.append(ProductDetailModel(name: data.productName ?? "",
                                                   photoUrl: data.urlProductPhoto ?? "",
                                                   quantity: data.quantity ?? 0,
                                                   productPrice: data.productPrice ?? 0))
                cell.append(PaymentRefundModel(hargaBarang: data.productPrice,
                                               shipmentInitial: data.shipmentCostInitial,
                                               shipmentreturn: data.shipmentCostReturn,
                                               shipmentCostFinal: data.shipmentCostFinal))
                cell.append(AmountDetailModel(amount: data.amount ?? 0))
                
                if let costInitial = data.shipmentCostInitial, let costReturn = data.shipmentCostReturn, let costFinal = data.shipmentCostFinal {
                    cell.append(AdjustmentModel(shipmentCostInitial: costInitial,
                                                shipmentCostReturn: costReturn,
                                                shipmentCostFinal: costFinal))
                    
                }
                
                self.data.accept(cell)
                self.isLoading.accept(false)
                
            case .failure(_):
                self.errorMessage.accept("Error Network")
                self.isLoading.accept(false)
                
            case .error:
                self.errorMessage.accept("Error Network")
                self.isLoading.accept(false)
            }
        })
    }
    
    func fetchDetailPenyesuaian() {
        guard let orderId = orderId else { return }
        let request = HistoryTransactionDetailRequest(type: type, orderId: orderId)
        self.isLoading.accept(true)
        
        operation.detailTransaction(request: request, completion: { result in
            switch result {
            case .success(let data):
                
                var cell: [HistoryTransactionDetailItem] = []
                cell.append(ProductAdjustmentModel(productName: data.orderDetail?.productName ?? "",
                                                   productPrice: data.orderDetail?.productPrice ?? 0,
                                                   quantity: data.orderDetail?.quantity ?? 0,
                                                   photoUrl: data.orderDetail?.urlProductPhoto ?? ""))
                cell.append(NoResiModel(noResi: data.orderShipment?.bookingNumber ?? ""))
                cell.append(OrderNumberModel(orderNumber: data.noInvoice ?? ""))
                cell.append(DestinationAdjustmentModel(destination: "\(data.orderShipment?.destinationDetail ?? "") \(data.orderShipment?.destinationSubDistrict ?? "") \(data.orderShipment?.destinationCity ?? "") \(data.orderShipment?.destinationProvince ?? "")"))
                cell.append(AdjustmentRefundModel(ongkirAwal: data.orderShipment?.cost ?? 0,
                                                  kurangBayar: data.orderShipment?.differentCost ?? 0,
                                                  totalOngkir: data.orderShipment?.actualCost ?? 0))
                cell.append(AdjustmentBottomModel())
                
                self.isLoading.accept(false)
                self.isDetailPenyesuaian.accept(false)
                self.data.accept(cell)
        
            case .failure(_):
                self.errorMessage.accept("Error Network")
                self.isLoading.accept(false)
                
            case .error:
                self.errorMessage.accept("Error Network")
                self.isLoading.accept(false)
            }
            
        })
    }
}

