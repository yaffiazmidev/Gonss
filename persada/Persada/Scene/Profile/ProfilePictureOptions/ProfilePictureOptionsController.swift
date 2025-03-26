//
//  ProfileImageOptionsController.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 15/12/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit
import KipasKipasShared

protocol ProfilePictureOptionsDelegate {
    func didTapPicture(image: UIImage?)
    func didTapCamera()
    func didTapLibrary()
    func didTapDonationBadge()
}

class ProfilePictureOptionsController: CustomHalfViewController {
    
    let mainView: ProfilePictureOptionsView
    
    var delegate: ProfilePictureOptionsDelegate?
    var image: UIImage? {
        didSet {
            mainView.imageView.image = image
        }
    }
    
    required init() {
        mainView = ProfilePictureOptionsView()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        canSlideUp = false
        viewHeight = 352
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupOnTap()
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        containerView.addSubviews([mainView.cancelView, mainView.dividerView, mainView.actionView, mainView.imageView])
        
        mainView.cancelView.anchor(
            bottom: containerView.safeAreaLayoutGuide.bottomAnchor,
            paddingBottom: 4,
            width: 64,
            height: 32
        )
        mainView.cancelView.centerXTo(containerView.centerXAnchor)
        
        mainView.dividerView.anchor(
            left: containerView.leftAnchor,
            bottom: mainView.cancelView.topAnchor,
            right: containerView.rightAnchor,
            paddingBottom: 20,
            height: 1
        )
        
        mainView.actionView.anchor(
            bottom: mainView.dividerView.topAnchor,
            paddingBottom: 40
        )
        mainView.actionView.centerXTo(containerView.centerXAnchor)
        
        mainView.imageView.anchor(
            bottom: mainView.actionView.topAnchor,
            paddingBottom: 40,
            width: 100,
            height: 100
        )
        mainView.imageView.centerXTo(containerView.centerXAnchor)
    }
}

extension ProfilePictureOptionsController {
    func setupOnTap() {
        mainView.cancelView.onTap {
            self.animateDismissView()
        }
        
        mainView.cameraView.onTap {
            self.animateDismissView {
                self.delegate?.didTapCamera()
            }
        }
        
        mainView.libraryView.onTap {
            self.animateDismissView {
                self.delegate?.didTapLibrary()
            }
        }
        
        mainView.badgeView.onTap {
            self.animateDismissView {
                self.delegate?.didTapDonationBadge()
            }
        }
        
        mainView.imageView.onTap {
            self.animateDismissView {
                self.delegate?.didTapPicture(image: self.mainView.imageView.image)
            }
        }
    }
}
