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
    
    var initialLoad = true
    var storylyView = StorylyView()
    var storyGroupList : [StoryGroup] = []
    var actionClicked: ((_ url : String?)->Void)? = nil
    
    var storiesdataLoaded: (([StoryGroup])->())?
    func removeLocalData() {
        self.storyGroupList.removeAll()
    }
    
    func configureStorelyForSDK(_ rootController : UIViewController , grocery : Grocery){
        
        ElGrocerUtility.sharedInstance.showStorelyBanner = false
    
        var someSet = Set<String>()
        someSet.insert(ElGrocerUtility.sharedInstance.cleanGroceryID(grocery.dbID))
        someSet.insert("quiz_offers")
        self.storylyView.storylyInit = StorylyInit(
                    storylyId: "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhY2NfaWQiOjE1MzcsImFwcF9pZCI6MTE1MywiaW5zX2lkIjoxMTc2fQ.k3DE2c0a38t0x8Droq5htoc-O7qbOZbrCojY_fIes5Y",
                    config: StorylyConfig.Builder()
                       .setBarStyling(
                            styling: StorylyBarStyling.Builder()
                                .setHorizontalPaddingBetweenItems(padding: 15)
                                .build()
                       )
                       .setStoryGroupStyling(
                           styling: StorylyStoryGroupStyling.Builder()
                               .setIconBorderColorNotSeen(colors: [ApplicationTheme.currentTheme.themeBasePrimaryColor , ApplicationTheme.currentTheme.themeBasePrimaryColor])
                               .setPinIconColor(color: ApplicationTheme.currentTheme.themeBasePrimaryColor)
                               .build()
                        )
                        .setStoryStyling(
                            styling: StorylyStoryStyling.Builder()
                                .setHeaderIconBorderColor(colors: [ApplicationTheme.currentTheme.themeBasePrimaryColor , ApplicationTheme.currentTheme.themeBasePrimaryColor])
                                .build()
                        )
                        .setLabels(labels: someSet)
                        .setTestMode(isTest: Platform.isDebugBuild)
                        .setLocale(locale: ElGrocerUtility.sharedInstance.isArabicSelected() ? "AR" : "EN")
                        .build()
                )
        self.storylyView.translatesAutoresizingMaskIntoConstraints = false
        self.storylyView.delegate =   self
        self.storylyView.rootViewController = rootController
        rootController.view.addSubview(storylyView)
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
        
        self.storylyView.storylyInit = StorylyInit(
            storylyId: "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhY2NfaWQiOjE1MzcsImFwcF9pZCI6MTE1MywiaW5zX2lkIjoxMTc2fQ.k3DE2c0a38t0x8Droq5htoc-O7qbOZbrCojY_fIes5Y",
            config: StorylyConfig.Builder()
                .setBarStyling(
                    styling: StorylyBarStyling.Builder()
                        .setHorizontalPaddingBetweenItems(padding: 15)
                        .build()
                )
                .setStoryGroupStyling(
                    styling: StorylyStoryGroupStyling.Builder()
                        .setIconBorderColorNotSeen(colors: [ApplicationTheme.currentTheme.themeBasePrimaryColor , ApplicationTheme.currentTheme.themeBasePrimaryColor])
                        .setPinIconColor(color: ApplicationTheme.currentTheme.themeBasePrimaryColor)
                        .build()
                )
                .setStoryStyling(
                    styling: StorylyStoryStyling.Builder()
                        .setHeaderIconBorderColor(colors: [ApplicationTheme.currentTheme.themeBasePrimaryColor , ApplicationTheme.currentTheme.themeBasePrimaryColor])
                        .build()
                )
                .setLabels(labels: someSet)
                .setTestMode(isTest: Platform.isDebugBuild)
                .setLocale(locale: ElGrocerUtility.sharedInstance.isArabicSelected() ? "AR" : "EN")
                .build()
        )
        self.storylyView.translatesAutoresizingMaskIntoConstraints = false
        self.storylyView.delegate =   self
        self.storylyView.rootViewController = rootController
        rootController.view.addSubview(storylyView)
    }
}
    
extension StorylyAds : StorylyDelegate {
    
    func storylyLoaded(_ storylyView: StorylyView, storyGroupList: [StoryGroup], dataSource: StorylyDataSource) {
        guard dataSource != StorylyDataSource.Local  else { return }
        elDebugPrint("load")
       elDebugPrint(self.storyGroupList.count)
        if initialLoad {
            initialLoad = false
            storylyView.isHidden = false
        }
        self.storylyView = storylyView
        
        
        
        self.storyGroupList = storyGroupList
        
        if let storiesdataLoaded = self.storiesdataLoaded, storyGroupList.count > 0 {
            storiesdataLoaded(storyGroupList)
        }
        
    }
    func storylyLoadFailed(_ storylyView: StorylyView, errorMessage: String) {
        elDebugPrint("failde")
        if !initialLoad {
            self.storylyView.isHidden = true
        }
    }
    
    func storylyEvent(_ storylyView: StorylyView, event: StorylyEvent, storyGroup: StoryGroup?, story: Story?, storyComponent: StoryComponent?) {
        FireBaseEventsLogger.trackBannerView(isSingle: true, brandName: "", "", "", link: nil , nil, true, story?.media.actionUrl ?? "")
    }
    
    func storylyActionClicked(_ storylyView: StorylyView, rootViewController: UIViewController, story: Story) {
        if let actionUrlString = story.media.actionUrl, let url = URL(string: actionUrlString) {
            storylyView.closeStory(animated: true)
            ElGrocerDynamicLink.handleDeepLink(url)
            //if(!sdkManager.isShopperApp){
                //ElGrocerDynamicLink.handleDeepLink(url)
            //}else{
            //    sdkManager.application(UIApplication.shared, open: url, options: [ : ])
            //}
            // Logging segment event StoryClickedEvent
            let storyClickedEvent = StoryClickedEvent(id: story.uniqueId, name: story.title, deepLink: actionUrlString)
            SegmentAnalyticsEngine.instance.logEvent(event: storyClickedEvent)
        }
    }
}
