//
//  StorlyTableViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 19/04/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
import Storyly
let KStorlyTableViewCell = "StorlyTableViewCell"
class StorlyTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var  storylyView : StorylyView! {
        didSet {
            storylyView.backgroundColor = .textfieldBackgroundColor()
        }
    }
    
    var chef : CHEF? = nil
    
    var topVc : FilteredRecipeViewController? {
        
        didSet{
            self.checkStolryStory()
            
        }
    }
    
    func checkStolryStory () {
        guard chef?.chefStorlySlug.count ?? 0 > 0 else {
            return
        }
        guard self.storylyView != nil else {return}
        var someSet = Set<String>()
        someSet.insert(chef?.chefStorlySlug ?? "")
        
        self.storylyView.storylyInit = StorylyInit(
            storylyId: ElGrocerUtility.sharedInstance.appConfigData.storlyInstanceId,
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
                .setCustomParameter(parameter: UserDefaults.getLogInUserID())
                .setTestMode(isTest: Platform.isDebugBuild)
                .setLocale(locale: ElGrocerUtility.sharedInstance.isArabicSelected() ? "AR" : "EN")
                .build()
        )
        storylyView.translatesAutoresizingMaskIntoConstraints = false
        storylyView.delegate = self.topVc
        storylyView.rootViewController = self.topVc
        //storylyView.storylyInit = story
       
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setinitialAppearance()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setinitialAppearance(){
        self.backgroundColor = .textfieldBackgroundColor()
    }
}
