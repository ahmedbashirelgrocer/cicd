//
//  EmptyTableViewCell.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 15/11/2022.
//

import UIKit

class EmptyTableViewCell: RxUITableViewCell {
    @IBOutlet weak var lblErrorMsg: UILabel!
    
    private var viewModel: EmptyCellViewModelType!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func configure(viewModel: Any) {
        guard let viewModel = viewModel as? EmptyCellViewModelType else { return }
        
        self.viewModel = viewModel
        
        self.viewModel.outputs.errorMsg
            .bind(to: self.lblErrorMsg.rx.text)
            .disposed(by: disposeBag)
    }
    
}
