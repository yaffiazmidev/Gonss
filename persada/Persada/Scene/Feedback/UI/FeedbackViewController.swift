//
//  FeedbackViewController.swift
//  KipasKipas
//
//  Created by PT.Koanba on 06/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController {

    @IBOutlet weak var labelFeedbackCounter: UILabel!
    @IBOutlet weak var buttonSubmitFeedback: UIButton!
    @IBOutlet weak var labelTextViewPlaceholder: UILabel!
    @IBOutlet weak var loadingSendButton: UIActivityIndicatorView!
    @IBOutlet weak var viewTextfieldBackground: UIView!
    @IBOutlet weak var textViewFeedback: UITextView!
    
    var onSubmitSuccess: (() -> Void)?
    
    private let delegate: FeedbackViewDelegate
    

    init(delegate: FeedbackViewDelegate) {
        self.delegate = delegate
        super.init(nibName: "FeedbackViewController", bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupView()
    }
    
    private func setupView() {
        viewTextfieldBackground.layer.cornerRadius = 6
        viewTextfieldBackground.layer.borderWidth = 1.0
        viewTextfieldBackground.layer.borderColor = UIColor.whiteSmoke.cgColor
        
        textViewFeedback.delegate = self
        
        title = "Kirim Feedback"

        let backImage = UIImage(named: "arrowleft")?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(self.back))
    }
    
    @objc
    func back(){
        self.navigationController?.popViewController(animated: true)
    }


    @IBAction func addFeedbackAction(_ sender: UIButton) {
        sendFeedback()
    }

    private func sendFeedback() {
        if let text = textViewFeedback.text, text.count > 0 {
            let request = FeedbackSenderRequest.create(with: text)
            delegate.didSendFeedback(request: request)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .notificationUpdateEmail, object: nil)
    }
}

extension FeedbackViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        labelTextViewPlaceholder.isHidden = !textViewFeedback.text.isEmpty
        
        guard let text = textView.text else  {
            return
        }
        let totalLength = text.count
        updateLabelCount(for: totalLength)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars <= 2000
    }
    
    private func updateLabelCount(for currentCount: Int) {
        labelFeedbackCounter.text = "\(currentCount)/2000"
        updateButtonState(for: currentCount)
    }
    
    private func updateButtonState(for currentCount: Int) {
        let removedSpacesString = textViewFeedback.text.trimmingCharacters(in: .whitespaces)
        let removedNewLinesString = removedSpacesString.trimmingCharacters(in: .newlines)
        let isWhiteSpacesOrNewLinesOnly =  removedNewLinesString.isEmpty
        if isWhiteSpacesOrNewLinesOnly {
            setSendButtonInActive()
        } else if currentCount <= 0 {
            setSendButtonInActive()
        } else {
            setSendButtonActive()
        }
    }
    
    private func setSendButtonInActive() {
        buttonSubmitFeedback.backgroundColor = .whiteSnow
        buttonSubmitFeedback.setTitleColor(.placeholder, for: .normal)
        buttonSubmitFeedback.isEnabled = false
    }
    
    private func setSendButtonActive() {
        buttonSubmitFeedback.backgroundColor = .primary
        buttonSubmitFeedback.setTitleColor(.white, for: .normal)
        buttonSubmitFeedback.isEnabled = true
    }
}

extension FeedbackViewController: FeedbackSenderView, FeedbackSenderLoadingView, FeedbackSenderErrorView {
    
    func display(_ viewModel: FeedbackSenderViewModels) {
        notifyRedDot()
        navigationController?.popViewController(animated: true)
        onSubmitSuccess?()
    }
    
    func display(_ viewModel: FeedbackSenderLoadingViewModel) {
        if viewModel.isLoading {
            updateToLoadingView()
        } else {
            revertToNormalView()
        }
    }
    
    func display(_ viewModel: FeedbackSenderLoadingErrorViewModel) {
        if viewModel.message != nil {
            showErrorDialog()
        }
    }
    
    private func notifyRedDot(){
        NotificationCenter.default.post(name: .notificationUpdateEmail, object: nil)
    }
    
    private func showErrorDialog() {
        let failedDialog = FeedbackFailedDialogViewController {
            
        } onResendClick: { [weak self] in
            guard let self = self else { return }
            self.sendFeedback()
        }
        present(failedDialog, animated: true)
    }
    
    private func updateToLoadingView() {
        loadingSendButton.startAnimating()
        buttonSubmitFeedback.setTitle("", for: .normal)
    }
    
    private func revertToNormalView() {
        loadingSendButton.stopAnimating()
        buttonSubmitFeedback.setTitle("Kirim Feedback", for: .normal)
    }
}
