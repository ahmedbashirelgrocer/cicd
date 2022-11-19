//
//  BannerCollectionViewCell.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 18/11/2022.
//

import UIKit

class BannerCollectionViewCell: RxUICollectionViewCell {
    @IBOutlet weak var ivBanner: UIImageView!
    @IBOutlet weak var viewBannerWrapper: AWButton!
    
    
    private var viewModel: ReusableCollectionViewCellViewModelType!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func configure(viewModel: Any) {
        guard let viewModel = viewModel as? ReusableCollectionViewCellViewModelType else { return }
        
        self.viewModel = viewModel
    }
    
    
}

private extension BannerCollectionViewCell {
    func bindViews() { }
}
