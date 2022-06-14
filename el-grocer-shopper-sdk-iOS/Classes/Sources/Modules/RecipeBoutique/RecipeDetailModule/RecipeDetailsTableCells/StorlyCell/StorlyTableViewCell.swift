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
        storylyView.storyItemIconBorderColor = [.navigationBarColor() , .navigationBarColor()]
        storylyView.storyGroupIconBorderColorNotSeen = [.navigationBarColor() , .navigationBarColor()]
        storylyView.storyGroupPinIconColor = .navigationBarColor()
     //   storylyView.storyGroupIconForegroundColors = [.navigationBarColor() , .navigationBarColor()]
        var someSet = Set<String>()
        someSet.insert(chef?.chefStorlySlug ?? "")
        let segment =  StorylySegmentation.init(segments: someSet)
        let story = StorylyInit.init(storylyId: ElGrocerUtility.sharedInstance.appConfigData.storlyInstanceId , segmentation: segment, customParameter: UserDefaults.getLogInUserID())
        storylyView.languageCode = ElGrocerUtility.sharedInstance.isArabicSelected() ? "AR" : "EN"
        storylyView.translatesAutoresizingMaskIntoConstraints = false
        storylyView.delegate = self.topVc
        storylyView.rootViewController = self.topVc
        storylyView.storylyInit = story
       
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
