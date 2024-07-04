//
//  FilterButton.swift
//  
//
//  Created by Rashid Khan on 06/06/2024.
//

import UIKit

extension UIFactory {
    static func makeImageButton(titleFont: UIFont = UIFont.SFProDisplaySemiBoldFont(14),
                                filtersCountFont: UIFont = UIFont.SFProDisplaySemiBoldFont(12),
                                title: String,
                                image: UIImage?,
                                count: Int
    ) -> FilterButton {
                                    
        let button = FilterButton(frame: .zero)
        button.titleLabel.text = title
        button.imageViewIcon.image = image
        button.titleLabel.font = titleFont
        button.filterCountLablel.font = filtersCountFont
        button.updateApplyCount(count)
        return button
    }
}

class FilterButton: UIView {
    private var containerView = UIFactory.makeView(with: ApplicationTheme.currentTheme.newUIrecipelightGrayBGColor, cornerRadiusStyle: .radius(15))
    var imageViewIcon = UIFactory.makeImageView(contentMode: .scaleAspectFit)
    var titleLabel = UIFactory.makeLabel(font: UIFont.SFProDisplaySemiBoldFont(14), text: "Filter")
    private var appliedFilterView = UIFactory.makeView(with: .black, cornerRadiusStyle: .radius(10))
    var filterCountLablel = UIFactory.makeLabel(font: UIFont.SFProDisplaySemiBoldFont(12), alignment: .center)
    
    var tapHandler: (()->Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.addSubview(containerView)
        containerView.addSubviews([imageViewIcon, titleLabel, appliedFilterView])
        appliedFilterView.addSubview(filterCountLablel)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 30),
            
            imageViewIcon.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            imageViewIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            imageViewIcon.heightAnchor.constraint(equalToConstant: 16),
            imageViewIcon.widthAnchor.constraint(equalToConstant: 16),
            
            titleLabel.leadingAnchor.constraint(equalTo: imageViewIcon.trailingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            appliedFilterView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            appliedFilterView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            appliedFilterView.heightAnchor.constraint(equalToConstant: 20),
            appliedFilterView.widthAnchor.constraint(equalToConstant: 20),
            
            filterCountLablel.centerXAnchor.constraint(equalTo: appliedFilterView.centerXAnchor),
            filterCountLablel.centerYAnchor.constraint(equalTo: appliedFilterView.centerYAnchor),
        ])
        
        containerView.isUserInteractionEnabled = true
        containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
        
        appliedFilterView.isHidden = true
        filterCountLablel.textColor = .navigationBarWhiteColor()
    }
    
    func updateApplyCount(_ count: Int) {
        self.appliedFilterView.isHidden = count <= 0
        self.imageViewIcon.isHidden = count > 0
        self.filterCountLablel.text = "\(count)"
    }
    
    @objc func didTap(_ sender: UITapGestureRecognizer) { tapHandler?() }
}
