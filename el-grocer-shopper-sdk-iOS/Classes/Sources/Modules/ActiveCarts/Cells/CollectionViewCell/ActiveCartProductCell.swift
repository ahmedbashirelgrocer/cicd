//
//  ActiveCartProductCell.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 14/11/2022.
//

import UIKit
import RxSwift
import RxDataSources

class ActiveCartProductCell: RxUICollectionViewCell {
    @IBOutlet weak var ivProductIcon: UIImageView!
    @IBOutlet weak var lblQuantity: UILabel! {
        didSet {
            lblQuantity.setProductCountWhiteStyle()
        }
    }
    
    
    private var viewModel: ActiveCartProductCellViewModelType!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func configure(viewModel: Any) {
        guard let viewModel = viewModel as? ActiveCartProductCellViewModelType else { return }
        
        self.viewModel = viewModel
        self.bindViews()
    }
}

private extension ActiveCartProductCell {
    func bindViews() { }
}
