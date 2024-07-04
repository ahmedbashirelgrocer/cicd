//
//  FiltersBrandTableViewCell.swift
//  
//
//  Created by saboor Khan on 05/06/2024.
//

import UIKit

class FiltersBrandTableViewCell: UITableViewCell, GenericReusableView {
    
    private let bgView: UIView = UIFactory.makeView()
    private let btnCheckBox: UIButton = UIFactory.makeButton(with: "unCheckedBox", in: .resource)
    private let lblBrandName: UILabel = UIFactory.makeLabel()
    
    typealias tapped = (_ brand: BrandDTO, _ isSelected: Bool)-> Void
    var checkBoxTapped: tapped?
    private var vm: FiltersBrandTableViewCellPresenter!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        addViewsAndSetConstraints()
        setupInitialAppearance()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(viewModel: any ReusableTableViewCellPresenterType) {
        //cast view model with guard statement and throw fatel error
        guard let vm = viewModel as? FiltersBrandTableViewCellPresenter else {
            fatalError()
        }
        self.vm = vm
        lblBrandName.text = vm.brand.name ?? ""
        setCheckBoxImage(isSelected: vm.isSelected)
    }
    
    func addViewsAndSetConstraints() {
        contentView.addSubviews([bgView])
        bgView.addSubviews([btnCheckBox, lblBrandName])
        
        NSLayoutConstraint.activate([
            bgView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bgView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bgView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bgView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            btnCheckBox.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 12),
            btnCheckBox.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -12),
            btnCheckBox.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 16),
            btnCheckBox.heightAnchor.constraint(equalToConstant: 24),
            btnCheckBox.widthAnchor.constraint(equalToConstant: 24),
            
            lblBrandName.leadingAnchor.constraint(equalTo: btnCheckBox.trailingAnchor, constant: 8),
            lblBrandName.centerYAnchor.constraint(equalTo: btnCheckBox.centerYAnchor, constant: 0),
            lblBrandName.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -16)
        ])
    }
    
    func setupInitialAppearance() {
        
        lblBrandName.setHeadLine5RegDarkStyle()
        lblBrandName.textAlignment = ElGrocerUtility.sharedInstance.isArabicSelected() ? .right : .left
        setCheckBoxImage(isSelected: false)
        btnCheckBox.addTarget(self, action: #selector(btnCheckBoxHandler), for: .touchUpInside)
    }
    
    func setCheckBoxImage(isSelected: Bool) {
        let imageName = isSelected ? "checkedBox" : "unCheckedBox"
        btnCheckBox.setImage(UIImage(name: imageName), for: UIControl.State())
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        // Configure the view for the selected state
    }
    
    @objc
    func btnCheckBoxHandler() {
        vm.isSelected = !(vm.isSelected)
        setCheckBoxImage(isSelected: vm.isSelected)
        if let checkBoxTapped = self.checkBoxTapped {
            checkBoxTapped(vm.brand, vm.isSelected)
        }
    }

}
