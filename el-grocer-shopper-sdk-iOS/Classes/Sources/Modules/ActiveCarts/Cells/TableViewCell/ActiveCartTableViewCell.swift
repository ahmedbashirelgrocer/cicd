//
//  ActiveCartTableViewCell.swift
//  Adyen
//
//  Created by Rashid Khan on 14/11/2022.
//

import UIKit
import RxSwift
import RxDataSources
import SDWebImage

class ActiveCartTableViewCell: RxUITableViewCell {
    @IBOutlet weak var ivStoreLogo: UIImageView!
    @IBOutlet weak var lblStoreName: UILabel! {
        didSet {
            lblStoreName.setBody2SemiboldDarkStyle()
        }
    }
    @IBOutlet weak var ivDeliveryTypeIcon: UIImageView!
    @IBOutlet weak var lblNextDeliverySlot: UILabel! {
        didSet {
            lblNextDeliverySlot.setSubHead2RegDarkStyle()
        }
    }
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var viewBannerWrapper: UIView!
    @IBOutlet weak var viewBanner: UIView!
    @IBOutlet weak var ivBannerImage: UIImageView!
    @IBOutlet weak var lblBannerMsg: UILabel! {
        didSet {
            lblBannerMsg.setCaptionOneRegDarkStyle()
        }
    }
    @IBOutlet weak var buttonNext: UIButton!
    
    private var viewModel: ActiveCartCellViewModelType!
    private var dataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<Int, ReusableCollectionViewCellViewModelType>>!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        self.viewBanner.isUserInteractionEnabled = true
        self.viewBanner.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bannerTap(_ :))))
        self.collectionView.delegate = self
        self.collectionView.register(UINib(nibName: ActiveCartProductCell.defaultIdentifier, bundle: .resource), forCellWithReuseIdentifier: ActiveCartProductCell.defaultIdentifier)
    }
    
    override func layoutSubviews() {
    }
    
    override func configure(viewModel: Any) {
        guard let viewModel = viewModel as? ActiveCartCellViewModelType else { return }
        
        self.viewModel = viewModel
        self.bindViews()
    }
    
    @IBAction func nextButtonTap(_ sender: Any) {
        self.viewModel.inputs.nextButtonTapObserver.onNext(())
    }
    
    @objc func bannerTap(_ sender: UITapGestureRecognizer) {
        self.viewModel.inputs.bannerTapObserver.onNext(())
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
        
        self.viewModel.outputs.storeName
            .bind(to: self.lblStoreName.rx.text)
            .disposed(by: disposeBag)
        
        self.viewModel.outputs.deliveryTypeIconName
            .map { UIImage(name: $0)}
            .bind(to: self.ivDeliveryTypeIcon.rx.image)
            .disposed(by: disposeBag)
        
        self.viewModel.outputs.deliveryText
            .bind(to: self.lblNextDeliverySlot.rx.attributedText)
            .disposed(by: disposeBag)
        
        self.viewModel.outputs.isBannerAvailable
            .map { !$0 }
            .bind(to: self.viewBannerWrapper.rx.isHidden)
            .disposed(by: disposeBag)
        
        self.viewModel.outputs.isArbic.subscribe { [weak self] isArbic in
            self?.buttonNext.transform = isArbic ? CGAffineTransform(scaleX: -1, y: 1) : CGAffineTransform(scaleX: 1, y: 1)
        }.disposed(by: disposeBag)
    }
}

extension ActiveCartTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / 3.5 - 16, height: collectionView.bounds.width / 3.5 - 32)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}
