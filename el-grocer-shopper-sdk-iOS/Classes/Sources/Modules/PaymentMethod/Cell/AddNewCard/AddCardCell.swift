//
//  AddNewCardCell.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 09/12/2023.
//

import UIKit
import RxSwift
import RxCocoa

class AddCardCell: RxUITableViewCell {
    @IBOutlet weak var ivLeadingIcon: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var ivTrailingIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        lblTitle.setH4RegDarkStyle()
    }

    override func configure(viewModel: Any) {
        let viewModel = viewModel as! AddCardCellViewModelType
        
        viewModel.outputs.title
            .bind(to: self.lblTitle.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.leadingIconName
            .map { UIImage(name: $0) }
            .bind(to: ivLeadingIcon.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.outputs.trailingIconName
            .map { UIImage(name: $0) }
            .bind(to: ivTrailingIcon.rx.image)
            .disposed(by: disposeBag)
    }
    
}
