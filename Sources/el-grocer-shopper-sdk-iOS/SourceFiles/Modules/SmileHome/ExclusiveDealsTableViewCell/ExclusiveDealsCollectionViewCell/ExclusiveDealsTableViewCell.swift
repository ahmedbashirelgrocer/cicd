//
//  ExclusiveDealsTableViewCell.swift
//  Adyen
//
//  Created by ELGROCER-STAFF on 25/03/2024.
//

import UIKit
protocol CopyAndShopDelegate{
    func copyAndShopWithGrocery(promo: ExclusiveDealsPromoCode, grocery: Grocery)
}
class ExclusiveDealsTableViewCell: UITableViewCell {

    public var delegate : CopyAndShopDelegate?
    
    @IBOutlet weak var headingLabel: UILabel!{
        didSet {
            headingLabel.setHeadLine5MediumDarkStyle()
        }
    }
    @IBOutlet weak var ivArrow: UIImageView!{
        didSet{
            ivArrow.image = UIImage(name: "arrowForwardSmiles")
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
    
    
    var promoList: [ExclusiveDealsPromoCode] = []
    var groceryA: [Grocery] = []
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.promoList.removeAll()
    }
    
    override func awakeFromNib() {
        self.registerCells()
        self.setUpCollectionView()
        setInitialAppearance()
    }
    
    func copyAndShopTapped(promo: ExclusiveDealsPromoCode, grocery: Grocery){
        self.delegate?.copyAndShopWithGrocery(promo: promo, grocery: grocery)
    }
    
    func registerCells() {
        let exclusiveDealsCollectionViewCell = UINib(nibName: "ExclusiveDealsCollectionViewCell", bundle: Bundle.resource)
        self.collectionView.register(exclusiveDealsCollectionViewCell, forCellWithReuseIdentifier: "ExclusiveDealsCollectionViewCell")
    }
    
    func setInitialAppearance() {
        headingLabel.text = localizedString("lbl_title_exclusive_deals", comment: "")
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            ivArrow.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }
    
    func setUpCollectionView() {
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false
        
        self.collectionView.semanticContentAttribute = ElGrocerUtility.sharedInstance.isArabicSelected() ? .forceRightToLeft : .forceLeftToRight
        
        if self.promoList.count > 0 {
            self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)
        }
        
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
    
    func configureCell(promoList: [ExclusiveDealsPromoCode]?, groceryA: [Grocery]?) {
        self.promoList = promoList ?? []
        self.groceryA = groceryA ?? []
        self.collectionView.reloadData()
    }
    
    
}
extension ExclusiveDealsTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return promoList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExclusiveDealsCollectionViewCell", for: indexPath) as! ExclusiveDealsCollectionViewCell
        
        let promoCode = promoList[indexPath.row]
        let grocery = self.groceryA.first { Grocery in
            return (Int(Grocery.getCleanGroceryID()) ?? 0) == (promoCode.retailer_id ?? 0)
        }
        cell.configure(promoCode: promoCode, grocery: grocery)
        cell.promoTapped = {[weak self] promo, grocery in
            
            if let promo = promo , let grocery = grocery {
                self?.copyAndShopTapped(promo: promo, grocery: grocery)
            }
            
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? ExclusiveDealsCollectionViewCell {
            DispatchQueue.main.async { [weak cell] in
                cell?.voucherBgView.addDashedBorderAroundView(color: ApplicationTheme.currentTheme.themeBasePrimaryBlackColor)
            }
        }
    }
}
extension ExclusiveDealsTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 328, height: 140)
    }
}
