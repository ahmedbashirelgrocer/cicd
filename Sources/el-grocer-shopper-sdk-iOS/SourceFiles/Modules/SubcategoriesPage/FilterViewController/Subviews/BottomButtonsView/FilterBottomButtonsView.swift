//
//  FilterBottomButtonsView.swift
//  
//
//  Created by saboor Khan on 05/06/2024.
//

import UIKit

extension UIFactory {
    static func makeFilterBottomButtonsView(delegate: FilterBottomButtonsViewDelegate)-> FilterBottomButtonsView {
        let view = FilterBottomButtonsView(delegate: delegate)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}

protocol FilterBottomButtonsViewDelegate {
    func resetButtonPressed()
    func applyButtonPressed()
}
extension FilterBottomButtonsViewDelegate {
    func resetButtonPressed() {}
    func applyButtonPressed() {}
}

class FilterBottomButtonsView: UIView {
    
    
    private let bgView: UIView = UIFactory.makeView()
    private let btnApply: UIButton = UIFactory.makeButton(with: UIFont.SFProDisplayBoldFont(17),
        backgroundColor: ApplicationTheme.currentTheme.viewPrimaryBGColor,
        title: localizedString("title_btn_apply", comment: ""),
        cornerRadiusStyle: .radius(22),
        borderWidth: 0
    )
    private let btnReset: UIButton = UIFactory.makeButton(with: UIFont.SFProDisplayBoldFont(17),
        backgroundColor: .clear,
        title: localizedString("title_btn_reset", comment: ""),
        cornerRadiusStyle: .radius(22),
        borderWidth: 1
    )
    
    private var delegate: FilterBottomButtonsViewDelegate!
    
    convenience init(delegate: FilterBottomButtonsViewDelegate) {
        self.init(frame: .zero)
        self.delegate = delegate
        
        addViewsAndSetUpConstraints()
        setUpInitialAppearance()
    }
    
    private func addViewsAndSetUpConstraints() {
        
        addSubviews([bgView])
        bgView.addSubviews([btnApply, btnReset])
        
        NSLayoutConstraint.activate([
            bgView.topAnchor.constraint(equalTo: topAnchor),
            bgView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bgView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bgView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            btnApply.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 16),
            btnApply.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -16),
            btnApply.leadingAnchor.constraint(equalTo: bgView.centerXAnchor, constant: 12),
            btnApply.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -36),
            btnApply.heightAnchor.constraint(equalToConstant: 44),
            
            btnReset.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 16),
            btnReset.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 16),
            btnReset.trailingAnchor.constraint(equalTo: bgView.centerXAnchor, constant: -12),
            btnReset.centerYAnchor.constraint(equalTo: btnApply.centerYAnchor),
            btnReset.heightAnchor.constraint(equalToConstant: 44),

        ])
    }
    
    func setUpInitialAppearance() {
        //btn apply
        btnApply.setH4SemiBoldWhiteStyle()
        btnApply.addTarget(self, action: #selector(btnApplyPressed), for: .touchUpInside)
        //btn reset
        btnReset.setH4SemiBoldAppBaseColorStyle()
        btnReset.layer.borderColor = ApplicationTheme.currentTheme.themeBasePrimaryColor.cgColor
        btnReset.addTarget(self, action: #selector(btnResetPressed), for: .touchUpInside)
 
    }
    
    @objc
    func btnApplyPressed() {
        self.delegate.applyButtonPressed()
    }
    
    @objc
    func btnResetPressed() {
        self.delegate.resetButtonPressed()
    }
    
}
