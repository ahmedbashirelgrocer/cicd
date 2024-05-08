//
//  LimitedTimeSavingsCardCollectionCell.swift
//  Adyen
//
//  Created by ELGROCER-STAFF on 01/04/2024.
//

import UIKit
//import ABLoaderView
import SDWebImage
class LimitedTimeSavingsCardCollectionCell: UICollectionViewCell {

    var delegate : RemoveCardWithNoProducts?
    var delegateCustomLandingPageTapped : CustomLandingPageTapped?
    var algoliaProductsLoaded = false
    var products = [LimitedTimeSavingsProduct]()
    var grocery: Grocery?
    var offers: LimitedTimeSavings?{
        didSet{
            if(self.offers != nil){
                self.getAlgoliaProductsWith(cardObject: self.offers!)
            }
        }
    }
    var cellInitialized: Bool?
    public var storeName = ""
    public var discountOffer = ""
    
    @IBOutlet weak var ivArrow: UIImageView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var retailerImageView: UIImageView!
    @IBOutlet weak var discount: UILabel!{
        didSet{
            discount.textColor = UIColor.navigationBarWhiteColor()
            discount.backgroundColor = UIColor.promotionRedColor()
            discount.font = UIFont.SFProDisplaySemiBoldFont(11)
            discount.layer.cornerRadius = 7
            discount.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var name: UILabel!{
        didSet{
            name.textColor = ApplicationTheme.currentTheme.labelGroceryCellSecondaryDarkTextColor
            name.font = UIFont.SFProDisplaySemiBoldFont(14)
        }
    }
    
    @IBOutlet weak var deliverySlot: UILabel!{
        didSet{
            deliverySlot.setCaptionOneRegDarkStyle()
        }
    }
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.products.removeAll()
        self.offers = nil
        self.algoliaProductsLoaded = false
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setInitialAppearance()
        self.collectionView.isScrollEnabled = false
        self.collectionView.reloadData()
        self.layer.cornerRadius = 8
        self.registerCells()
        self.setUpCollectionView()
    }

    func configure(offers: LimitedTimeSavings, grocery: Grocery?) {
        self.grocery = grocery
        self.offers = offers
        self.cellInitialized = true
        self.storeName = grocery?.name ?? ""
        self.discountOffer = "  " + (grocery?.salesTagLine ?? "") + "  "
        self.name.text = self.storeName
        self.discount.text = self.discountOffer
        if(grocery?.salesTagLine == nil || grocery?.salesTagLine == ""){
            self.discount.isHidden = true
        }else{
            self.discount.isHidden = false
        }
        if(grocery != nil){
            self.getDeliverySlotString(grocery: grocery!)
        }
        self.retailerImageView.assignImage(imageUrl: grocery?.smallImageUrl ?? "")
    }
    
    func setInitialAppearance() {
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            ivArrow.transform = CGAffineTransform(scaleX: -1, y: 1)
            deliverySlot.textAlignment = .right
        }
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
            //ABLoader().stopShining(cell)
            cell.stopShimmeringEffect()
            let product = products[indexPath.row]
            cell.configureCell(product: product, groceryId: grocery?.dbID ?? "0")
        }else{
            cell.startShimmeringEffect()
            //ABLoader().startShining(cell)
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(offers != nil){
            self.delegateCustomLandingPageTapped?.didTapCustomLandingPageWith(offer: self.offers!)
        }
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
    func getAlgoliaProductsWith(cardObject: LimitedTimeSavings){
        AlgoliaApi.sharedInstance.searchWithQuery(query: cardObject.query ?? "", pageNumber: 0){
         content, error in
            if let arrayHits = content?["hits"] as? NSArray{
                if(arrayHits.count >= 1){
                    self.products.removeAll()
                    for productObj in arrayHits{
                        if let dictProduct = productObj as? NSDictionary{
                            let productModel = LimitedTimeSavingsProduct(dictProduct: dictProduct, groceryId: Int(self.grocery?.dbID ?? "0") ?? 0)
                            if(productModel.shop != nil){
                                self.products.append(productModel)
                            }
                        }
                    }
                    if(self.products.count >= 4){
                        DispatchQueue.main.async {
                            self.algoliaProductsLoaded = true
                            self.collectionView.reloadData()
                        }
                    }else{
                        self.delegate?.removeCardWithNoProducts(offer: cardObject)
                    }
                }else{
                    self.delegate?.removeCardWithNoProducts(offer: cardObject)
                }
            }else{
                self.delegate?.removeCardWithNoProducts(offer: cardObject)
            }
        }
    }
}
extension LimitedTimeSavingsCardCollectionCell{
    func setDeliveryDate (_ data : String) {
        let dataA = data.components(separatedBy: CharacterSet.newlines)
        var attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(11) , NSAttributedString.Key.foregroundColor : self.deliverySlot.textColor ]
        if dataA.count == 1 {
            if self.deliverySlot.text?.count ?? 0 > 13 {
                attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(11) , NSAttributedString.Key.foregroundColor : self.deliverySlot.textColor ]
                 let attributedString1 = NSMutableAttributedString(string: dataA[0], attributes:attrs1 as [NSAttributedString.Key : Any])
                 self.deliverySlot.attributedText = attributedString1
                return
            }
        }
        let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(11) , NSAttributedString.Key.foregroundColor : self.deliverySlot.textColor]
        let attributedString1 = NSMutableAttributedString(string:dataA[0], attributes:attrs1 as [NSAttributedString.Key : Any])
        let timeText = dataA.count > 1 ? dataA[1] : ""
        let attributedString2 = NSMutableAttributedString(string:" \(timeText)", attributes:attrs2 as [NSAttributedString.Key : Any])
        attributedString1.append(attributedString2)
        self.deliverySlot.attributedText = attributedString1
        self.deliverySlot.minimumScaleFactor = 0.5;
    }
    func getDeliverySlotString(grocery: Grocery) {
        let scheduledEmoji = "🚛 "
        if  (grocery.isOpen.boolValue && (grocery.isInstant() || grocery.isInstantSchedule())) {
            let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(11) , NSAttributedString.Key.foregroundColor : self.deliverySlot.textColor]
            let instantSlotString = "🛵 " + localizedString("today_title", comment: "") + " " + localizedString("60_min", comment: "")
            let attributedString2 = NSMutableAttributedString(string: instantSlotString, attributes:attrs2 as [NSAttributedString.Key : Any])
            self.deliverySlot.attributedText = attributedString2
        }else if let jsonSlot = grocery.initialDeliverySlotData {
            if let dict = grocery.convertToDictionary(text: jsonSlot) {
                let slotString = DeliverySlotManager.getStoreGenericSlotFormatterTimeStringWithDictionary(dict, isDeliveryMode: grocery.isDelivery.boolValue)
                setDeliveryDate(scheduledEmoji + slotString)
            }else {
                setDeliveryDate(scheduledEmoji + (grocery.genericSlot ?? ""))
            }
        }else {
            setDeliveryDate(scheduledEmoji + (grocery.genericSlot ?? ""))
        }
    }
}
