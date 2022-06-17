//
//  savedCarCell.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 14/04/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

let kSavedCarCellHeight : CGFloat = 102 + 24
let kCarImageBlack : String = "carBlack"
let kEditImageBlack : String = "editBlack"
let kDeleteImageBlack : String = "deleteBlack"
let kCheckImage : String = "checkGreen"
let kCardVisa : String = "cardVisa"
let kCardMaster : String = "cardMaster"

class savedCarCell: UITableViewCell {

    @IBOutlet var cellBGView: AWView!{
        didSet{
            cellBGView.cornarRadius = 8
        }
    }
    @IBOutlet var lblInfo: UILabel!{
        didSet{
            lblInfo.setBody3BoldUpperStyle(false)
        }
    }
    @IBOutlet var carImageView: UIImageView!
    @IBOutlet var defaultBGView: UIView!{
        didSet{
            defaultBGView.backgroundColor = UIColor.clear
        }
    }
    @IBOutlet var lblDefault: UILabel!{
        didSet{
            lblDefault.setBody3BoldUpperStyle(true)
        }
    }
    @IBOutlet var imgDefault: UIImageView!
    @IBOutlet var DeleteBGView: UIView!{
        didSet{
            DeleteBGView.backgroundColor = UIColor.clear
        }
    }
    @IBOutlet var lblDelete: UILabel!{
        didSet{
            lblDelete.setBody3BoldUpperStyle(false)
        }
    }
    @IBOutlet var imgDelete: UIImageView!
    @IBOutlet var btnDelete: UIButton!
    @IBOutlet var editBGView: UIView!{
        didSet{
            editBGView.backgroundColor = UIColor.clear
        }
    }
    @IBOutlet var lblEdit: UILabel!{
        didSet{
            lblEdit.setBody3BoldUpperStyle(false)
        }
    }
    @IBOutlet var imgEdit: UIImageView!
    @IBOutlet var btnEdit: UIButton!
    
    var saveType : savedType = .addNewCar
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupInitialAppearence()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupInitialAppearence(){
        lblDefault.text = NSLocalizedString("btn_default", comment: "")
        
        cellBGView.backgroundColor = .white
        self.backgroundColor = .tableViewBackgroundColor()
        
        if saveType == .addNewCar{
            carImageView.image = UIImage(name: kCarImageBlack)
            imgEdit.image = UIImage(name: kEditImageBlack)
            imgDelete.image = UIImage(name: kDeleteImageBlack)
            imgDefault.image = UIImage(name: kCheckImage)
            lblEdit.text = NSLocalizedString("btn_edit", comment: "")
            lblDelete.text = NSLocalizedString("btn_delete", comment: "")
            
            DeleteBGView.isHidden = false
            editBGView.isHidden = false
            defaultBGView.isHidden = true
        }else{
            DeleteBGView.isHidden = true
            defaultBGView.isHidden = true
            editBGView.isHidden = false
            imgEdit.image = UIImage(name: kDeleteImageBlack)
            lblEdit.text = NSLocalizedString("btn_delete", comment: "")
        }
    }
    
    func ConfigureCardCell(data : CreditCard , isDefault : Bool = false){
        if data.cardID != ""{
            
            let info = NSLocalizedString("lbl_card_ending", comment: "") + data.last4
            lblInfo.text = info
            
            setCardImage(card: data.cardType)
            
            configureSelected(isDefault)
        }
        
        
    }
    
    func setCardImage(card : CreditCardType){
        if card == .VISA{
            self.carImageView.image = UIImage(name: kCardVisa)
        }else if card == .MASTER_CARD{
            self.carImageView.image = UIImage(name: kCardMaster)
        }
    }
    
    func ConfigureCarCell(data : Car , isDefault : Bool = false){
        if let name = data.model?.name{
            let info : String = "\(data.plateNumber),\(name),\(data.company),\(data.color?.name ?? "")"
            lblInfo.text = info
            configureSelected(isDefault)
        }
       
    }
    
    func configureSelected(_ isSelected : Bool = false){
        
        if isSelected {
            self.cellBGView.layer.borderWidth = 2
            self.cellBGView.layer.borderColor = UIColor.navigationBarColor().cgColor
            self.defaultBGView.isHidden = !isSelected
        }else{
            self.cellBGView.layer.borderWidth = 0
            self.defaultBGView.isHidden = !isSelected
        }
        
        
    }

}
