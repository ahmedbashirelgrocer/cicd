//
//  SlotsTableViewCell.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 26/11/2023.
//

import UIKit

class SlotsTableViewCell: RxUITableViewCell {
    @IBOutlet weak var ivRadioButton: UIImageView!
    @IBOutlet weak var lblText: UILabel!
    
    private let checkedRadioIconName = sdkManager.isShopperApp ? "egRadioButtonFilled" : "RadioButtonFilled"
    private let unCheckedRadioIconName = sdkManager.isShopperApp ? "egRadioButtonUnfilled" :"RadioButtonUnfilled"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        self.lblText.setBody2SemiboldDarkStyle()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        self.ivRadioButton.image = UIImage(name: selected ? self.checkedRadioIconName : self.unCheckedRadioIconName)
    }
    
    override func configure(viewModel: Any) {
        guard let viewModel = viewModel as? SlotTableViewCellViewModelType else { return }
        
        viewModel.outputs.slotText
            .bind(to: self.lblText.rx.text)
            .disposed(by: disposeBag)
    }
}
