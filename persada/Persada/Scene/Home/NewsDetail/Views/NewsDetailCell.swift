//
//  NewsDetailCell.swift
//  Persada
//
//  Created by Muhammad Noor on 06/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import WebKit

protocol UpdateNewsDetailHeightProtocol: AnyObject {
    func updateHeightOfRow(_ cell: NewsDetailCell, _ textView: UITextView)
    func updateHeight(height: CGFloat)
}

class NewsDetailCell: UITableViewCell {
    var myContext = 0
    
    @objc dynamic var webView : WKWebView = {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.contentMode = .scaleAspectFill
        webView.scrollView.isScrollEnabled = false
        return webView
    }()
    // MARK: - Public Property
    
    lazy var contentTextView: UITextView = {
        let textView = UITextView(frame: .zero)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.cornerRadius = 20
        textView.layer.masksToBounds = false
        textView.isUserInteractionEnabled = true
        textView.textColor = .black
        textView.isScrollEnabled = false
        textView.textAlignment = .justified
        textView.backgroundColor = .clear
        textView.isEditable = false
        return textView
    }()
    
    weak var cellDelegate: UpdateNewsDetailHeightProtocol?
    
    // MARK: - Public Method
    
    override func awakeFromNib() {
        super.awakeFromNib()
        

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
        webView.navigationDelegate = self
        contentTextView.delegate = self
        selectionStyle = .none
        addSubview(webView)
 
        webView.anchor(top: safeAreaLayoutGuide.topAnchor, left: safeAreaLayoutGuide.leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 16, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
    }
    
    var isCalled = false
    var heightTemp : CGFloat = 0.0
    
}

extension NewsDetailCell: UITextViewDelegate, WKNavigationDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if let delegate = cellDelegate {
            delegate.updateHeightOfRow(self, contentTextView)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
                self.webView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
                       if complete != nil {
                           self.webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
                            if let delegate = self.cellDelegate {
                                delegate.updateHeight(height: height as! CGFloat)
                            }
                           })
                       }
        
                })
    }
    

}
