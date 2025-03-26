//
//  BaseController.swift
//  KipasKipas
//
//  Created by kuh on 05/05/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import Combine
import NVActivityIndicatorView

protocol Controller {
    associatedtype VM: BaseControllerViewModel
    var viewModel: VM { get set }
    func setupLoading()
}

extension Controller where Self: BaseController {
    func setupLoading() {
        viewModel
            .$isLoading
            .sink { isLoading in
                isLoading ? self.startLoading() : self.stopLoading()
            }.store(in: &cancellable)
    }
}

class BaseController: UIViewController {
    var cancellable = Set<AnyCancellable>()
    private lazy var loadingView = LoadingViewController()
    
    let loading = NVActivityIndicatorView(frame: .zero, type: .ballPulse, color: .primary, padding: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.addSubview(loading)
        loading.centerInSuperview(size: CGSize(width: 40, height: 40))
    }

    func startLoading() {
        loadingView.modalPresentationStyle = .overCurrentContext
        loadingView.modalTransitionStyle = .crossDissolve
        present(loadingView, animated: true, completion: nil)
    }

    func stopLoading() {
        loadingView.dismiss(animated: true, completion: nil)
    }
}
