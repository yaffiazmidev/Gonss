//
//  ShareViewController.swift
//  KipasKipasShareExtension
//
//  Created by Rahmat Trinanda Pramudya Amar on 09/11/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {
    private lazy var mainView = { ShareView() }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func isContentValid() -> Bool {
        print("ShareViewController - isContentValid")
        return true
    }
    
    override func didSelectPost() {
        print("ShareViewController - didSelectPost")
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    override func configurationItems() -> [Any]! {
        print("ShareViewController - configurationItems")
        return []
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadMedia()
        print("ShareViewController - viewWillAppear")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("ShareViewController - viewWillDisappear")
    }
}

// MARK: - View
extension ShareViewController: ShareViewDelegate {
    private func setupView() {
        view = mainView
        mainView.delegate = self
        setupShadow()
        mainView.showLoading()
    }
    
    private func setupShadow() {
        if UIAccessibility.isReduceTransparencyEnabled == false {
            view.backgroundColor = .clear
            let blurEffect = UIBlurEffect(style: .dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.insertSubview(blurEffectView, at: 0)
        } else {
            view.backgroundColor = .black
        }
    }
    
    func onDismiss() {
        didSelectPost()
    }
}

// MARK: - Helper
private extension ShareViewController {
    private func urlScheme() -> String {
        let scheme = "kipasapp://"
        if let id = Bundle.main.bundleIdentifier {
            if id.contains("dev") {
                return "dev\(scheme)"
            }
            if id.contains("staging") {
                return "stg\(scheme)"
            }
        }
        return scheme
    }
    
    private func group() -> String {
        return "group.\(Bundle.main.bundleIdentifier ?? "com.koanba.kipaskipas.mobile.KipasKipasShareExtension")"
    }
    
    private func invokeApp(with mediaPaths: Dictionary<String, [String]>) {
        print("ShareViewController invokeApp paths", mediaPaths)
        guard !mediaPaths.isEmpty else {
            print("ShareViewController attachment supported is empty")
            mainView.showMessage()
            return
        }
        
        guard let dataPaths = try? JSONSerialization.data(withJSONObject: mediaPaths, options: []),
              let stringPaths = String(data: dataPaths, encoding: .utf8),
              let encodedPaths = stringPaths.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(urlScheme())postMedias?paths=\(encodedPaths)")
        else {
            print("ShareViewController failure convert dictionary to json")
            mainView.showMessage()
            return
        }
        
        print("ShareViewController invokeApp url", String(describing: url))
        openApp(url: url)
    }
    
    private func openApp(url: URL?) {
        let sharedSelector = NSSelectorFromString("sharedApplication")
        let openSelector = NSSelectorFromString("openURL:")
        
        if let url = url,
           UIApplication.responds(to: sharedSelector),
           let shared = UIApplication.perform(sharedSelector)?.takeRetainedValue() as? UIApplication,
           shared.responds(to: openSelector) {
            
            shared.perform(openSelector, with: url)
        }
        didSelectPost()
    }
}

// MARK: - Media Handler
private extension ShareViewController {
    private func loadMedia() {
        print("ShareViewController loadMedia")
        guard let item = self.extensionContext?.inputItems.first as? NSExtensionItem,
              let attachments = item.attachments else {
            mainView.showMessage()
            return
        }
        
        var paths: [String: [String]] = ["videos": [], "photos": []]
        var attachmentLoaded = 0
        
        for attachment in attachments {
            for identifier in attachment.registeredTypeIdentifiers {
                load(for: attachment, with: identifier) { type, path  in
                    paths[type]?.append(path)
                    attachmentLoaded+=1
                    
                    if attachmentLoaded >= attachments.count { // has loaded
                        self.invokeApp(with: paths)
                    }
                }
            }
        }
    }
    
    private func load(for attachment: NSItemProvider, with identifier: String, completion: @escaping (_ type: String, _ path: String) -> Void) {
        let imageType = [kUTTypeJPEG, kUTTypeJPEG2000, kUTTypeRawImage, kUTTypeTIFF, kUTTypeGIF, kUTTypePNG, kUTTypeICO] as [String]
        let videoType = [kUTTypeMovie, kUTTypeVideo, kUTTypeMPEG4, kUTTypeAppleProtectedMPEG4Video, kUTTypeAVIMovie, kUTTypeQuickTimeMovie] as [String]
        
        if imageType.contains(identifier) {
            path(for: attachment, with: identifier) { path in
                if let path = path {
                    completion("photos", path)
                    return
                }
            }
        }
        
        if videoType.contains(identifier) {
            path(for: attachment, with: identifier) { path in
                if let path = path {
                    completion("videos", path)
                    return
                }
            }
        }
    }
}

// MARK: - Image Handler
private extension ShareViewController {
    private func path(for attachment: NSItemProvider, with identifier: String, completion: @escaping (String?) -> Void) {
        attachment.loadItem(forTypeIdentifier: identifier, options: nil) { (coding, error) in
            guard let url = coding as? URL else {
                completion(nil)
                return
            }
            
            let path = self.save(url)
            completion(path)
        }
    }
    
    func save(_ url: URL) -> String? {
        guard let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: group()) else { return nil }
        
        let targetURL = directory.appendingPathComponent(url.lastPathComponent)
        
        do {
            if FileManager.default.fileExists(atPath: targetURL.path) {
                try FileManager.default.removeItem(at: targetURL)
            }
            try FileManager.default.copyItem(at: url, to: targetURL)
            return targetURL.absoluteString
        } catch {
            return nil
        }
    }
}
