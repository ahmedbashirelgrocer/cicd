//
//  LimitedTimeSavingsCardCollectionCell.swift
//  Adyen
//
//  Created by ELGROCER-STAFF on 01/04/2024.
//

import UIKit
import ABLoaderView
import SDWebImage
class LimitedTimeSavingsCardCollectionCell: UICollectionViewCell {

    var algoliaProductsLoaded = false
    var products = [LimitedTimeSavingsProduct]()
    var grocery: Grocery?
    var offers: LimitedTimeSavings?
    public var storeName = "Smiles Market "
    public var discountOffer = "  50% Off Fruits  "
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var retailerImageView: UIImageView!
    @IBOutlet weak var discount: UILabel!{
        didSet{
            let discountAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.navigationBarWhiteColor(),
                .backgroundColor: UIColor.promotionRedColor(),
                .font: UIFont.SFProDisplaySemiBoldFont(11)
            ]
            let attributedDiscountString = NSAttributedString(string: discountOffer, attributes: discountAttributes)
            discount.attributedText = attributedDiscountString
            discount.layer.cornerRadius = 7
            discount.clipsToBounds = true
        }
    }
    @IBOutlet weak var retailerName: UILabel!{
        didSet{
            let nameAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: ApplicationTheme.currentTheme.labelGroceryCellSecondaryDarkTextColor,
                .font: UIFont.SFProDisplaySemiBoldFont(14)
            ]
            let attributedNameString = NSAttributedString(string: storeName, attributes: nameAttributes)
            retailerName.numberOfLines = 0
            retailerName.attributedText = attributedNameString
        }
    }
    @IBOutlet weak var deliverySlot: UILabel!{
        didSet{
            deliverySlot.setCaptionOneRegDarkStyle()
            deliverySlot.text = "🛵 Within 40 mins"
        }
    }
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.collectionView.reloadData()
        self.layer.cornerRadius = 8
        self.registerCells()
        self.setUpCollectionView()
        self.getAlgoliaProducts()
    }

    func configure(offers: LimitedTimeSavings, grocery: Grocery?) {
        self.grocery = grocery
        self.offers = offers
        self.storeName = grocery?.name ?? ""
        self.discountOffer = "  " + (grocery?.salesTagLine ?? "") + "  "
        self.retailerName.text = self.storeName
        self.discount.text = self.discountOffer
        self.deliverySlot.text = grocery?.genericSlot ?? ""
        self.retailerImageView.assignImage(imageUrl: grocery?.smallImageUrl ?? "")
    }
    
    func registerCells() {
        let limitedTimeSavingsProductCell = UINib(nibName: "LimitedTimeSavingsProductCell", bundle: Bundle.resource)
        self.collectionView.register(limitedTimeSavingsProductCell, forCellWithReuseIdentifier: "LimitedTimeSavingsProductCell")
    }
    
    func setUpCollectionView() {
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false
        
        self.collectionView.collectionViewLayout = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.itemSize = CGSize(width: (self.frame.size.width/2) - 20, height: 126)
            layout.minimumInteritemSpacing = 5
            layout.minimumLineSpacing = 5
            let edgeInset:CGFloat =  15
            layout.sectionInset = UIEdgeInsets(top: 0, left: edgeInset, bottom: 0, right: edgeInset)
            return layout
        }()
    }
}
extension LimitedTimeSavingsCardCollectionCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(self.algoliaProductsLoaded){
            return products.count
        }else{
            return 4
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LimitedTimeSavingsProductCell", for: indexPath) as!
        LimitedTimeSavingsProductCell
        if(algoliaProductsLoaded){
            ABLoader().stopShining(cell)
            let product = products[indexPath.row]
            cell.configureCell(product: product, groceryId: grocery?.dbID ?? "0")
        }else{
            ABLoader().startShining(cell)
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    }
}
extension LimitedTimeSavingsCardCollectionCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (self.frame.size.width/2) - 20, height: 80)
    }
}
extension LimitedTimeSavingsCardCollectionCell{
    func getAlgoliaProducts(){
        AlgoliaApi.sharedInstance.searchWithQuery(query: "shops.retailer_id:16", pageNumber: 0) { content, error in
            if let arrayHits = content?["hits"] as? NSArray{
                for productObj in arrayHits{
                    if let dictProduct = productObj as? NSDictionary{
                        let productModel = LimitedTimeSavingsProduct(dictProduct: dictProduct)
                        self.products.append(productModel)
                    }
                }
                DispatchQueue.main.async {
                    self.algoliaProductsLoaded = true
                    self.collectionView.reloadData()
                }
            }
        }
    }
}
