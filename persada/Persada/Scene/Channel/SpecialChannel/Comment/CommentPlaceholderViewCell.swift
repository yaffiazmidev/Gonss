//
//  CommentPlaceholderViewCell.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 21/06/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

class CommentPlaceholderViewCell: UICollectionViewCell{
    @IBOutlet var label: UILabel!
    @IBOutlet var loading: UIActivityIndicatorView!
    
    static let className = "CommentPlaceholderViewCell"
    static let idCell = "commentPlaceholderViewCell"
    
    func setViewByState(_ state: CommentState){
        switch state{
        case .empty:
            label.text = "Belum ada komentar"
            label.isHidden = false
            loading.isHidden = true
        case .loading:
            label.text = nil
            label.isHidden = true
            loading.isHidden = false
            loading.startAnimating()
        case .hasData:
            break
        }
    }
    
    func setLabel(text: String){
        self.label.text = text
    }
}
