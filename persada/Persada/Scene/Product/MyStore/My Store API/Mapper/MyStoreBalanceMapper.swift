//
//  MyStoreBalanceMapper.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 10/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

final class MyStoreBalanceMapper {
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> MyStoreBalance {
        guard response.isOK, let root = try? JSONDecoder().decode(RemoteMyStoreBalance.self, from: data) else {
            throw KKNetworkError.invalidData
        }
        
        return MyStoreBalance(
            id: root.data?.id ?? "",
            transactionBalance: root.data?.transactionBalance ?? 0,
            refundBalance: root.data?.refundBalance ?? 0,
            totalBalance: root.data?.totalBalance ?? 0,
            isGopayActive: root.data?.isGopayActive ?? false,
            gopayBalance: root.data?.gopayBalance ?? 0,
            accountId: root.data?.accountId ?? "",
            withdrawFee: root.data?.withdrawFee,
            bankAccountDto: root.data?.bankAccountDto,
            postDonationId: root.data?.postDonationId
        )
    }
}

