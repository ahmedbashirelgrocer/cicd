//
//  ExclusiveDealsTableViewCell.swift
//  Adyen
//
//  Created by ELGROCER-STAFF on 25/03/2024.
//

import UIKit
protocol CopyAndShopDelegate{
    func copyAndShopWithGrocery()
}
class ExclusiveDealsTableViewCell: UITableViewCell {

    public var delegate : CopyAndShopDelegate?
    
    @IBOutlet weak var headingLabel: UILabel!{
        didSet {
            headingLabel.setHeadLine5MediumDarkStyle()
            headingLabel.text = localizedString("lbl_title_exclusive_deals", comment: "")
        }
    }
    @IBOutlet weak var ivArrow: UIImageView!{
        didSet{
            if SDKManager.shared.isSmileSDK  {
                ivArrow.image = UIImage(name: "arrowForwardSmiles")
            }
        }
    }
    @IBOutlet weak var btnViewAllBgView: AWView!{
        didSet {
            btnViewAllBgView.roundWithShadow(corners: [.layerMaxXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner], radius: 12.5)
            btnViewAllBgView.backgroundColor = ApplicationTheme.currentTheme.viewthemePrimaryBlackBGColor
        }
    }
    
    @IBOutlet weak var viewAllBtn: AWButton!
    @IBOutlet weak var btnViewAll: AWButton!{
        didSet {
            btnViewAll.setBody3SemiBoldDarkStyle()
            btnViewAll.setTitle(localizedString("view_more_title", comment: ""), for: .normal)
            btnViewAll.setTitleColor(ApplicationTheme.currentTheme.buttonthemeBaseBlackPrimaryForeGroundColor, for: .normal)
        }
    }
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        self.registerCells()
        self.setUpCollectionView()
    }
    
    @objc func copyAndShopTapped(){
        self.delegate?.copyAndShopWithGrocery()
    }
    
    func registerCells() {
        let exclusiveDealsCollectionViewCell = UINib(nibName: "ExclusiveDealsCollectionViewCell", bundle: Bundle.resource)
        self.collectionView.register(exclusiveDealsCollectionViewCell, forCellWithReuseIdentifier: "ExclusiveDealsCollectionViewCell")
    }
    
    func setUpCollectionView() {
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false
        
        self.collectionView.collectionViewLayout = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.itemSize = CGSize(width: 328, height: 140)
            layout.minimumInteritemSpacing = 1
            layout.minimumLineSpacing = 1
            let edgeInset:CGFloat =  1
            layout.sectionInset = UIEdgeInsets(top: 0, left: edgeInset, bottom: 0, right: edgeInset)
            return layout
        }()
    }
}
extension ExclusiveDealsTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExclusiveDealsCollectionViewCell", for: indexPath) as! ExclusiveDealsCollectionViewCell
        cell.copyAndShopBtn.addTarget(self, action: #selector(copyAndShopTapped), for: .touchUpInside)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
extension ExclusiveDealsTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 328, height: 140)
    }
}
