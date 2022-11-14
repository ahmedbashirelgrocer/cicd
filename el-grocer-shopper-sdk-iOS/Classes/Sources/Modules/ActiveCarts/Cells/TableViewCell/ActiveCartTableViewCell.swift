//
//  ActiveCartTableViewCell.swift
//  Adyen
//
//  Created by Rashid Khan on 14/11/2022.
//

import UIKit
import RxSwift
import RxDataSources

class ActiveCartTableViewCell: RxUITableViewCell {
    @IBOutlet weak var ivStoreLogo: UIImageView!
    @IBOutlet weak var lblStoreName: UILabel!
    @IBOutlet weak var ivDeliveryTypeIcon: UIImageView!
    @IBOutlet weak var lblNextDeliverySlot: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var viewBannerWrapper: UIView!
    @IBOutlet weak var viewBanner: UIView!
    
    private var viewModel: ActiveCartCellViewModelType!
    private var dataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<Int, ReusableCollectionViewCellViewModelType>>!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        self.collectionView.register(UINib(nibName: ActiveCartProductCell.defaultIdentifier, bundle: .resource), forCellWithReuseIdentifier: ActiveCartProductCell.defaultIdentifier)
    }

    override func configure(viewModel: Any) {
        guard let viewModel = viewModel as? ActiveCartCellViewModelType else { return }
        
        self.viewModel = viewModel
        self.bindViews()
    }
    
    @IBAction func nextButtonTap(_ sender: Any) {
        
    }
}

private extension ActiveCartTableViewCell {
    func bindViews() {
        self.dataSource = RxCollectionViewSectionedReloadDataSource(configureCell: { dataSource, collectionView, indexPath, viewModel in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: viewModel.reusableIdentifier, for: indexPath) as! RxUICollectionViewCell
            
            cell.configure(viewModel: viewModel)
            return cell
        })
     
        self.viewModel.outputs.cellViewModels
            .bind(to: self.collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}
