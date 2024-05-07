//
//  LimitedTimeSavingsTableViewCell.swift
//  Adyen
//
//  Created by ELGROCER-STAFF on 01/04/2024.
//

import UIKit

protocol PushMarketingCampaignLandingPageDelegate{
    func pushMarketingCampaignLandingPageWith(limitedTimeSavings: LimitedTimeSavings)
}
protocol RemoveCardWithNoProducts{
    func removeCardWithNoProducts(offer: LimitedTimeSavings)
}
protocol RemoveLimitedTimeSavingsSection{
    func removeLimitedTimeSavingsSection()
}
protocol CustomLandingPageTapped{
    func didTapCustomLandingPageWith(offer: LimitedTimeSavings)
}

class LimitedTimeSavingsTableViewCell: UITableViewCell {

    var delegate: PushMarketingCampaignLandingPageDelegate?
    var delegateRemoveLimitedTimeSavings: RemoveLimitedTimeSavingsSection?
    var offers: [LimitedTimeSavings] = []
    var groceryA: [Grocery] = []
    
    @IBOutlet weak var headingLbl: UILabel!{
        didSet {
            headingLbl.setHeadLine5MediumDarkStyle()
            headingLbl.text = localizedString("lbl_title_limited_time_savings", comment: "")
        }
    }
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.backgroundColor = .clear
        self.registerCells()
        self.setUpCollectionView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(offers: [LimitedTimeSavings]?, groceryA: [Grocery]?) {
        self.offers = offers ?? []
        self.groceryA = groceryA ?? []
        self.collectionView.reloadData()
    }
    
    func registerCells() {
        let limitedTimeSavingsCardCollectionCell = UINib(nibName: "LimitedTimeSavingsCardCollectionCell", bundle: Bundle.resource)
        self.collectionView.register(limitedTimeSavingsCardCollectionCell, forCellWithReuseIdentifier: "LimitedTimeSavingsCardCollectionCell")
    }
    
    func setUpCollectionView() {
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false
        
        self.collectionView.collectionViewLayout = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            //layout.itemSize = CGSize(width: ScreenSize.SCREEN_WIDTH - 40, height: 230)
            layout.minimumInteritemSpacing = 5
            layout.minimumLineSpacing = 5
            let edgeInset:CGFloat =  10
            layout.sectionInset = UIEdgeInsets(top: 0, left: edgeInset, bottom: 0, right: edgeInset)
            return layout
        }()
    }
}
extension LimitedTimeSavingsTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return offers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LimitedTimeSavingsCardCollectionCell", for: indexPath) as! LimitedTimeSavingsCardCollectionCell
        cell.delegate = self
        cell.delegateCustomLandingPageTapped = self
        if(offers.count != 0){
            let offer = offers[indexPath.row]
            let grocery = self.groceryA.first { Grocery in
                return (Int(Grocery.getCleanGroceryID()) ?? 0) == (offer.retailer_ids[0])
            }
            print(offer)
            cell.configure(offers: offer, grocery: grocery)
        }
        cell.bgView.layer.cornerRadius = 8
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let offer = offers[indexPath.row]
        self.delegate?.pushMarketingCampaignLandingPageWith(limitedTimeSavings: offer)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    }
}
extension LimitedTimeSavingsTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(offers.count == 1){
            return CGSize(width: ScreenSize.SCREEN_WIDTH - 35, height: 238)
        }else{
            return CGSize(width: ScreenSize.SCREEN_WIDTH - 80, height: 238)
        }
    }
}
extension LimitedTimeSavingsTableViewCell: RemoveCardWithNoProducts{
    func removeCardWithNoProducts(offer: LimitedTimeSavings) {
        if let index = offers.firstIndex(where: { $0.id == offer.id && $0.query == offer.query }) {
            offers.remove(at: index)
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                if(self.offers.count == 0){
                    self.delegateRemoveLimitedTimeSavings?.removeLimitedTimeSavingsSection()
                }
            }
        }
    }
}
extension LimitedTimeSavingsTableViewCell: CustomLandingPageTapped{
    func didTapCustomLandingPageWith(offer: LimitedTimeSavings) {
        self.delegate?.pushMarketingCampaignLandingPageWith(limitedTimeSavings: offer)
    }
}
