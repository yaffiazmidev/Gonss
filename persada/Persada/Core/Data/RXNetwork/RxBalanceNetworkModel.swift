//
//  RxBalanceNetworkModel.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 23/02/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import RxSwift

public final class RxBalanceNetworkModel {
	private let network: Network<SaldoResult>
	private let networkBalance: Network<TransactionProductResult> = Network<TransactionProductResult>()
	
	init(network: Network<SaldoResult>) {
		self.network = network
	}
	
	func getSaldo() -> Observable<SaldoResult> {
		let requestEndpoint = SaldoEndpoint.getSaldo
		return network.getItemBalence(requestEndpoint.path, parameters: requestEndpoint.parameter, headers: requestEndpoint.header as! [String: String])
	}
	
	func getDetailBalance(id: String) -> Observable<TransactionProductResult> {
		let requestEndpoint = TransactionEndpoint.orderDetail(id: id)
		let header = requestEndpoint.header as! [String: String]
		return networkBalance.getItem(requestEndpoint.path, parameters: requestEndpoint.parameter, headers: header)
	}
}

