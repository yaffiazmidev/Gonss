//
//  NotificationPreferencesDialogViewController.swift
//  KipasKipas
//
//  Created by PT.Koanba on 16/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

class NotificationPreferencesDialogViewController: UIViewController {

    private let onCancelClick: () -> Void
    private let onSettingClick: () -> Void
    
    init(onCancelClick: @escaping () -> Void, onSettingClick: @escaping () -> Void) {
        self.onCancelClick = onCancelClick
        self.onSettingClick = onSettingClick
        
        super.init(nibName: "NotificationPreferencesDialogViewController", bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        registeTapDismissGesture()
    }
    
    private func registeTapDismissGesture() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
        
        gestureRecognizer.cancelsTouchesInView = false
        
        self.view.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCancelClick(_ sender: UIButton) {
        onCancelClick()
        close()
    }
    
    @IBAction func onSettingClick(_ sender: Any) {
        onSettingClick()
        close()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
