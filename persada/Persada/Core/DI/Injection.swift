//
//  Injection.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 18/12/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

final class Injection: NSObject {

	func provideFeedUseCase() -> FeedUseCase {
		let repo = makeFeedRepository()
		return FeedInteractorRx(repository: repo)
	}
	
	func provideSaldoUseCase() -> BalanceUseCase {
		let repo = makeBalanceRepository()
		return BalanceInteractorRx(repository: repo)
	}

	func provideAuthUseCase() -> AuthUseCase {
		let repo = makeAuthRepository()
		return AuthInteractorRx(repository: repo)
	}

	func provideProfileUseCase() -> ProfileUseCase {
		let repo = makeProfileRepository()
		return ProfileInteractorRx(repository: repo)
	}
	
	func provideProductUseCase() -> ProductUseCase {
		let repo = makeProductRepository()
		return ProductInteractorRx(repository: repo)
	}
    
    func provideSelectCourier() -> SelectCourierUseCase {
        let repo = makeSelectCourierRepository()
        return SelectCourierRx(repository: repo)
    }
	
	func provideAddressUseCase() -> AddressUseCase {
			let repo = makeAddressRepository()
			return AddressInteractorRx(repository: repo)
	}
    
	func provideNotificationUseCase() -> NotificationUseCase {
		let repo = makeNotificationRepository()
		return NotificationInteractorRx(repository: repo)
	}
	
	func provideTransactionUseCase() -> TransactionUseCase {
		let repo = makeTransactionRepository()
		return TransactionInteratorRx(repository: repo)
	}
	
	func provideHashtagUseCase() -> HashtagUseCase {
		let repo = makeHashtagRepository()
		return HashtagInteractorRx(repository : repo)
	}
	
    
    func provideOrderUseCase() -> OrderUseCase {
        let repo = makeOrderRepository()
        return OrderInteractorRx(repository: repo)
    }
    
	func makeFeedRepository() -> FeedRepository {
		return FeedRepositoryImpl.sharedInstance(RxFeedNetworkModel(network: Network<FeedArray>(), networkDefault: Network<DefaultResponse>()))
	}

	func makeAuthRepository() -> AuthRepository {
		return AuthRepositoryImpl.sharedInstance(RxAuthNetworkModel(networkDefault: Network<DefaultResponse>()))
	}

	func makeProfileRepository() -> ProfileRepository {
		return ProfileRepositoryImpl.sharedInstance(RxProfileNetworkModel(network: Network<ProfileResult>())
		)
	}
	
	func makeProductRepository() -> ProductRepository {
		return ProductRepositoryImpl.sharedInstance(
			RxProductNetworkModel(network: Network<ProductResult>(), networkArchive: Network<ProductResultById>(), networkDefault: Network<DefaultResponse>(), networkDelete: Network<DeleteResponse>())
		)
	}
    
    func makeSelectCourierRepository() -> SelectCourierRepository {
			return SelectCourierRepositoryImpl.sharedInstance(RxSelectCourierNetworkModel(network: Network<SelectCourierResult>(), networkDefault: Network<UpdateCourierResult>()))
    }
	
	func makeBalanceRepository() -> BalanceRepository {
		return BalanceRepositoryImpl.sharedInstance(RxBalanceNetworkModel(network: Network<SaldoResult>()))
	}
	
	func makeNotificationRepository() -> NotificationRepository {
        return NotificationRepositoryImpl.sharedInstance( RxNotificationNetworkModel(network: Network<NotificationSocialResult>(), networkTransaction: Network<NotificationTransactionResult>(), networkTransactionDetail: Network<TransactionProductResult>(), networkDefault: Network<DefaultResponse>())
		)
	}
	
	func makeAddressRepository() -> AddressRepository {
			return AddressRepositoryImpl.sharedInstance( RxAddressNetworkModel(network: Network<DefaultResponse>(), networkAddress: Network<AddressResult>(), networkAddressSingle: Network<SingleAddressResult>(), networkArea: Network<AreaResult>(), networkRemove: Network<RemoveResponse>(), networkPostalCode: Network<NewPostalCodeResult>())
		)
	}
	
	func makeTransactionRepository() -> TransactionRepository {
		return TransactionRepositoryImpl.sharedInstance(RxTransactionNetworkModel(network: Network<BalanceResult>(), networkOrder: Network<PaymentResponse>()))
	}
	
	func makeHashtagRepository() -> HashtagRepository {
		return HashtagRepositoryImpl.sharedInstance( RxHashtagNetworkModel(network: Network<FeedArray>()))
	}
    
    func makeOrderRepository() -> OrderRepository {
        return OrderRepositoryImpl.sharedInstance(RxOrderNetworkModel(network: Network<CheckoutOrderResult>(), networkDefault: Network<DelayCheckoutResult>(), networkContinue: Network<CheckoutOrderContinueResult>()))
    }
	
}
