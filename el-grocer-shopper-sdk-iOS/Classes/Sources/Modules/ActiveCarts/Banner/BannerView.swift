//
//  BannerView.swift
//  Adyen
//
//  Created by Rashid Khan on 18/11/2022.
//

import UIKit
import RxSwift
import RxCocoa

class BannerView: UIView {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var contentView: UIView!
    
    var bannerTapped: ((BannerDTO)->())?
    
    private var timer: Timer?
    
    var banners: [BannerDTO] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        guard self.banners.isEmpty else { return }
        
        if timer == nil { timer?.invalidate() }
        
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { [weak self] tiemr in
            self?.collectionView.scrollToNextItem()
        })
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        Bundle.resource.loadNibNamed("BannerView", owner: self, options: nil)
        contentView.fixInView(self)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.collectionView.register(UINib(nibName: BannerCollectionViewCell.defaultIdentifier, bundle: .resource), forCellWithReuseIdentifier: BannerCollectionViewCell.defaultIdentifier)
    }
    
    deinit {
        self.timer?.invalidate()
    }
}

extension BannerView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.banners.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BannerCollectionViewCell.defaultIdentifier, for: indexPath) as! RxUICollectionViewCell
        cell.configure(viewModel: BannerCellViewModel(banner: self.banners[indexPath.row]))
        return cell
    }
}

extension BannerView: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.width * 0.19)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let bannerTapped = self.bannerTapped {
            bannerTapped(self.banners[indexPath.row])
        }
    }
}

// MARK: Rx Extension for binding Banner View with BannerDTOs
extension Reactive where Base: BannerView {
    var banners: Binder<[BannerDTO]> {
        return Binder(self.base) { bannerView, banners in
            bannerView.banners = banners
        }
    }
}

extension UIView {
    func fixInView(_ container: UIView!) -> Void{
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.frame = container.frame;
        container.addSubview(self);
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}
