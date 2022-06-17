//
//  CandCGetDetailTableViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 22/02/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
import NBBottomSheet

let KCandCGetDetailTableViewCellIdentifier = "CandCGetDetailTableViewCell"
let KCandCGetDetailTableViewCellHeight = 80

enum detailCellType {
    case orderCollector
    case car
}

class CandCGetDetailTableViewCell: UITableViewCell {
    @IBOutlet var bgView: UIView! {
        didSet {
            bgView.layer.cornerRadius = 8
        }
    }
    @IBOutlet var lblCellType: UILabel! {
        didSet{
            lblCellType.setBody3RegWhiteStyle()
        }
    }
    
    @IBOutlet var lblCellCurrentValue: UILabel! {
        didSet{
            lblCellCurrentValue.setBody3BoldUpperWhiteStyle()
        }
    }
    
    @IBOutlet var selectedTypeImage: UIImageView!
    
    @IBOutlet var btnChange: AWButton! {
        didSet{
            self.btnChange.setBody3BoldWhiteStyle()
            self.btnChange.setTitle(NSLocalizedString("change_button_title", comment: ""), for: UIControl.State())
        }
    }
    var currentCellType : detailCellType?
    var currentTopVc : Any?
    var carDeleted: ((_ dbId : Int?)->Void)?
    var carSelected: ((_ car : Car?)->Void)?
    var collectorSelected: ((_ collector : collector?)->Void)?
    var currentDataHandler : MyBasketCandCDataHandler?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    func configure(_ cellType : detailCellType , topVc : Any? , dataHandler : MyBasketCandCDataHandler) {
        
        self.currentCellType = cellType
        self.currentTopVc = topVc
        if cellType == .car {
            selectedTypeImage.image = UIImage(name: "MyBasket_Car_Detail")
            selectedTypeImage.changePngColorTo(color: UIColor.navigationBarWhiteColor())
            lblCellType.text = NSLocalizedString("lbl_car_Details_heading", comment: "")
            //setCarData()
            setCarData(dataHandler: dataHandler)
            
        }else{
            selectedTypeImage.image = UIImage(name: "MyBasket_Collector_Details")
            selectedTypeImage.changePngColorTo(color: UIColor.navigationBarWhiteColor())
            lblCellType.text = NSLocalizedString("lbl_Order_Collector", comment: "")
            //setCollectorData()
            setCollectorData(dataHandler: dataHandler)
        }
        
     
       
       
  
    }
    
    
    func setCollectorData(dataHandler : MyBasketCandCDataHandler){
        
        if dataHandler != nil{
            
            self.currentDataHandler = dataHandler
            
            self.btnChange.isHidden = (dataHandler.selectedCollector == nil)
            if dataHandler.selectedCollector != nil {
                self.btnChange.isHidden = (dataHandler.selectedCollector == nil)
                if dataHandler.selectedCollector?.name.count ?? 0 > 0 {
                    let attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14), NSAttributedString.Key.foregroundColor : UIColor.navigationBarWhiteColor()]
                    let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(14), NSAttributedString.Key.foregroundColor : UIColor.navigationBarWhiteColor()]
                    let attributedString = NSMutableAttributedString(string: "" , attributes:attrs1 as [NSAttributedString.Key : Any])
                    let phoneNumber = dataHandler.selectedCollector?.name ?? ""
                    let attributedString1 = NSMutableAttributedString(string: phoneNumber  , attributes:attrs2 as [NSAttributedString.Key : Any])
                    attributedString.append(attributedString1)
                    let attributedString2 = NSMutableAttributedString(string: ", " + (dataHandler.selectedCollector?.phonenNumber ?? "")  , attributes:attrs1 as [NSAttributedString.Key : Any])
                    attributedString.append(attributedString2)
                    DispatchQueue.main.async {
                        UIView.performWithoutAnimation {
                            self.lblCellCurrentValue.attributedText  = attributedString
                        }
                    }
                }else{
                    lblCellCurrentValue.text = "\(String(describing: dataHandler.selectedCollector?.name ?? ""))" + "," + "\(String(describing: dataHandler.selectedCollector?.phonenNumber ?? ""))"
                }
            }else{
                lblCellCurrentValue.text = NSLocalizedString("lbl_enter_details", comment: "").uppercased()
            }
        }else{
            lblCellCurrentValue.text = NSLocalizedString("lbl_enter_details", comment: "").uppercased()
        }
        
            
        
        
    }
    func setCarData(dataHandler : MyBasketCandCDataHandler)  {
        if dataHandler != nil {
            
            self.currentDataHandler = dataHandler
            
            self.btnChange.isHidden = (dataHandler.selectedCar == nil)
            if dataHandler.selectedCar != nil {
                
                if dataHandler.selectedCar?.plateNumber.count ?? 0 > 0 {
                    let attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14), NSAttributedString.Key.foregroundColor : UIColor.navigationBarWhiteColor()]
                    let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(14), NSAttributedString.Key.foregroundColor : UIColor.navigationBarWhiteColor()]
                    var plateNumber = dataHandler.selectedCar?.company ?? ""
                    plateNumber = plateNumber.count > 0 ? plateNumber.appending(", ") : plateNumber.appending("")
                    let attrString = NSMutableAttributedString.init(string: plateNumber, attributes: attrs1)
                    
                    plateNumber = plateNumber.appending(dataHandler.selectedCar?.plateNumber ?? "" )
                    if dataHandler.selectedCar?.plateNumber.count ?? 0 > 0 {
                        attrString.append(NSMutableAttributedString.init(string: dataHandler.selectedCar?.plateNumber ?? "" , attributes: attrs2))
                        attrString.append(NSMutableAttributedString.init(string: ", " , attributes: attrs1))
                    }
                    attrString.append(NSMutableAttributedString.init(string: dataHandler.selectedCar?.color?.name ?? "" , attributes: attrs1))
                    DispatchQueue.main.async {
                        UIView.performWithoutAnimation {
                            self.lblCellCurrentValue.attributedText  = attrString
                        }
                    }
                }else{
                    lblCellCurrentValue.text = NSLocalizedString("lbl_enter_details", comment: "").uppercased()
                }
            }else{
                lblCellCurrentValue.text = NSLocalizedString("lbl_enter_details", comment: "").uppercased()
            }
        }else{
            lblCellCurrentValue.text = NSLocalizedString("lbl_enter_details", comment: "").uppercased()
        }
    }
    
    
    func selectionHandler(dataHandler : MyBasketCandCDataHandler){
        
        if self.currentCellType == .car {
                
                
                if dataHandler != nil {
                   
                    if dataHandler.carList.count > 0 {
                        var size = dataHandler.carList.count * 50
                        if CGFloat(size + 300) > ScreenSize.SCREEN_HEIGHT {
                            size = Int(ScreenSize.SCREEN_HEIGHT - 280.0)
                        }
                        
                        var configuration = NBBottomSheetConfiguration(animationDuration: 0.4, sheetSize: .fixed(CGFloat(size + 210)))
                        configuration.backgroundViewColor = UIColor.newBlackColor().withAlphaComponent(0.56)
                        let bottomSheetController = NBBottomSheetController(configuration: configuration)
                        let controler = OrderCollectorDetailsVC(nibName: "OrderCollectorDetailsVC", bundle: nil)
                        controler.detailsType = .car
                        controler.carDataList = dataHandler.carList
                        controler.selectedCar = dataHandler.selectedCar
                        controler.dataHandlerView = self.currentTopVc as? UIViewController
                        controler.carSelected = { (car) in
                            if let clousre = self.carSelected{
                                clousre(car)
                            }
                        }
                        controler.carDeleted = { (carId) in
                            
                            if let clousre = self.carDeleted{
                                clousre(carId)
                            }
                        }
                        
                
                        
                        if self.currentTopVc is UIViewController {
                            bottomSheetController.present(controler, on: self.currentTopVc as! UIViewController)
                        }
                        return
                    }
                }
                
       
                var configuration = NBBottomSheetConfiguration(animationDuration: 0.4, sheetSize: .fixed(555))
                configuration.backgroundViewColor = UIColor.newBlackColor().withAlphaComponent(0.56)
                let bottomSheetController = NBBottomSheetController(configuration: configuration)
                let controler = AddCarDetailsVC(nibName: "AddCarDetailsVC", bundle: nil)
                    controler.carType  = .addNew
                if self.currentTopVc is UIViewController {
                    controler.currentVc = self.currentTopVc as? UIViewController
                }
                controler.carSelected = { (car) in
                    if car != nil , let closure = self.carSelected{
                            closure(car)
                    }
                }
                  //  controler.currentTopVc = self.currentTopVc
                if self.currentTopVc is UIViewController {
                    bottomSheetController.present(controler, on: self.currentTopVc as! UIViewController)
                    controler.btnBack.visibility = .gone
                }
            }else{
                if dataHandler != nil {
                    if dataHandler.collectorList.count > 0 {
                        var size = dataHandler.collectorList.count * 50
                        if CGFloat(size + 300) > ScreenSize.SCREEN_HEIGHT {
                            size = Int(ScreenSize.SCREEN_HEIGHT - 280.0)
                        }
                        var configuration = NBBottomSheetConfiguration(animationDuration: 0.4, sheetSize: .fixed(CGFloat(size + 210)))
                        configuration.backgroundViewColor = UIColor.newBlackColor().withAlphaComponent(0.56)
                        let bottomSheetController = NBBottomSheetController(configuration: configuration)
                        let controler = OrderCollectorDetailsVC(nibName: "OrderCollectorDetailsVC", bundle: nil)
                        controler.dataList = dataHandler.collectorList
                        controler.selectedCollector = dataHandler.selectedCollector
                        controler.dataHandlerView = self.currentTopVc as? UIViewController
                        controler.collectorSelected = { (collector) in
                            if let clousre = self.collectorSelected{
                                clousre(collector)
                            }
                            
                        }
                        if self.currentTopVc is UIViewController {
                            bottomSheetController.present(controler, on: self.currentTopVc as! UIViewController)
                        }
                        return
                    }
                }
                var configuration = NBBottomSheetConfiguration(animationDuration: 0.4, sheetSize: .fixed(378))
                configuration.backgroundViewColor = UIColor.newBlackColor().withAlphaComponent(0.56)
                let bottomSheetController = NBBottomSheetController(configuration: configuration)
                let controler = CartPickerAddDetails(nibName: "CartPickerAddDetails", bundle: nil)
                controler.collectorType  = .AddNewCollector
                if self.currentTopVc is UIViewController {
                    controler.currentVc = self.currentTopVc as? UIViewController
                }
                if self.currentTopVc is UIViewController {
                    bottomSheetController.present(controler, on: self.currentTopVc as! UIViewController)
                    controler.btnBack.visibility = .gone
                }
            }
        

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func selectionHandler(_ sender: Any) {
        
        if let dataHandler = self.currentDataHandler{
            self.selectionHandler(dataHandler: dataHandler)
        }
        return
        if let type = self.currentCellType {
            if type == .car {
                
                /*
                if self.currentTopVc is MyBasketViewController {
                    let dataController : MyBasketViewController = self.currentTopVc as! MyBasketViewController
                    if dataController.dataHandler.carList.count > 0 {
                        var size = dataController.dataHandler.carList.count * 50
                        if CGFloat(size + 300) > ScreenSize.SCREEN_HEIGHT {
                            size = Int(ScreenSize.SCREEN_HEIGHT - 280.0)
                        }
                        
                        var configuration = NBBottomSheetConfiguration(animationDuration: 0.4, sheetSize: .fixed(CGFloat(size + 210)))
                        configuration.backgroundViewColor = UIColor.newBlackColor().withAlphaComponent(0.56)
                        let bottomSheetController = NBBottomSheetController(configuration: configuration)
                        let controler = OrderCollectorDetailsVC(nibName: "OrderCollectorDetailsVC", bundle: nil)
                        controler.detailsType = .car
                        controler.carDataList = dataController.dataHandler.carList
                        controler.selectedCar = dataController.dataHandler.selectedCar
                        controler.dataHandlerView = dataController
                        controler.carSelected = { (car) in
                            dataController.dataHandler.selectedCar = car
                            dataController.reloadTableData()
                        }
                        controler.carDeleted = { (carId) in
                            let index = dataController.dataHandler.carList.firstIndex { (car) -> Bool in
                                return car.dbId == carId
                            }
                            if index != nil {
                                dataController.dataHandler.carList.remove(at: index!)
                            }
                            dataController.reloadTableData()
                            
                        }
                        
                
                        
                        if self.currentTopVc is UIViewController {
                            bottomSheetController.present(controler, on: self.currentTopVc as! UIViewController)
                        }
                        return
                    }
                }*/
                
       
                var configuration = NBBottomSheetConfiguration(animationDuration: 0.4, sheetSize: .fixed(555))
                configuration.backgroundViewColor = UIColor.newBlackColor().withAlphaComponent(0.56)
                let bottomSheetController = NBBottomSheetController(configuration: configuration)
                let controler = AddCarDetailsVC(nibName: "AddCarDetailsVC", bundle: nil)
                    controler.carType  = .addNew
                if self.currentTopVc is UIViewController {
                    controler.currentVc = self.currentTopVc as? UIViewController
                }
                controler.carSelected = { (car) in
                   /* if self.currentTopVc is MyBasketViewController {
                        let dataController : MyBasketViewController = self.currentTopVc as! MyBasketViewController
                        if car != nil {
                            dataController.dataHandler.carList.append(car!)
                            dataController.dataHandler.selectedCar = car
                            dataController.reloadTableData()
                        }
                    }*/
                }
                  //  controler.currentTopVc = self.currentTopVc
                if self.currentTopVc is UIViewController {
                    bottomSheetController.present(controler, on: self.currentTopVc as! UIViewController)
                    controler.btnBack.visibility = .gone
                }
            }else{
                /*
                if self.currentTopVc is MyBasketViewController {
                    let dataController : MyBasketViewController = self.currentTopVc as! MyBasketViewController
                    if dataController.dataHandler.collectorList.count > 0 {
                        var size = dataController.dataHandler.collectorList.count * 50
                        if CGFloat(size + 300) > ScreenSize.SCREEN_HEIGHT {
                            size = Int(ScreenSize.SCREEN_HEIGHT - 280.0)
                        }
                        var configuration = NBBottomSheetConfiguration(animationDuration: 0.4, sheetSize: .fixed(CGFloat(size + 210)))
                        configuration.backgroundViewColor = UIColor.newBlackColor().withAlphaComponent(0.56)
                        let bottomSheetController = NBBottomSheetController(configuration: configuration)
                        let controler = OrderCollectorDetailsVC(nibName: "OrderCollectorDetailsVC", bundle: nil)
                        controler.dataList = dataController.dataHandler.collectorList
                        controler.selectedCollector = dataController.dataHandler.selectedCollector
                        controler.dataHandlerView = dataController
                        controler.collectorSelected = { (collector) in
                            dataController.dataHandler.selectedCollector = collector
                            dataController.reloadTableData()
                        }
                        if self.currentTopVc is UIViewController {
                            bottomSheetController.present(controler, on: self.currentTopVc as! UIViewController)
                        }
                        return
                    }
                }*/
                var configuration = NBBottomSheetConfiguration(animationDuration: 0.4, sheetSize: .fixed(378))
                configuration.backgroundViewColor = UIColor.newBlackColor().withAlphaComponent(0.56)
                let bottomSheetController = NBBottomSheetController(configuration: configuration)
                let controler = CartPickerAddDetails(nibName: "CartPickerAddDetails", bundle: nil)
                controler.collectorType  = .AddNewCollector
                if self.currentTopVc is UIViewController {
                    controler.currentVc = self.currentTopVc as? UIViewController
                }
                if self.currentTopVc is UIViewController {
                    bottomSheetController.present(controler, on: self.currentTopVc as! UIViewController)
                    controler.btnBack.visibility = .gone
                }
            }
        }
        
        
    }
    
}
