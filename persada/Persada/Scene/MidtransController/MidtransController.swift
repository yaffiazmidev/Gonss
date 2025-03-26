//
//  MidtransController.swift
//  KipasKipas
//
//  Created by kuh on 05/05/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import WebKit
import UIKit

class MidtransController: BaseController, Controller {
    private var webview: WKWebView!
    var viewModel = MidtransViewModel()
    private var ghostBackTapHandlerView: UIView?
    private var doneButtonTapHandler: UIView?

    override func loadView() {
        super.loadView()
        webview = WKWebView()
        webview.allowsLinkPreview = false
        view.addSubview(webview)
        webview.frame = view.frame
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoading()
        webview.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
        loadUrl()
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let url = change?[NSKeyValueChangeKey.newKey] as? NSURL,
           let urlString = url.absoluteString {
            if urlString.contains("order-summary") {
                setupBackTapGesture()
                return
            }
            if urlString.contains("success") {
                setupDoneButtonTapHandler()
                return
            }
            if urlString.contains("status_code=200&transaction_status=capture") {
                viewModel.onComplete()
                return
            }
            self.ghostBackTapHandlerView?.removeFromSuperview()
            self.doneButtonTapHandler?.removeFromSuperview()
        }
    }

    private func loadUrl() {
        guard let url = URL(string: viewModel.urlString) else {
            viewModel.onError("something went wrong...")
            return
        }
        webview.load(URLRequest(url: url))
        webview.allowsBackForwardNavigationGestures = true
    }

    private func setupBackTapGesture() {
        let tapView = UIView()
        tapView.backgroundColor = .clear
        tapView.onTap(action: viewModel.onCancel)
        self.ghostBackTapHandlerView = tapView
        webview.addSubview(tapView)
        tapView.anchor(
            .top(view.safeAreaLayoutGuide.topAnchor),
            .leading(view.safeAreaLayoutGuide.leadingAnchor)
        )
        tapView.heightAnchor.constraint(equalToConstant: 54).isActive = true
        tapView.widthAnchor.constraint(equalToConstant: 48).isActive = true
    }

    private func setupDoneButtonTapHandler() {
        let tapView = UIView()
        tapView.backgroundColor = .clear
        tapView.onTap(action: viewModel.onComplete)
        self.doneButtonTapHandler = tapView
        webview.addSubview(tapView)
        tapView.anchor(
            .bottom(view.safeAreaLayoutGuide.bottomAnchor),
            .leading(view.safeAreaLayoutGuide.leadingAnchor),
            .trailing(view.safeAreaLayoutGuide.trailingAnchor)
        )
        tapView.heightAnchor.constraint(equalToConstant: 54).isActive = true
    }
}

