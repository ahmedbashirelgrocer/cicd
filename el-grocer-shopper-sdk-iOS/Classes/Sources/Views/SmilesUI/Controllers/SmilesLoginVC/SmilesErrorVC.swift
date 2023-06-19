//
//  SmilesErrorVC.swift
//  ElGrocerShopper
//
//  Created by Sarmad Abbas on 15/10/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SmilesErrorVC: UIViewController {
    
    lazy var btnBack: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(name: "BackWhite"), for: .normal)
        return button
    }()
    
    lazy var backgroundGradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [#colorLiteral(red: 0.875736475, green: 0.2409847379, blue: 0.1460545063, alpha: 1).cgColor, #colorLiteral(red: 0.5716853142, green: 0.3168505132, blue: 0.5579631925, alpha: 1).cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        return gradient
    }()
    
    private lazy var logoView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(name: "smiles_logo_white")
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 22, weight: .medium)
        label.text = localizedString("Oops! Something went wrong on our side 🤔", comment: "")
        label.textColor = #colorLiteral(red: 0.9607843757, green: 0.9607843757, blue: 0.9607843757, alpha: 1)
        return label
    }()
    
    private lazy var detailsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = #colorLiteral(red: 0.9607843757, green: 0.9607843757, blue: 0.9607843757, alpha: 1)
        label.text = localizedString("We are fixing the problem.\nPlease, try again soon.", comment: "")
        return label
    }()
    
    private lazy var btnBottom: UIButton = {
        let button = UIButton()
        button.setTitle(localizedString("lbl_retry", comment: ""), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        let textColor: UIColor = #colorLiteral(red: 0.9559774995, green: 0.9609488845, blue: 0.9608611465, alpha: 1)
        button.setTitleColor(textColor, for: .normal)
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 1
        button.layer.borderColor = textColor.cgColor
        return button
    }()
    
    private lazy var spacers: [UIView] = [makeSpacer(), makeSpacer(), makeSpacer(), makeSpacer()]
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupLayouts()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        backgroundGradientLayer.frame = view.bounds
    }
    
    func setupViews() {
        view.backgroundColor = .white
        view.layer.insertSublayer(backgroundGradientLayer, at: 0)
        for i in 0..<spacers.count {
            view.addSubview(spacers[i])
        }
        view.addSubview(logoView)
        view.addSubview(titleLabel)
        view.addSubview(detailsLabel)
        view.addSubview(btnBottom)
        view.addSubview(btnBack)
    }
    
    func setupLayouts() {
        NSLayoutConstraint.activate([
            btnBack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            btnBack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            btnBack.heightAnchor.constraint(equalToConstant: 40),
            btnBack.widthAnchor.constraint(equalToConstant: 40)
        ])
        
        NSLayoutConstraint.activate([
            spacers[0].topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            spacers[0].leftAnchor.constraint(equalTo: view.leftAnchor),
            spacers[0].rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
        
        NSLayoutConstraint.activate([
            logoView.topAnchor.constraint(equalTo: spacers[0].bottomAnchor),
            logoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            logoView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4)
        ])
        
        NSLayoutConstraint.activate([
            spacers[1].topAnchor.constraint(equalTo: logoView.bottomAnchor),
            spacers[1].leftAnchor.constraint(equalTo: view.leftAnchor),
            spacers[1].rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: spacers[1].bottomAnchor),
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            detailsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            detailsLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            detailsLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            spacers[2].topAnchor.constraint(equalTo: detailsLabel.bottomAnchor, constant: 5),
            spacers[2].leftAnchor.constraint(equalTo: view.leftAnchor),
            spacers[2].rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
        
        NSLayoutConstraint.activate([
            btnBottom.topAnchor.constraint(equalTo: spacers[2].bottomAnchor),
            btnBottom.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            btnBottom.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            btnBottom.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            spacers[3].topAnchor.constraint(equalTo: btnBottom.bottomAnchor),
            spacers[3].leftAnchor.constraint(equalTo: view.leftAnchor),
            spacers[3].rightAnchor.constraint(equalTo: view.rightAnchor),
            spacers[3].bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            spacers[1].heightAnchor.constraint(equalTo: spacers[0].heightAnchor, multiplier: 0.8),
            spacers[2].heightAnchor.constraint(equalTo: spacers[0].heightAnchor, multiplier: 4),
            spacers[3].heightAnchor.constraint(equalTo: spacers[0].heightAnchor, multiplier: 2)
        ])
    }
    
    func setupBindings() {
        self.btnBack.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        self.btnBottom.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }

    private func makeSpacer() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }
    
}

