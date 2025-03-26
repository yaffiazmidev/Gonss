//
//  BrowserController.swift
//  Persada
//
//  Created by movan on 27/07/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import WebKit

public enum UrlType {
    case general
    case docs
    case info
}

public class BrowserController: UIViewController {
    var isUrlRequest = false
    public var isInvoice = false
    public var onBack: (() -> Void)?
    
    private var webView: WKWebView! {
        didSet {
            webView.translatesAutoresizingMaskIntoConstraints = true
            webView.isOpaque = false
            webView.backgroundColor = .white
            webView.scrollView.backgroundColor = .white
            
            view.addSubview(webView)
            
            webView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        }
    }
    
    private var progressView: UIProgressView! {
        didSet {
            progressView.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(progressView)
            
            progressView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width, height: 2)
        }
    }
    
    var url: String!
    var urlReq: URLRequest!
    
    public convenience init(url: String, urlReq: URLRequest? = nil, title: String? = nil, type: UrlType) {
        self.init(nibName:nil, bundle:nil)
        
        print("URL BROWSER CONTROLER \(url)")
        self.urlReq = urlReq
        self.title = title
        if url == "" {
            isUrlRequest = true
        }else{
            isUrlRequest = false
            switch type {
            case .general:
                self.url = url
            case .docs:
                self.url = url
            case .info:
                //				self.url = "http://KipasKipas.id/\(url)"
                self.url = "http://KipasKipas.id/"
            }
            
        }
    }
    
}

extension BrowserController: UIGestureRecognizerDelegate {
    
