//
//  CheckoutPresenter.swift
//  Persada
//
//  Created by movan on 22/07/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Combine

protocol CheckoutPresenterLogic: AnyObject {
	func dismiss()
	func areaNotCoverage(error : ErrorMessage)
	func areaCovered()
}

final class CheckoutPresenter {
	
	weak var delegate: CheckoutPresenterLogic?
	
	private var router: CheckoutRouter
	private var disposeBag = DisposeBag()
	private var interactor = CheckoutInteractor()
	
	var subscriptions = Set<AnyCancellable>()
	var error = BehaviorRelay<String?>(value: "")
    
	var accountId: String?
    var item: BehaviorRelay<Product?> = BehaviorRelay<Product?>(value: nil)
	var quantity: Int
	var address: BehaviorRelay<Address?> = BehaviorRelay<Address?>(value: nil)
	var deliveryAddress: Address?
	var total: Int?
	var courier: BehaviorRelay<Courier?> = BehaviorRelay<Courier?>(value: nil)
	var parameterOrder: ParameterOrder?
    var bool = false
    var productId: String
    
	init(router: CheckoutRouter, productId: String, quantity: Int) {
		self.router = router
		self.productId = productId
		self.quantity = quantity
	}
	
	func setParameter(_ data: ParameterOrder) {
		self.parameterOrder = data
	}
	
	func setDeliveryAddress(_ address: Address) {
		self.deliveryAddress = address
	}
	
	func setAddress(_ value: Address) {
		self.address.accept(value)
	}
	
	func addCost(_ courier: Courier) {
		self.courier.accept(courier)
	}
	
	func orderProduct( parameter: ParameterOrder) {
		
		self.interactor.orderProduct(parameter: parameter)
			.subscribe { [weak self] (response) in
				self?.delegate?.dismiss()
			} onError: { error in
				self.mappingErrorRelay(error: error)
			}.disposed(by: disposeBag)
	}
		
	func fetchBuyerAddress() {
		interactor.fetchAddress(type: .buyer).subscribe { result in
            guard let validData = result.data?.filter({ (address) -> Bool in
                (address.isDefault ?? false)
            }).first else { return }
            
			self.address.accept(validData)
		} onError: { error in
			self.mappingErrorRelay(error: error)
		}.disposed(by: disposeBag)
	}
	
    func isOrderDelayed(delayed: @escaping ()->Void, notDelayed: @escaping ()->Void){
        interactor.isOrderDelayed()
            .debug()
            .subscribe { (response) in
            print("Responsenya \(response)")
                if let bool = response.data?.orderExist {
                if bool {
                    delayed()
                } else {
                    notDelayed()
                }
            }
        } onError: { (error) in
					self.mappingErrorRelay(error: error)
        } onCompleted: {
            print("Responsenya \( self.bool)")
        }.disposed(by: disposeBag)
    }
    
    func checkout(order: CheckoutOrderRequest, success: @escaping (String) -> Void, onOutOfStock: @escaping () -> Void) {
        //        interactor.checkout(order: order)
        //            .debug()
        //            .subscribe { (response) in
        //                success(response.data.redirectURL)
        //            } onError: { (error) in
        //				self.mappingErrorRelay(error: error)
        //            }.disposed(by: disposeBag)
        checkoutRequest(order: order) { [weak self] response in
            guard self != nil else { return }
            success(response.data?.redirectURL ?? "")
        } onOutOfStock: { [weak self] response in
            guard self != nil else { return }
            onOutOfStock()
        } onFailure: { [weak self] error in
            guard self != nil else { return }
            self?.mappingErrorRelay(error: error)
        }
    }
    
