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
                               .setSize(size: .Custom)
                               .setIconHeight(height: 160)
                               .setIconWidth(width: 160)
                               .setIconCornerRadius(radius: 12)
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
        
        
        let story = StorylyInit(storylyId: "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhY2NfaWQiOjE1MzcsImFwcF9pZCI6MTE1MywiaW5zX2lkIjoxMTc2fQ.k3DE2c0a38t0x8Droq5htoc-O7qbOZbrCojY_fIes5Y")
        storylyView.translatesAutoresizingMaskIntoConstraints = false
        storylyView.storylyInit = story
        rootController.view.addSubview(storylyView)
        storylyView.delegate = self
        storylyView.rootViewController = rootController
        StorylyConfig.Builder().setLocale(locale: ElGrocerUtility.sharedInstance.isArabicSelected() ? "AR" : "EN")
        StorylyStoryStyling.Builder().setHeaderIconBorderColor(colors: [ApplicationTheme.currentTheme.themeBasePrimaryColor , ApplicationTheme.currentTheme.themeBasePrimaryColor])
        StorylyStoryGroupStyling.Builder().setIconBorderColorNotSeen(colors: [ApplicationTheme.currentTheme.themeBasePrimaryColor , ApplicationTheme.currentTheme.themeBasePrimaryColor])
        StorylyStoryGroupStyling.Builder().setPinIconColor(color: ApplicationTheme.currentTheme.themeBasePrimaryColor)
        StorylyConfig.Builder().setTestMode(isTest: Platform.isDebugBuild)
        StorylyConfig.Builder().setLabels(labels: someSet)
        StorylyConfig.Builder().setStoryStyling(styling: StorylyStoryStyling.Builder().build())
        StorylyConfig.Builder().setStoryGroupStyling(styling: StorylyStoryGroupStyling.Builder().build())
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
        if(!sdkManager.isShopperApp){
            if let actionUrlString = story.media.actionUrl, let url = URL(string: actionUrlString) {
                storylyView.closeStory(animated: true)
                ElGrocerDynamicLink.handleDeepLink(url)
                
                // Logging segment event StoryClickedEvent
                let storyClickedEvent = StoryClickedEvent(id: story.uniqueId, name: story.title, deepLink: actionUrlString)
                SegmentAnalyticsEngine.instance.logEvent(event: storyClickedEvent)
            }
        }else{
            if let actionUrlString = story.media.actionUrl, let url = URL(string: actionUrlString) {
                if let clouser = self.actionClicked {clouser(actionUrlString)}
                
                if !sdkManager.application(UIApplication.shared, open: url, sourceApplication: "Storyly", annotation: "") {
                    if let clouser = self.actionClicked {clouser(actionUrlString)}
                }else {
                    if let clouser = self.actionClicked {clouser("")}
                }
                
            }else {
                if let clouser = self.actionClicked {clouser(story.media.actionUrl ?? "")}
            }
        }
    }
}
