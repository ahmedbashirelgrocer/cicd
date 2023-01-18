//
//  CategoriesCell.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 13/01/2023.
//

import UIKit
import RxSwift
import RxDataSources

class CategoriesCell: RxUITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var viewModel: CategoriesCellViewModelType!
    private var dataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<Int, ReusableCollectionViewCellViewModelType>>!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.collectionView.delegate = self
        self.collectionView.register(UINib(nibName: StoresCategoriesCollectionViewCell.defaultIdentifier, bundle: .resource), forCellWithReuseIdentifier: StoresCategoriesCollectionViewCell.defaultIdentifier)
    }

    override func configure(viewModel: Any) {
        guard let viewModel = viewModel as? CategoriesCellViewModel else { return }
        
        self.viewModel = viewModel
        self.bindViews()
    }
}

extension CategoriesCell: UICollectionViewDelegateFlowLayout {
    func bindViews() {
        self.dataSource = RxCollectionViewSectionedReloadDataSource(configureCell: { dataSource, tableView, indexPath, viewModel in
            let cell = tableView.dequeueReusableCell(withReuseIdentifier: viewModel.reusableIdentifier, for: indexPath) as! RxUICollectionViewCell
            cell.configure(viewModel: viewModel)
            return cell
        })
        
        self.viewModel.outputs.collectionCellViewModels.bind(to: self.collectionView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
          return 13
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 75 , height: 108)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 11 , bottom: 0 , right: 16)
    }
}

