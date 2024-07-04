//
//  FilterSheetTableHeaderView.swift
//  
//
//  Created by saboor Khan on 06/06/2024.
//

import UIKit

extension UIFactory {
    static func makeFilterSheetTableHeaderView()-> FilterSheetTableHeaderView{
        let view = FilterSheetTableHeaderView()
        return view
    }
}

class FilterSheetTableHeaderView: UIView {
    
    let bgView = UIFactory.makeView()
    let lblName = UIFactory.makeLabel()
    
    convenience init() {
        // Call the designated initializer of the superclass (UIView)
        self.init(frame: .zero)
        // Set the custom value
        addSubViewsAndSetContraints()
        setInitialAppearance()
    }
    
    func addSubViewsAndSetContraints() {
        //self.translatesAutoresizingMaskIntoConstraints = false
        addSubviews([bgView])
        bgView.addSubviews([lblName])
        
        NSLayoutConstraint.activate([
            bgView.topAnchor.constraint(equalTo: topAnchor),
            bgView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bgView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bgView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            lblName.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 16),
            lblName.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -16),
            lblName.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 12),
            lblName.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -12),
        ])
    }
    
    func setInitialAppearance() {
        backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
        lblName.setHeadLine5BoldDarkStyle()
        lblName.textAlignment = ElGrocerUtility.sharedInstance.isArabicSelected() ? .right : .left
    }
    
    func setTitle(title: String) {
        lblName.text = title
    }

}
