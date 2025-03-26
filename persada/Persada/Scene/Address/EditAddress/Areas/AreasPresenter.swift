//
//  AreasPresenter.swift
//  KipasKipas
//
//  Created by movan on 12/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class AreasPresenter {
	let result = BehaviorRelay<[Area]>(value: [])
    let resultPostalCode = BehaviorRelay<[PostalCodeElement]>(value: [])
	var filteredresult : BehaviorRelay<[Area]> = BehaviorRelay(value: [])
    var filteredresultPostalCode : BehaviorRelay<[PostalCodeElement]> = BehaviorRelay(value: [])
	let didSelectRowTrigger = PublishSubject<IndexPath>()
	
	private let disposeBag = DisposeBag()
	private let router : AreasRouter!
	private let interactor : AreasInteractor!
	
	
	lazy var searchValue : BehaviorRelay<String> = BehaviorRelay(value:"")

	lazy var searchValueObservable: Observable<String> = self.searchValue.asObservable()
	lazy var resultObservable: Observable<[Area]> = self.result.asObservable()
    lazy var resultPostalCodeObservable: Observable<[PostalCodeElement]> = self.resultPostalCode.asObservable()
	lazy var filteredResultObservable: Observable<[Area]> = self.filteredresult.asObservable()
    lazy var filteredResultPostalCodeObservable: Observable<[PostalCodeElement]> = self.filteredresultPostalCode.asObservable()
	let errorRelay = BehaviorRelay<Error?>(value: nil)
	
	init(router: AreasRouter, interactor: AreasInteractor) {
		self.router = router
		self.interactor = interactor
		
		didSelectRowTrigger.asObservable()
				.observeOn(MainScheduler.asyncInstance)
				.bind(onNext: selectRow)
				.disposed(by: disposeBag)
		
		fetchResult()
		search()
	}
	
	private func selectRow(indexPath: IndexPath) {
        switch interactor.type {
        case .postalCode:
            let area = Area(code: "", id: "", name: "", postalCode: filteredresultPostalCode.value[indexPath.row].value)
            router.dismiss(area, interactor.type)
        default:
            let area = filteredresult.value[indexPath.row]
            router.dismiss(area, interactor.type)
        }
	}
	
	func fetchResult(){
		switch interactor.type {
		case .province:
			interactor.provinsiResponse().subscribe { [weak self] (areaResult) in
				self?.result.accept(areaResult.data?.content ?? [])
			} onError: { [weak self] (error) in
				self?.errorRelay.accept(error)
			}.disposed(by: disposeBag)
		case .city:
			interactor.kotaResponse().subscribe { [weak self] (areaResult) in
				self?.result.accept(areaResult.data?.content ?? [])
			} onError: { [weak self] (error) in
				self?.errorRelay.accept(error)
			}.disposed(by: disposeBag)
		case .subdistrict:
			interactor.kecamatanResponse().subscribe { [weak self] (areaResult) in
				self?.result.accept(areaResult.data?.content ?? [])
			} onError: { [weak self] (error) in
				self?.errorRelay.accept(error)
			}.disposed(by: disposeBag)
		case .postalCode:
			interactor.postalCodeResponse().subscribe { [weak self] (areaResult) in
                self?.resultPostalCode.accept(areaResult.data.postalCodes )
			} onError: { [weak self] (error) in
				self?.errorRelay.accept(error)
			}.disposed(by: disposeBag)
		default:
			return
		}
	}
	
	func search(){
		switch interactor.type {
		case .postalCode:
			searchValueObservable.asObservable().subscribe(onNext: { [weak self] value in
				self?.resultPostalCodeObservable.map({ (areas) in
					areas.filter { (area) -> Bool in
						if value.isEmpty { return true }
                        return (area.value.lowercased().contains(value.lowercased()))
					}
				}).bind(to: self!.filteredresultPostalCode).disposed(by: self!.disposeBag)
				}).disposed(by: disposeBag)
		default :
			searchValueObservable.asObservable().subscribe(onNext: { [weak self] value in
				self?.resultObservable.map({ (areas) in
					areas.filter { (area) -> Bool in
						if value.isEmpty { return true }
						return (area.name?.lowercased().contains(value.lowercased()))!
					}
				}).bind(to: self!.filteredresult).disposed(by: self!.disposeBag)
				}).disposed(by: disposeBag)
		}
	}
}
