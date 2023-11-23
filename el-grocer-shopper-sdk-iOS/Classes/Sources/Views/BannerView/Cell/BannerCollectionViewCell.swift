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
    
    
    private var viewModel: BannerCellViewModelType!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.ivBanner.layer.cornerRadius = 8.0
    }
    
    override func configure(viewModel: Any) {
        guard let viewModel = viewModel as? BannerCellViewModelType else { return }
        
        self.viewModel = viewModel
        self.bindViews()
        
    }
    
    
}

private extension BannerCollectionViewCell {
    func bindViews() {
        self.viewModel.outputs.bannerImage.subscribe(onNext: { [weak self] imageUrl in
            guard let self = self else { return }
            
            self.ivBanner.sd_setImage(with: imageUrl, placeholderImage: UIImage(name: ""), context: nil)
        }).disposed(by: disposeBag)
    }
}
