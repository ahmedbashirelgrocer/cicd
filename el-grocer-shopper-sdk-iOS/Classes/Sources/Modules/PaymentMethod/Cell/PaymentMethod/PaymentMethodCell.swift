//
//  OnlinePaymentCell.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 07/12/2023.
//

import UIKit
import RxSwift
import RxCocoa

class PaymentMethodCell: RxUITableViewCell {
    @IBOutlet weak var ivIcon: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var ivRadioIcon: UIImageView!
    @IBOutlet weak var lblSubtitle: UILabel!
    
    private var viewModel: PaymentMethodCellViewModelType!
    
    private let checkedRadioIconName = sdkManager.isShopperApp ? "egRadioButtonFilled" : "RadioButtonFilled"
    private let unCheckedRadioIconName = sdkManager.isShopperApp ? "egRadioButtonUnfilled" :"RadioButtonUnfilled"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lblTitle.setH4RegDarkStyle()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
//        self.ivRadioIcon.image = UIImage(name: selected ? self.checkedRadioIconName : self.unCheckedRadioIconName)
    }
    
    override func configure(viewModel: Any) {
        let viewModel = viewModel as! PaymentMethodCellViewModelType
        
        viewModel.outputs.icon
            .bind(to: self.ivIcon.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.outputs.title
            .bind(to: self.lblTitle.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.subTitle
            .subscribe(onNext: { [weak self] subTitle in
                self?.lblSubtitle.visibility = subTitle == nil ? .goneY : .visible
                self?.lblSubtitle.text = subTitle
            }).disposed(by: disposeBag)
        
        viewModel.outputs.selected
            .subscribe(onNext: { [weak self] isSelected in
                guard let self = self else { return }
                
                self.ivRadioIcon.image = UIImage(name: isSelected ? self.checkedRadioIconName : self.unCheckedRadioIconName)
            }).disposed(by: disposeBag)
    }
}
