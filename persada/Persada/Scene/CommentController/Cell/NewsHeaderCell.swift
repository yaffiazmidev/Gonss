//
//  NewsHeaderCell.swift
//  Persada
//
//  Created by Muhammad Noor on 06/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import IGListKit

class NewsHeaderCell: UICollectionViewCell, ListBindable {
    
    // MARK: - Public Property
    
    let titleLabel: UILabel = {
        let lbl = UILabel(frame: .zero)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = .Roboto(.medium, size: 26)
        lbl.numberOfLines = 0
        lbl.textColor = .black
        return lbl
    }()
    
    var imagePost : AGVideoPlayerView = {
        let image = AGVideoPlayerView(frame: .zero)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = 20
        image.backgroundColor = .gray
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        image.shouldSwitchToFullscreen = true
        image.shouldAutoplay = true
        image.shouldAutoRepeat = false
        return image
    }()
    
    var mediaView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 20
        view.backgroundColor = .gray
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    lazy var sourceLabel: UILabel = {
        let label: UILabel = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .Roboto(.medium, size: 12)
        label.textColor = .placeholder
        return label
    }()
    let image = UIImageView(frame: .zero)
    
    // MARK: - Public Method
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        
        [titleLabel, mediaView, sourceLabel].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0)
        
        sourceLabel.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 20, paddingBottom: 8, paddingRight: 20, width: 0, height: 20)
        
        mediaView.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: sourceLabel.topAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 20, paddingBottom: 12, paddingRight: 20, width: 0, height: 0)
    }
    
    func configure(title: String, date: String, source: String, mediaURL: String, type: String, thumbnail: String) {
        titleLabel.text = title
        if type == "image" {
            mediaView.addSubview(image)
            image.clipsToBounds = true
            image.contentMode = .scaleAspectFill
            image.fillSuperview()
            image.loadImage(at: mediaURL, low: thumbnail)
        } else {
            mediaView.addSubview(imagePost)
            imagePost.fillSuperview()
            imagePost.showsCustomControls = true
            imagePost.videoUrl = URL(string: mediaURL)
            imagePost.previewLowImageUrl = URL(string: mediaURL)
            imagePost.previewImageUrl = URL(string: mediaURL)
            imagePost.showsCustomControls = true
        }
        sourceLabel.text = "\(date)  Sumber - \(source)"
    }
    

    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? NewsHeaderViewModel else { return }
        self.configure(title: viewModel.title, date: viewModel.date, source: viewModel.source, mediaURL: viewModel.mediaURL, type: viewModel.type, thumbnail: viewModel.thumbnail)
    }

}
