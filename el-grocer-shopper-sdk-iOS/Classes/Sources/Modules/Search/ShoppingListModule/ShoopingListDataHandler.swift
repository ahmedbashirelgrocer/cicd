//
//  ShoopingListDataHandler.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 15/07/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import Foundation

protocol ShoopingListDataHandlerDelegate : class {
    func receivedBannerDataOfSearchString( bannerSearchString : String) -> Void
}
extension ShoopingListDataHandlerDelegate {
    func receivedBannerDataOfSearchString( bannerSearchString : String) -> Void {}
}

class ShoopingListDataHandler {

     weak var delegate : ShoopingListDataHandlerDelegate?
          var grocery:Grocery?
    var bannerArray : [NSDictionary] = [NSDictionary]()
    var banneraSearchStringArray : [String] = [String]() {
        didSet{
            self.startBannerSearchFor(self.banneraSearchStringArray)
        }
    }

    private var bannerWorkItem:DispatchWorkItem?

    private func startBannerSearchFor (_ searchA : [String] ) -> Void {

        guard searchA.count > 0 else {
            return
        }
        guard self.grocery != nil else {
            elDebugPrint("No grocery set")
            return
        }
       
        self.getBanners()

    }

    private func removeBannerCall () {
        if let bannerWork = self.bannerWorkItem {
            bannerWork.cancel()
        }
    }

    private func getBanners(){

        self.removeBannerCall()

        self.bannerWorkItem = DispatchWorkItem {
            if let gorceryId = self.grocery?.dbID {
                for searchString : String in self.banneraSearchStringArray {
                    self.getSingleBannerForSearchAgainstString(gorceryId, searchString: searchString)
                }
            }
        }
        DispatchQueue.global(qos: .userInitiated).async(execute:  self.bannerWorkItem!)

    }

    private func getSingleBannerForSearchAgainstString (_ groceryID : String ,  searchString : String  ) -> Void {
        self.getBannersFromServer( groceryID , searchInput: searchString)
    }

    private func getBannersFromServer(_ gorceryId:String , searchInput : String){
        
        guard !searchInput.isEmpty else {
            return
        }

        let homeTitle = "Banners"
        let location = BannerLocation.in_search_tier_1.getType()
        let clearnGroceryID = ElGrocerUtility.sharedInstance.cleanGroceryID(gorceryId)
        ElGrocerApi.sharedInstance.getBannersFor(location: location , retailer_ids: [clearnGroceryID], store_type_ids: nil , retailer_group_ids: nil  , category_id: nil , subcategory_id: nil, brand_id: nil, search_input: searchInput ) { (result) in
            switch result {
                case .success(let response):
                    self.saveBannersResponseData(response, withHomeTitle: homeTitle, andWithGroceryId: clearnGroceryID, searchString: searchInput)
                case.failure(let error):
                    elDebugPrint(error.localizedMessage)
            }
        }
   
/*
        ElGrocerApi.sharedInstance.getBannersOfGrocery(parameters) { (result) in

            switch result {

            case .success(let response):
                self.saveBannersResponseData(response, withHomeTitle: homeTitle, andWithGroceryId: gorceryId, searchString: searchInput)

            case .failure(let error):
                elDebugPrint(error.localizedMessage)
                // error.showErrorAlert()
            }
        }*/
    }

    private func saveBannersResponseData(_ responseObject:NSDictionary, withHomeTitle homeTitle:String, andWithGroceryId gorceryId:String , searchString : String) {

        if (self.grocery?.dbID == gorceryId) {
            let banners = BannerCampaign.getBannersFromResponse(responseObject)
            var homeFeed : Home? = nil
            if banners.count > 0 {
                homeFeed = Home.init(homeTitle, withCategory: nil, withBanners: banners, withType:HomeType.Banner,  andWithResponse: nil)
            }
            let dict = ["value" : searchString , searchString : homeFeed as Any]
            self.bannerArray.append(dict as NSDictionary)
            elDebugPrint(self.bannerArray)
            self.delegate?.receivedBannerDataOfSearchString(bannerSearchString : searchString)
        }

    }
    
}
