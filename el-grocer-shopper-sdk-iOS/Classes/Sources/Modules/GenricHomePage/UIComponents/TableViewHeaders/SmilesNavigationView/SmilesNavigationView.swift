//
//  SmilesNavigationView.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 19/11/2023.
//

import Foundation

class SmilesNavigationView: UIView {
    lazy var profileButton: UIButton = {
        let button = UIButton()
        let image = UIImage(name: "menu")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var titleView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var leftTitleImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(name: "NavBarElgrocerIconShopper")
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var leftTitle: UILabel = {
        let label = UILabel()
        label.text = ""
        label.setH3SemiBoldStyle()
        label.textColor = ApplicationTheme.currentTheme.themeBasePrimaryBlackColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var smilesPointsView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.colorWithHexString(hexString: "423B79")
        view.layer.cornerRadius = 13.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var emojiView: UIImageView = {
        let view = UIImageView(image: UIImage(name: "smiles_face"))
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .clear
//        view.contentMode = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var lblSmilesPoint: UILabel = {
        let label = UILabel()
        label.text = localizedString("earn_rewards_now", comment: "")
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    convenience init () {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        self.addViews()
        self.setupConstraint()
    }
    
    internal required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.backgroundColor = .white
        self.addViews()
        self.setupConstraint()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let frame = self.superview?.bounds {
            self.frame = frame
        }
    }
    
    private func addViews() {
        
        self.addSubview(self.leftTitleImage)
        self.addSubview(self.leftTitle)
        self.addSubview(self.profileButton)
        self.addSubview(self.titleView)
        
        self.titleView.addSubview(self.smilesPointsView)
        
        self.smilesPointsView.addSubview(self.emojiView)
        self.smilesPointsView.addSubview(self.lblSmilesPoint)
    }
    
    private func setupConstraint() {
        
        NSLayoutConstraint.activate([
            profileButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            profileButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            profileButton.heightAnchor.constraint(equalToConstant: 45),
            profileButton.widthAnchor.constraint(equalTo: profileButton.heightAnchor)
        ])
        
        NSLayoutConstraint.activate([
            leftTitleImage.centerYAnchor.constraint(equalTo: profileButton.centerYAnchor),
            leftTitleImage.leadingAnchor.constraint(equalTo: profileButton.trailingAnchor, constant: 3),
            leftTitleImage.heightAnchor.constraint(equalToConstant: 20),
            leftTitleImage.widthAnchor.constraint(equalTo: leftTitleImage.heightAnchor),
        ])
        
        NSLayoutConstraint.activate([
            leftTitle.centerYAnchor.constraint(equalTo: leftTitleImage.centerYAnchor, constant: 2),
            leftTitle.leadingAnchor.constraint(equalTo: leftTitleImage.trailingAnchor, constant: 7),
            leftTitle.heightAnchor.constraint(equalToConstant: 45)
        ])
        
        NSLayoutConstraint.activate([
            titleView.centerYAnchor.constraint(equalTo: profileButton.centerYAnchor),
            titleView.leadingAnchor.constraint(equalTo: leftTitle.trailingAnchor, constant: 4),
            titleView.heightAnchor.constraint(equalToConstant: 26),
        ])
        
        NSLayoutConstraint.activate([
            emojiView.centerYAnchor.constraint(equalTo: profileButton.centerYAnchor),
            emojiView.leadingAnchor.constraint(equalTo: smilesPointsView.leadingAnchor, constant: 1),
            emojiView.topAnchor.constraint(equalTo: smilesPointsView.topAnchor, constant: 1),
            emojiView.bottomAnchor.constraint(equalTo: smilesPointsView.bottomAnchor, constant: -1),
            emojiView.widthAnchor.constraint(equalTo: emojiView.heightAnchor),
        ])
        
        NSLayoutConstraint.activate([
            lblSmilesPoint.centerYAnchor.constraint(equalTo: profileButton.centerYAnchor),
            lblSmilesPoint.leadingAnchor.constraint(equalTo: emojiView.trailingAnchor, constant: 6),
            lblSmilesPoint.trailingAnchor.constraint(equalTo: self.smilesPointsView.trailingAnchor, constant: -6),
        ])
        
        NSLayoutConstraint.activate([
            smilesPointsView.centerYAnchor.constraint(equalTo: profileButton.centerYAnchor),
            smilesPointsView.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 8),
            smilesPointsView.heightAnchor.constraint(equalToConstant: 26),
            smilesPointsView.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: -8),
        ])
    }
    
    func setSmilesPoints(_ points: Int) {
        self.lblSmilesPoint.text = points == -1 ? localizedString("earn_rewards_now", comment: "") : String(points)
    }
    
    func setLeftTitle(_ text: String) {
        self.leftTitle.text = text
    }
}
