//
//  SingleBannerTableViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 09/09/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
import Storyly
let KSingleBannerTableViewCellIdentifier = "SingleBannerTableViewCell"
class SingleBannerTableViewCell: UITableViewCell {
    var storylyView = StorylyView()
    var storyGroupList : [StoryGroup] = []
    var actionClicked: ((_ url : String?)->Void)?
    @IBOutlet var bannerImageView: UIImageView!
    
  
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.bannerImageView.layer.cornerRadius = 8
        self.bannerImageView.clipsToBounds = true
    }
    
    func configureStoryly(_ rootController : UIViewController , groceryList : [Grocery]) {
        
        guard ElGrocerUtility.sharedInstance.appConfigData != nil else {return}
        var someSet = Set<String>()
        for grocery in groceryList {
            someSet.insert(ElGrocerUtility.sharedInstance.cleanGroceryID(grocery.dbID))
        }
        let segment =  StorylySegmentation.init(segments: someSet)
        let story = StorylyInit(storylyId: "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhY2NfaWQiOjE1MzcsImFwcF9pZCI6MTE1MywiaW5zX2lkIjoxMTc2fQ.k3DE2c0a38t0x8Droq5htoc-O7qbOZbrCojY_fIes5Y" , segmentation: segment)
        
        storylyView.translatesAutoresizingMaskIntoConstraints = false
        storylyView.languageCode = ElGrocerUtility.sharedInstance.isArabicSelected() ? "AR" : "EN"
        storylyView.storylyInit = story
        self.addSubview(storylyView)
        storylyView.delegate = self
        storylyView.rootViewController = rootController
        storylyView.storyItemIconBorderColor = [ApplicationTheme.currentTheme.themeBasePrimaryColor , ApplicationTheme.currentTheme.themeBasePrimaryColor]
        storylyView.storyGroupIconBorderColorNotSeen = [ApplicationTheme.currentTheme.themeBasePrimaryColor , ApplicationTheme.currentTheme.themeBasePrimaryColor]
        storylyView.storyGroupPinIconColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func tapAction(_ sender: Any) {
        for group in self.storyGroupList {
            _ = self.storylyView.openStory(storyGroupId: group.id)
        }
    }
}

extension SingleBannerTableViewCell : StorylyDelegate {
    
    func storylyLoaded(_ storylyView: StorylyView, storyGroupList: [StoryGroup], dataSource: StorylyDataSource) {
        elDebugPrint("load")
       elDebugPrint(self.storyGroupList.count)
        self.storylyView = storylyView
        self.storyGroupList = storyGroupList
        
    }
    func storylyLoadFailed(_ storylyView: StorylyView, errorMessage: String) {
        elDebugPrint("failde")
    }
    
    
    func storylyActionClicked(_ storylyView: StorylyView, rootViewController: UIViewController, story: Story) {
        storylyView.dismiss(animated: true) {
            
            if let clouser = self.actionClicked {clouser(story.media.actionUrl)}
        }
    }
    
    
    
}
