//
//  StopBecomeResellerController.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 23/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit

class StopBecomeResellerController: UIViewController {
    
    private lazy var mainView: StopBecomeResellerViewUI = StopBecomeResellerViewUI(frame: self.view.bounds)
    
    private let delegate: StopBecomeResellerControllerDelegate
    private let params: RemoveResellerParams
    var dismissAction: (() -> Void)?

    init(delegate: StopBecomeResellerControllerDelegate, params: RemoveResellerParams) {
        self.delegate = delegate
        self.params = params
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupHandleAction() {
        mainView.yesButton.onTap { [weak self] in
            guard let self = self else { return }
            
            self.delegate.didStopBecomeReseller(request: ResellerProductRemoveRequest(id: self.params.id))
        }
        
        mainView.noButton.onTap { [weak self] in
            guard let self = self else { return }
            
            self.dismiss(animated: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHandleAction()
    }
    
    override func loadView() {
        super.loadView()
        view = mainView
    }
}

extension StopBecomeResellerController: StopBecomeResellerView, StopBecomeResellerLoadingErrorView {
    
    func display(_ viewModel: StopBecomeResellerViewModel) {
        if viewModel.item.message.containsIgnoringCase(find: "General Success") {
            dismissAction?()
            dismiss(animated: true)
        }
    }
    
    func display(_ viewModel: StopBecomeResellerLoadingErrorViewModel) {
        DispatchQueue.main.async { Toast.share.show(message: viewModel.message ?? .get(.somethingWrong)) }
    }
}
