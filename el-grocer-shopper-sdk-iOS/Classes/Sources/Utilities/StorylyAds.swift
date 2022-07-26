//
//  StorylyDeals.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 25/11/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import Foundation
import Storyly
import FirebaseCore
class StorylyAds  {
    
    var storylyView = StorylyView()
    var storyGroupList : [StoryGroup] = []
    var actionClicked: ((_ url : String?)->Void)? = nil
    
    func removeLocalData() {
        self.storyGroupList.removeAll()
    }
    
    
    func configureStoryly(_ rootController : UIViewController , groceryList : [Grocery]) {
        
       
        var someSet = Set<String>()
        for grocery in groceryList {
            someSet.insert(ElGrocerUtility.sharedInstance.cleanGroceryID(grocery.dbID))
        }
        for grocery in groceryList {
            let parentId = "p_" + grocery.parentID.stringValue
            someSet.insert(parentId)
        }
        let segment =  StorylySegmentation.init(segments: someSet)
        let story = StorylyInit(storylyId: "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhY2NfaWQiOjE1MzcsImFwcF9pZCI6MTE1MywiaW5zX2lkIjoxMTc2fQ.k3DE2c0a38t0x8Droq5htoc-O7qbOZbrCojY_fIes5Y" , segmentation: segment)
        
        storylyView.translatesAutoresizingMaskIntoConstraints = false
        storylyView.languageCode = ElGrocerUtility.sharedInstance.isArabicSelected() ? "AR" : "EN"
        storylyView.storylyInit = story
        rootController.view.addSubview(storylyView)
        storylyView.delegate = self
        storylyView.rootViewController = rootController
        storylyView.storyItemIconBorderColor = [.navigationBarColor() , .navigationBarColor()]
        storylyView.storyGroupIconBorderColorNotSeen = [.navigationBarColor() , .navigationBarColor()]
        storylyView.storyGroupPinIconColor = .navigationBarColor()
       // storylyView.storyGroupIconForegroundColors = [.navigationBarColor() , .navigationBarColor()]
    }
}
    
extension StorylyAds : StorylyDelegate {
    
    func storylyLoaded(_ storylyView: StorylyView, storyGroupList: [StoryGroup], dataSource: StorylyDataSource) {
        elDebugPrint("load")
       elDebugPrint(self.storyGroupList.count)
        self.storylyView = storylyView
        self.storyGroupList = storyGroupList
        
    }
    func storylyLoadFailed(_ storylyView: StorylyView, errorMessage: String) {
        elDebugPrint("failde")
    }
    
    func storylyEvent(_ storylyView: StorylyView, event: StorylyEvent, storyGroup: StoryGroup?, story: Story?, storyComponent: StoryComponent?) {
        FireBaseEventsLogger.trackBannerView(isSingle: true, brandName: "", "", "", link: nil , nil, true, story?.media.actionUrl ?? "")
    }
    
    func storylyActionClicked(_ storylyView: StorylyView, rootViewController: UIViewController, story: Story) {
        
        storylyView.dismiss(animated: true) {
            
        
            MixpanelEventLogger.trackDealsOffersButton(dealId: "\(story.id)")
            if let actionUrlString = story.media.actionUrl, let url = URL(string: actionUrlString) {
                
                if let clouser = self.actionClicked {clouser(actionUrlString)}
                /*
                if !SDKManager.shared.application(UIApplication.shared, open: url, sourceApplication: "Storyly", annotation: "") {
                    if let clouser = self.actionClicked {clouser(actionUrlString)}
                }else {
                    if let clouser = self.actionClicked {clouser("")}
                }*/
                
                
                /*if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url){
                    if let urlString = dynamicLink.url?.absoluteString {
                        if let clouser = self.actionClicked {clouser(urlString)}
                    }
                } else {
                    if let clouser = self.actionClicked {clouser(actionUrlString)}
                }*/
            }else {
                if let clouser = self.actionClicked {clouser(story.media.actionUrl ?? "")}
            }
            
        }
    }
  
}

