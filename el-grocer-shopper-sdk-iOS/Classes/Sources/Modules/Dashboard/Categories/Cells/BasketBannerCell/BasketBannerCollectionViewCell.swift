//
//  BasketBannerCollectionViewCell.swift
//  ElGrocerShopper
//
//  Created by Abubaker Majeed on 19/06/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import UIKit
import FirebaseAnalytics
let BasketBannerCollectionViewCellIdentifier = "BasketBannerCollectionViewCell"

class BasketBannerCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var bannerTableView: UITableView!
    var grocery:Grocery?
    var isMultiBanner : Bool = true
    var homeFeed : Home?  {
        didSet {
            self.bannerTableView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        let basketBannerCellNib = UINib(nibName: "BasketBannerCell", bundle: Bundle(for: MainCategoriesViewController.self))
//        self.bannerTableView.register(basketBannerCellNib, forCellReuseIdentifier: kBasketBannerCellIdentifier)
        
        
        let genericBannersCell = UINib(nibName: KGenericBannersCell, bundle: Bundle(for: GenericBannersCell.self))
        self.bannerTableView.register(genericBannersCell, forCellReuseIdentifier: KGenericBannersCell)
       
//        let bannerCellNib = UINib(nibName: "BannerCell", bundle: Bundle(for: MainCategoriesViewController.self))
//        self.bannerTableView.register(bannerCellNib, forCellReuseIdentifier: kBannerCellIdentifier)
//        self.bannerTableView.isScrollEnabled = false
        
        self.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
        bannerTableView.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
    }
    
}
extension BasketBannerCollectionViewCell : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.bannerTableView.frame.size.height
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homeFeed == nil ? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : GenericBannersCell = tableView.dequeueReusableCell(withIdentifier: "GenericBannersCell", for: indexPath) as! GenericBannersCell
        if let homeFeedData = homeFeed {
            cell.configured(homeFeedData.banners)
            cell.bannerList.bannerCampaignClicked =  { [weak self] (banner) in
                guard let self = self  else {   return   }
                if banner.campaignType.intValue == BannerCampaignType.web.rawValue {
                    if let topVc = UIApplication.topViewController() {
                        ElGrocerUtility.sharedInstance.showWebUrl(banner.url, controller: topVc)
                    }
                }else if banner.campaignType.intValue == BannerCampaignType.brand.rawValue {
                    // self.showWebUrl(banner.url)
                    banner.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: ElGrocerUtility.sharedInstance.groceries)
                }else if banner.campaignType.intValue == BannerCampaignType.retailer.rawValue  ||  banner.campaignType.intValue == BannerCampaignType.priority.rawValue {
                    banner.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: ElGrocerUtility.sharedInstance.groceries)
                }
            }
            return cell
        }
        return cell
    }
}
