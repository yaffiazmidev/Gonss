//
//  AuthPopUpViewController.swift
//  KipasKipas
//
//  Created by batm batmandiri on 19/03/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class ReportPopupViewController: UIViewController {
    
    private var mainView: ReportPopupView
    
    required init(mainView: ReportPopupView) {
        self.mainView = mainView
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        mainView.delegate = self
        self.hideKeyboardWhenTappedAround()
    }
    
    override func loadView() {
        view = mainView
    }
}

extension ReportPopupViewController: PopupReportDelegate {
    
    func closePopUp() {
        self.dismiss(animated: false, completion: nil)
    }
}
