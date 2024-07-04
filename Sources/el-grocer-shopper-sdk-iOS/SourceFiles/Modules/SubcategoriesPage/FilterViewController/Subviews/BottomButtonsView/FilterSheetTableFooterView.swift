//
//  FilterSheetTableFooterView.swift
//  
//
//  Created by saboor Khan on 06/06/2024.
//

import UIKit

extension UIFactory {
    static func makeFilterSheetTableFooterView()-> FilterSheetTableFooterView{
        let view = FilterSheetTableFooterView()
        return view
    }
}

class FilterSheetTableFooterView: UIView {
    
    let bgView = UIFactory.makeView()
    
    convenience init() {
        // Call the designated initializer of the superclass (UIView)
        self.init(frame: .zero)
        // Set the custom value
        addSubViewsAndSetContraints()
        setInitialAppearance()
    }
    
    func addSubViewsAndSetContraints() {
        addSubviews([bgView])
        NSLayoutConstraint.activate([
            bgView.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            bgView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            bgView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            bgView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            bgView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    func setInitialAppearance() {
        backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
        bgView.backgroundColor = ApplicationTheme.currentTheme.borderLightGrayColor
    }

}
