//
//  OfferAlertViewController.swift
//  Adyen
//
//  Created by ELGROCCER on 28/03/2024.
//

import UIKit
import RxSwift

class OfferAlertViewController: UIViewController {
    
    //MARK: - outlets
    @IBOutlet weak var  alertLbl:UILabel!
    @IBOutlet weak var  descrptionLbl:UILabel!
    @IBOutlet weak var skipBtn:UIButton!
    var isSmilemarket = true
    @IBOutlet weak var discoverBtn:AWButton! {
        didSet {
            discoverBtn.setH4SemiBoldEnableButtonStyle()
        }
    }
    @IBOutlet weak var viewBanner:BannerView!{
        didSet{
            viewBanner.layer.cornerRadius = 5
        }
    }
    
    // MARK: -  Varriables
    var skipBtnText = ""
    var alertTitle = ""
    var descrptionLblTitle = ""
    var discoverBtnTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var imageUrl = ""
        
        self.viewBanner.banners = [BannerDTO.init(
            name: "", campaignType:.staticImage,
            imageURL:isSmilemarket ? "SingleStoreBanner" : "smilesmarketBanner",
            bannerImageURL: "",
            url: "",
            categories: [],
            subcategories: [],
            brands: [], retailerIDS: [], locations: [], storeTypes: [], retailerGroups: [],
            customScreenId: nil)]
       
        self.viewBanner.bannerType = BannerLocation.campaign_locationExit_grocery_and_more.getType()
        if let groceries = HomePageData.shared.groceryA {
           self.getGenericBanners(for: groceries)
        }
        self.setUI()
    }
    
    func setUI() {
        self.alertLbl.text = alertTitle
        self.descrptionLbl.text = descrptionLblTitle
        self.skipBtn.setTitle(skipBtnText, for: .normal)
        self.discoverBtn.setTitle(discoverBtnTitle, for: .normal)
        self.viewBanner.bannerTapped = { [weak self] banner in
          guard let self = self, let campaignType = banner.campaignType, let bannerDTODictionary = banner.dictionary as? NSDictionary else { return }
            self.dismiss(animated: false) {
            let bannerCampaign = BannerCampaign.createBannerFromDictionary(bannerDTODictionary)
                switch campaignType {
                case .brand:
                    bannerCampaign.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: sdkManager.isGrocerySingleStore ? [ElGrocerUtility.sharedInstance.activeGrocery!] : (HomePageData.shared.groceryA ?? [ElGrocerUtility.sharedInstance.activeGrocery!]))
                    break
                case .retailer,.customBanners:
                    bannerCampaign.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: sdkManager.isGrocerySingleStore ? [ElGrocerUtility.sharedInstance.activeGrocery!] : (HomePageData.shared.groceryA ?? [ElGrocerUtility.sharedInstance.activeGrocery!]))
                    break
                case .web:
                    ElGrocerUtility.sharedInstance.showWebUrl(banner.url ?? "", controller: self)
                    break
                case .priority:
                    bannerCampaign.changeStoreForBanners(currentActive: nil, retailers: sdkManager.isGrocerySingleStore ? [ElGrocerUtility.sharedInstance.activeGrocery!] : (HomePageData.shared.groceryA ?? [ElGrocerUtility.sharedInstance.activeGrocery!]))
                    break
                case .storely:
                    break
                case .staticImage:
                    break
                }
            }
        }
    }
    
    
    //MARK: - Button Actions
    @IBAction func discoverBtnClick() {
        var launchOptions = sdkManager.launchOptions
        guard launchOptions != nil else {return}
        SegmentAnalyticsEngine.instance.logEvent(event: SDKExitedDiscoverOffersEvent(isSmilemarket))
        
        self.dismiss(animated: true) {
            if self.isSmilemarket {
               // ElGrocerUtility
                launchOptions?.marketType = .marketPlace
                sdkManager.rootViewController?.dismiss(animated: false, completion: {
                    ElGrocer.start(with: launchOptions)
                })
           } else {
                if DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext) != nil {
                    launchOptions?.marketType = .grocerySingleStore
                    FlavorAgent.restartEngineWithLaunchOptions(launchOptions!) {
                        if let view = UIApplication.topViewController()?.view {
                            let _ = SpinnerView.showSpinnerViewInView(view)
                        }
                    } completion: { isCompleted, grocery in
                        SpinnerView.hideSpinnerView()
                        ElGrocerUtility.sharedInstance.activeGrocery = grocery
                        sdkManager.rootViewController?.dismiss(animated: false, completion: {
                            ElGrocer.start(with: launchOptions)
                        })
                    }
                }
            }
        }
        
    }
    
    @IBAction func skipBtnClick() {
       // SDKManager.isOncePerSession = false
        defer {
            
            SDKManager.shared.rootContext = nil
            SDKManager.shared.rootViewController = nil
            SDKManager.shared.currentTabBar = nil
            //sdkManager.isOncePerSession = false
        }
        
        SegmentAnalyticsEngine.instance.logEvent(event: SDKExitedEvent())
        NotificationCenter.default.removeObserver(SDKManager.shared, name: NSNotification.Name(rawValue: kReachabilityManagerNetworkStatusChangedNotificationCustom), object: nil)
        if let rootContext = SDKManager.shared.rootContext,
           let presentedViewController = rootContext.presentedViewController {
            presentedViewController.dismiss(animated:true, completion: {
                rootContext.dismiss(animated: true)
            })
        }else {
            if let _ = self.tabBarController {
                self.tabBarController?.dismiss(animated: true)
            }else if let _ = SDKManager.shared.currentTabBar {
                SDKManager.shared.currentTabBar?.dismiss(animated: true)
            }else if let _ = SDKManager.shared.rootViewController {
                SDKManager.shared.rootViewController?.dismiss(animated: true)
            }
        }
    }
    
    
    class func getViewController() -> OfferAlertViewController {
        return OfferAlertViewController(nibName: "OfferAlertViewController", bundle: Bundle.resource) as OfferAlertViewController
    }
    func getGenericBanners(for groceries : [Grocery], and storeTyprA : [String]? = nil) {
        guard groceries.count > 0 else {return}
        //self.viewBanner.banners.removeAll()
        let ids = groceries.map { $0.dbID }
        let location = BannerLocation.campaign_locationExit_grocery_and_more.getType()
        
        ElGrocerApi.sharedInstance.getBanners(for: location , retailer_ids: ids, store_type_ids: storeTyprA , retailer_group_ids: nil , category_id: nil , subcategory_id: nil, brand_id: nil, search_input: nil) { (result) in
            switch result {
            case .success(let bannerA):
                if bannerA.count > 0 {
                    self.viewBanner.banners =  bannerA.map { $0.toBannerDTO() }
                    self.viewBanner.bannerType = location
                }
            case.failure(let _): break
            }
        }
    }
}
