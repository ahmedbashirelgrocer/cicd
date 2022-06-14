//
//  CollectorDetailCell.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 16/02/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

class CollectorDetailCell: UITableViewCell {

    @IBOutlet var imgCollectorProfile: UIImageView!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var btnRadio: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setFonts()
        setSelectionNone()
        setInitialAppearance()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
        // Configure the view for the selected state
    }
    func setSelectionNone(){
        self.selectionStyle = .none
    }
    func setInitialAppearance(){
        self.backgroundColor = UIColor.navigationBarWhiteColor()
    }
    func assignValues(detailsType : CollectorDetailsType){
        //MARK: Only For setup remove
        initialAssignValues(detailsType: detailsType)
        lblName.text = "James, 0551234567"
        btnRadio.setImage(UIImage(named: "RadioButtonUnfilled"), for: .normal)
    }
    func setRadioButtonFilled(setFilled : Bool){
        if setFilled{
            btnRadio.setImage(UIImage(named: "RadioButtonFilled"), for: .normal)
        }else{
            btnRadio.setImage(UIImage(named: "RadioButtonUnfilled"), for: .normal)
        }
    }
    func initialAssignValues(detailsType : CollectorDetailsType){
        if detailsType == .orderCollector{
            self.imgCollectorProfile.image = UIImage(named: "CartCollectorProfileIcon")
        }else{
            self.imgCollectorProfile.image = UIImage(named: "CarDetailsProfileIcon")
        }
    }
    func setFonts(){
        lblName.setH4RegDarkStyle()
    }
}
