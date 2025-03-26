//
//  NewsDetailSeeSourceButton.swift
//  KipasKipas
//
//  Created by PT.Koanba on 03/08/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class NewsDetailSeeSourceButton: UITableViewCell {
    
    // MARK: - Public Property
    
    let button: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .Roboto(.regular, size: 16)
        button.backgroundColor = .whiteSmoke
        button.text(.get(.lihatSumberBerita))
        button.setTitleColor(.contentGrey, for: .normal)
        return button
    }()

    
    let view = UIView()
    
    // MARK: - Public Method
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        view.backgroundColor = .whiteSmoke
        [button, view].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        button.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: UIScreen.main.bounds.width, height: 56)
        view.anchor(top: button.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: UIScreen.main.bounds.width, height: 34)
    }
    
    func configure(url: String) {
        button.onTap {
            guard let url = URL(string: url) else {
              return
            }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    


}


class BlankCell: UITableViewCell {
    
    // MARK: - Public Property
    
    let view = UIView()

    
    // MARK: - Public Method
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        selectionStyle = .none
        backgroundColor = .white
        [view].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        view.backgroundColor = .white
        
        view.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: UIScreen.main.bounds.width, height: 76)
    }

}
