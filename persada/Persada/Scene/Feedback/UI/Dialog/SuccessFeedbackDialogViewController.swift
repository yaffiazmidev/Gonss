//
//  SuccessFeedbackDialogViewController.swift
//  KipasKipas
//
//  Created by PT.Koanba on 07/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

class SuccessFeedbackDialogViewController: UIViewController {
    
    @IBOutlet weak var viewDialogBackground: UIView!
    
    init() {
        super.init(nibName: "SuccessFeedbackDialogViewController", bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        viewDialogBackground.layer.cornerRadius = 6.0
    }


    @IBAction func buttonOkeAction(_ sender: UIButton) {
        dismiss(animated: true)
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
