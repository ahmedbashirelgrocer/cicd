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

class TouchlessCollectionView: UICollectionView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        superview?.touchesBegan(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        superview?.touchesEnded(touches, with: event)
    }
}

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
    @IBOutlet weak var collectionView: TouchlessCollectionView!
    
    @IBOutlet weak var viewBannerWrapper: UIView!
    @IBOutlet weak var viewBanner: BannerView!
    @IBOutlet weak var buttonNext: UIButton!
    
    private lazy var bottomConstraint = collectionView.bottomAnchor.constraint(equalTo: collectionView.superview!.bottomAnchor, constant: -16)
    
    private var viewModel: ActiveCartCellViewModelType!
    private var dataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<Int, ReusableCollectionViewCellViewModelType>>!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        self.collectionView.delegate = self
        self.collectionView.register(UINib(nibName: ActiveCartProductCell.defaultIdentifier, bundle: .resource), forCellWithReuseIdentifier: ActiveCartProductCell.defaultIdentifier)
        self.buttonNext.isUserInteractionEnabled = false
    }
    
    override func configure(viewModel: Any) {
        guard let viewModel = viewModel as? ActiveCartCellViewModelType else { return }
        
        self.viewModel = viewModel
        
        // Banner tap handler
        self.viewBanner.bannerTapped = { [weak self] banner in
            self?.viewModel.inputs.bannerTapObserver.onNext(banner)
        }
        
        self.bindViews()
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
        
        self.viewModel.outputs.storeIconUrl.subscribe { [weak self] url in
            self?.ivStoreLogo.sd_setImage(with: url, placeholderImage: UIImage(name: ""), context: nil)
        }.disposed(by: disposeBag)
        
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
        
        self.viewModel.outputs.banners
            .bind(to: self.viewBanner.rx.banners)
            .disposed(by: disposeBag)
        
        self.viewModel.outputs.banners.subscribe(onNext: { [weak self] banners in
            self?.bottomConstraint.isActive = banners.isEmpty
            self?.invalidateIntrinsicContentSize()
        }).disposed(by: disposeBag)
        
        self.viewModel.outputs.isArbic.subscribe { [weak self] isArbic in
            self?.buttonNext.transform = isArbic ? CGAffineTransform(scaleX: -1, y: 1) : CGAffineTransform(scaleX: 1, y: 1)
            self?.collectionView.transform = isArbic ? CGAffineTransform(scaleX: -1, y: 1) : CGAffineTransform(scaleX: 1, y: 1)
            self?.collectionView.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
        }.disposed(by: disposeBag)
    }
}

extension ActiveCartTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / 3 - 32, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}