    func checkoutRequest(order: CheckoutOrderRequest, onSuccess: @escaping ((CheckoutOrderResult)->Void), onOutOfStock: @escaping((CheckoutOrderErrorResponse)->Void), onFailure: @escaping ((Error) -> Void) ){
        
        let orderEndpoint = OrderEndpoint.checkoutOrder(order: order)
        let absolutePath = "\(APIConstants.baseURL)\(orderEndpoint.path)"
        var urlRequest = URLRequest(url: URL(string: absolutePath)!)
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(order)
        
        urlRequest.httpBody = jsonData
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(getToken() ?? "")", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, _ in
            guard self != nil else { return }
            DispatchQueue.main.async {
                if let data = data {
                    let decoder = JSONDecoder()
                    do {
                        let jsonData = try decoder.decode(CheckoutOrderResult.self, from: data)
                        onSuccess(jsonData)
                    } catch _ {
                        do {
                            let jsonData = try decoder.decode(CheckoutOrderErrorResponse.self, from: data)
                            onOutOfStock(jsonData)
                        } catch let error2 {
                            onFailure(error2)
                        }
                    }
                }
            }
        }.resume()
    }
    
    func checkoutContinue(order: CheckoutOrderRequest, success: @escaping (String) -> Void, onOutOfStock: @escaping () -> Void) {
        checkoutContinueRequest(order: order) { [weak self] response in
            guard self != nil else { return }
            success(response.data?.redirectUrl ?? "")
        } onOutOfStock: { [weak self] response in
            guard self != nil else { return }
            onOutOfStock()
        } onFailure: { [weak self] error in
            guard self != nil else { return }
            self?.mappingErrorRelay(error: error)
        }
    }
    
    func checkoutContinueRequest(order: CheckoutOrderRequest, onSuccess: @escaping ((CheckoutOrderContinueResult)->Void), onOutOfStock: @escaping((CheckoutOrderErrorResponse)->Void), onFailure: @escaping ((Error) -> Void) ){
        
        let orderEndpoint = OrderEndpoint.checkoutOrderContinue(order: order)
        let absolutePath = "\(APIConstants.baseURL)\(orderEndpoint.path)"
        var urlRequest = URLRequest(url: URL(string: absolutePath)!)
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(order)
        
        urlRequest.httpBody = jsonData
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(getToken() ?? "")", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, _ in
            guard self != nil else { return }
            DispatchQueue.main.async {
                if let data = data {
                    let decoder = JSONDecoder()
                    do {
                        let jsonData = try decoder.decode(CheckoutOrderContinueResult.self, from: data)
                        onSuccess(jsonData)
                    } catch _ {
                        do {
                            let jsonData = try decoder.decode(CheckoutOrderErrorResponse.self, from: data)
                            onOutOfStock(jsonData)
                        } catch let error2 {
                            onFailure(error2)
                        }
                    }
                }
            }
        }.resume()
    }
    
    func getProductById(id: String, success: @escaping (Product) -> Void) {
        interactor.getProductById(id: id).observeOn(MainScheduler.instance)
            .subscribe { [weak self] response in
                guard let validData = response.data else { return }
                self?.item.accept(validData)
                success(validData)
            } onError: { (error) in
                self.mappingErrorRelay(error: error)
            }.disposed(by: disposeBag)
    }
    
	func checkCourierAvaiable(_ param: ParameterCourier) {
		
		let network = ShipmentNetworkModel()
		
		network.requestCouriers(.shipmentCouriers, param).sink { (completion) in
			switch completion {
			case .failure(let error):
				if let apiError = error as? ErrorMessage {
					if ((apiError.statusData?.containsIgnoringCase(find: "Not Cover")) != nil) {
							self.delegate?.areaNotCoverage(error: apiError)
					} else {
						self.mappingErrorRelay(error: error)
					}
				} else {
					self.mappingErrorRelay(error: error)
				}
			case .finished: break
			}
		} receiveValue: { (model) in
			self.delegate?.areaCovered()
		}.store(in: &subscriptions)
	}
	
	func mappingErrorRelay(error: Error) {
		if let apiError = error as? ErrorMessage {
            if apiError.code == "5000" {
                self.error.accept(apiError.code)
            }else{
                self.error.accept(apiError.statusData)
            }
		} else {
			self.error.accept(error.localizedDescription)
		}
	}
}

