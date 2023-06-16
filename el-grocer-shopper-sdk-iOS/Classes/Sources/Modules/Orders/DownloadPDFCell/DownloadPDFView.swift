//
//  DownloadPDFView.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 16/06/2023.
//

import UIKit

class DownloadPDFView: UIView {

    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Download tax invoice"
        label.setBody3BoldSecondaryDarkGreenColorStyle()
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 2),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -2),
            imageView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1),
            imageView.heightAnchor.constraint(equalToConstant: 20),
            
            textLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: -2),
            textLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: 0),
            textLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }

}