    public override func loadView() {
        super.loadView()
        
        view.backgroundColor = .white
        
        let pref = WKPreferences()
        pref.javaScriptEnabled = true
        
        let config = WKWebViewConfiguration()
        config.preferences = pref
        config.applicationNameForUserAgent = "Safari"
        webView = WKWebView(frame: view.frame, configuration: config)
        progressView = UIProgressView(progressViewStyle: .default)
        self.navigationController?.showBarIfNecessary()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        if isInvoice {
            let backButton = UIBarButtonItem(image: UIImage(named: .get(.iconClose)), style: .plain, target: self, action: #selector(BrowserController.back))
            
            
            let downloadButton = UIBarButtonItem(image: UIImage(named: .get(.iconDownload)), style: .plain, target: self, action: #selector(downloadInvoicePDF))
            let printButton = UIBarButtonItem(image: UIImage(named: .get(.iconPrinter)), style: .plain, target: self, action: #selector(downloadAndPrintInvoicePDF))
            
            self.navigationItem.hidesBackButton = true
            self.navigationItem.leftBarButtonItem = backButton
            self.navigationItem.rightBarButtonItems = [printButton, downloadButton]
        } else {
            let backButton = UIBarButtonItem(image: UIImage(named: .get(.arrowleft)), style: .plain, target: self, action: #selector(BrowserController.back))
            
            self.navigationItem.hidesBackButton = true
            self.navigationItem.leftBarButtonItem = backButton
        }
        
    }
    
    @objc
    func downloadInvoicePDF(){
        let time = Date().timeIntervalSince1970
        if !pdfFileAlreadySaved(url: url, fileName: "invoice-\(time)") {
            savePdf(urlString: url, fileName: "invoice-\(time)")
        }
    }
    
    @objc
    func downloadAndPrintInvoicePDF(){
        let time = Date().timeIntervalSince1970
        if !pdfFileAlreadySaved(url: url, fileName: "invoice-\(time)") {
            savePdf(urlString: url, fileName: "invoice-\(time)", printPDF: true)
        }
    }
    
    @objc
    func printPDF(url: URL) {
        if UIPrintInteractionController.canPrint(url) {
            let printInfo = UIPrintInfo(dictionary: nil)
            printInfo.jobName = url.lastPathComponent
            printInfo.outputType = .photo
            
            let printController = UIPrintInteractionController.shared
            printController.printInfo = printInfo
            printController.showsNumberOfCopies = false
            
            printController.printingItem = url
            
            printController.present(animated: true, completionHandler: nil)
        }
    }

    
    func savePdf(urlString:String, fileName:String, printPDF: Bool = false) {
            DispatchQueue.main.async {
                let url = URL(string: urlString)
                let pdfData = try? Data.init(contentsOf: url!)
                let resourceDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
                let pdfNameFromUrl = "KipasKipas-\(fileName).pdf"
                let actualPath = resourceDocPath.appendingPathComponent(pdfNameFromUrl)
                do {
                    try pdfData?.write(to: actualPath, options: .atomic)
                    print("pdf successfully saved!")
                    self.showToast(message: "Invoice Downloaded", font: .roboto(.regular, size: 10))
                    self.showSavedPdf(url: actualPath.absoluteString, fileName: "KipasKipas-\(fileName)", printPDF: printPDF)
                } catch {
                    print("Pdf could not be saved")
                    self.showToast(message: "Download Invoice Failed", font: .roboto(.regular, size: 10))
                }
            }
        }

    func showSavedPdf(url:String, fileName:String, printPDF: Bool = false) {
        do {
            let docURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let contents = try FileManager.default.contentsOfDirectory(at: docURL, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
            for url in contents {
                if url.description.contains("\(fileName).pdf") {
                    // its your file! do what you want with it!
                    let sharedurl = url.absoluteString.replacingOccurrences(of: "file://", with: "shareddocuments://")
                    if printPDF {
                        self.printPDF(url: url)
                    } else {
                        let documentInteractionController: UIDocumentInteractionController!
                        documentInteractionController = UIDocumentInteractionController.init(url: url)
                        documentInteractionController?.delegate = self
                        documentInteractionController?.presentPreview(animated: true)
                    }
                }
            }
        } catch {
            print("could not locate pdf file !!!!!!!")
        }
        
    }

    // check to avoid saving a file multiple times
    func pdfFileAlreadySaved(url:String, fileName:String)-> Bool {
        var status = false
        if #available(iOS 10.0, *) {
            do {
                let docURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let contents = try FileManager.default.contentsOfDirectory(at: docURL, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
                for url in contents {
                    if url.description.contains("KipasKipas-\(fileName).pdf") {
                        status = true
                    }
                }
            } catch {
                print("could not locate pdf file !!!!!!!")
            }
        }
        return status
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        webView.uiDelegate = self
        let value = webView.estimatedProgress
        let progress = Float(value)
        if progress == 1 {
            self.progressView.isHidden = true
        } else {
            self.progressView.isHidden = false
            self.progressView.progress = progress
        }
        print("URL Req : ", isUrlRequest)
        if isUrlRequest == false {
            webView.load(URLRequest(url: URL(string: url)!))
        }else{
            webView.load(urlReq)
        }
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    @objc public func back(sender: UIBarButtonItem) {
        onBack?()
        _ = navigationController?.popViewController(animated: false)
    }
    
}

extension BrowserController: WKNavigationDelegate, WKUIDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        print(navigationResponse.response)
        let headers = (navigationResponse.response as! HTTPURLResponse).allHeaderFields
        let req = URLRequest(url: navigationResponse.response.url!)
        print(headers)
        print(req)
        if req.description.contains("/close") {
            self.navigationController?.popViewController(animated: true)
        } else if (req.description.contains("status_code=201&transaction_status=pending")) {
            self.tabBarController?.tabBar.isHidden = false
            self.navigationController?.popToRootViewController(animated: false)
        }
        decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print(navigationAction.request)
        let urlRequest = navigationAction.request
        if urlRequest.description.contains("gojek://gopay/merchanttransfer") {
            UIApplication.shared.open(URL(string: navigationAction.request.description)!, options: [:])
        }
        decisionHandler(.allow)
    }
    
}

extension BrowserController: UIDocumentInteractionControllerDelegate {
    public func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}

fileprivate extension UIViewController {
    func showToast(message : String, font: UIFont) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 2.0, delay: 0.5, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

fileprivate extension UINavigationController {
    func showBarIfNecessary() {
        if self.isNavigationBarHidden {
            self.setNavigationBarHidden(false, animated: true)
        }
    }
}

