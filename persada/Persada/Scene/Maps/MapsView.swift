//
//  MapsView.swift
//  KipasKipas
//
//  Created by PT.Koanba on 24/05/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class MapsView : UIView, UITextFieldDelegate {
    
    
    @IBOutlet weak var textFieldLocationSearch: UITextField!
    @IBOutlet weak var buttonLocationSave: PrimaryButton!
    @IBOutlet weak var viewMaps: UIView!
    
    var onClickSearch: (() -> Void)?
    var onClickSave: (() -> Void)?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    static func loadViewFromNib() -> MapsView {
                    let bundle = Bundle(for: self)
                    let nib = UINib(nibName: "MapsView", bundle: bundle)
                    return nib.instantiate(withOwner: self, options: nil).first as! MapsView
            }
    

    func initView(){
        textFieldLocationSearch.delegate = self
        textFieldLocationSearch.isUserInteractionEnabled = true
        textFieldLocationSearch.attributedPlaceholder = NSAttributedString(string: "Cari lokasi...",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.black25])
        
        
        let imageView = UIImageView(image: UIImage(named: .get(.iconSearch)))
        imageView.contentMode = .left
        if let size = imageView.image?.size {
            imageView.frame = CGRect(x: 0.0, y: 0.0, width: size.width + 10.0, height: size.height)
        }
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        textFieldLocationSearch.addSubview(imageView)
        
        imageView.anchor(top: textFieldLocationSearch.topAnchor, bottom: textFieldLocationSearch.bottomAnchor, right: textFieldLocationSearch.rightAnchor, paddingRight : 10)
//        textFieldLocationSearch.rightView = imageView
//        textFieldLocationSearch.rightViewMode = .always
        textFieldLocationSearch.layer.borderColor = UIColor.whiteSmoke.cgColor
        textFieldLocationSearch.layer.borderWidth = 1
        textFieldLocationSearch.layer.cornerRadius = 8
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
    
    @IBAction func searchTapped(_ sender: UITextField) {
        self.onClickSearch?()
    }
    
    @IBAction func saveTapped(_ sender: UIButton) {
        self.onClickSave?()
    }
}
