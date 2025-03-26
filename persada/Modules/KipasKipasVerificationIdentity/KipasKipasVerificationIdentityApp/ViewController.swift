//
//  ViewController.swift
//  KipasKipasVerificationIdentityApp
//
//  Created by DENAZMI on 28/05/24.
//

import UIKit
import KipasKipasVerificationIdentityiOS
import KipasKipasCamera

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigateToMainScene()
    }
    
    @IBAction func didClickGoButton(_ sender: Any) {
        navigateToMainScene()
    }
    
    private func navigateToMainScene() {
        let vc = VerifyIdentityCameraController(cameraType: .identity)
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
}

