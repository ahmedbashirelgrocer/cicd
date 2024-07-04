//
//  TitleView.swift
//  
//
//  Created by Rashid Khan on 06/06/2024.
//

import UIKit

class TitleView: UIView {
    private var containerView = UIFactory.makeView()
    var titleText = UIFactory.makeLabel(font: UIFont.SFProDisplaySemiBoldFont(16), text: localizedString("all_products", comment: ""))
    var filterButton = UIFactory.makeImageButton(title: localizedString("btn_filter_title", comment: ""), image: UIImage(name: "filter_alt"), count: 0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(containerView)
        containerView.addSubviews([titleText, filterButton])
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 30),
            
            titleText.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleText.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            filterButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            filterButton.centerYAnchor.constraint(equalTo: titleText.centerYAnchor),
        ])
        
        filterButton.tapHandler = { [weak self] in }
    }
}
