//
//  KKPopUpViewViewController.swift
//  KipasKipasDirectMessageUI
//
//  Created by DENAZMI on 26/07/23.
//

import UIKit

public class KKPopUpViewViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var cancelButton: KKDefaultButton!
    @IBOutlet weak var actionButton: KKDefaultButton!
    
    @IBOutlet weak var popUpImageView: UIImageView!
    @IBOutlet weak var popUpImageViewHeightConstraint: NSLayoutConstraint!
    public var handleTapActionButton: (() -> Void)?
    public var handleTapCancelButton: (() -> Void)?
    public var handleTapCloseButton: (() -> Void)?
    
    private var popUpTile: String
    private var message: String
    private var cancelButtonTitle: String
    private var actionButtonTitle: String
    private let isHiddenCancelButton: Bool
    private let imageName: String?
    private let imageHeight: CGFloat
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    public init(
        title: String,
        message: String,
        isHiddenCancelButton: Bool = false,
        imageName: String? = nil,
        imageHeight: CGFloat = 57,
        cancelButtonTitle: String = "Batalkan",
        actionButtonTitle: String = "OK")
    {
        self.popUpTile = title
        self.message = message
        self.isHiddenCancelButton = isHiddenCancelButton
        self.imageName = imageName
        self.imageHeight = imageHeight
        self.cancelButtonTitle = cancelButtonTitle
        self.actionButtonTitle = actionButtonTitle
        super.init(nibName: "KKPopUpViewViewController", bundle: SharedBundle.shared.bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        titleLabel.text = popUpTile
        messageLabel.text = message
        cancelButton.isHidden = isHiddenCancelButton
        cancelButton.setTitle(cancelButtonTitle, for: .normal)
        actionButton.setTitle(actionButtonTitle, for: .normal)
        popUpImageView.setImage(imageName ?? "empty")
        popUpImageView.isHidden = imageName == nil
        popUpImageViewHeightConstraint.constant = imageHeight
        view.layoutIfNeeded()
    }
    
    @IBAction func didClickCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: handleTapCancelButton)
    }
    
    @IBAction func didClickActionButton(_ sender: Any) {
        dismiss(animated: true, completion: handleTapActionButton)
    }
    
    @IBAction func didClickCloseButton(_ sender: Any) {
        dismiss(animated: true, completion: handleTapCloseButton)
    }
    
}
