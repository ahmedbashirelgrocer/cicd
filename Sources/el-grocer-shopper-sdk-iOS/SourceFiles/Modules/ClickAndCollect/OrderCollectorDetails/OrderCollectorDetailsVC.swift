//
//  OrderCollectorDetailsVC.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 16/02/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
//import NBBottomSheet

enum CollectorDetailsType {
    case car
    case orderCollector
}

class OrderCollectorDetailsVC: UIViewController {
    
    var collectorSelected: ((_ collector : collector?)->Void)?
    var dataList : [collector] = []
    var selectedCollector : collector?
    var dataHandlerView : UIViewController?
    
    var carDeleted: ((_ dbId : Int?)->Void)?
    var carSelected: ((_ car : Car?)->Void)?
    var carDataList : [Car] = []
    var selectedCar : Car?

    @IBOutlet var lblHeading: UILabel!
    @IBOutlet var detailsTableView: UITableView!{
        didSet{
            detailsTableView.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
        }
    }
    @IBOutlet var imgSomeoneElse: UIImageView!
    @IBOutlet var lbl_Someone_else: UILabel!{
        didSet{
            lbl_Someone_else.text = localizedString("lbl_Someone_else", comment: "")
        }
    }
    @IBOutlet var btnAddNew: UIButton!{
        didSet{
            btnAddNew.setImage(UIImage(name: "plusLinear"), for: .normal)
            btnAddNew.setH4SemiBoldWhiteStyle(true)
           
        }
    }
    @IBOutlet var btnConfirm: AWButton!{
        didSet{
            btnConfirm.setTitle(localizedString("confirm_button_title", comment: ""), for: .normal)
        }
    }
    @IBOutlet var backGroundView: UIView!
    
    var detailsType : CollectorDetailsType = .orderCollector
    //extension Variables
    var setFilled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.designBackGroundView()
        self.setupInitialAppearance()
        self.setupFontsAndColors()
        self.setTableviewDelegates()
    }
    func setTableviewDelegates() {
        self.detailsTableView.register(UINib.init(nibName: "CollectorDetailCell", bundle: Bundle.resource), forCellReuseIdentifier: "CollectorDetailCell")
        detailsTableView.delegate = self
        detailsTableView.dataSource = self
        detailsTableView.isScrollEnabled = true
    }
    func designBackGroundView(){
        backGroundView.layer.cornerRadius = 12.0
        if #available(iOS 11.0, *) {
            backGroundView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
    }
    func setupInitialAppearance(){
        switch detailsType {
        case .orderCollector :
            self.lblHeading.text = localizedString("lbl_Order_Detail_Collector", comment: "")
            self.imgSomeoneElse.image = UIImage(name: "CartCollectorProfileIcon")
            self.lbl_Someone_else.text = localizedString("lbl_Someone_else", comment: "")
        default:
            self.lblHeading.text = localizedString("lbl_Car_Detail_Collector", comment: "")
            self.imgSomeoneElse.image = UIImage(name: "CarDetailsProfileIcon")
            self.lbl_Someone_else.text = localizedString("lbl_Different_Car", comment: "")
        }
        self.btnAddNew.setTitle(localizedString("lbl_add_new", comment: ""), for: UIControl.State())
        self.btnAddNew.setH4SemiBoldWhiteStyle(true)
    }
    func setupFontsAndColors(){
        //Labels
        self.lblHeading.font = UIFont.SFProDisplaySemiBoldFont(20)
        self.lblHeading.textColor = UIColor.newBlackColor()
        //textFields
        self.lbl_Someone_else.font = UIFont.SFProDisplayNormalFont(17)
        self.lbl_Someone_else.textColor = UIColor.newBlackColor()
        // buttons
        self.btnConfirm.titleLabel?.font = UIFont.SFProDisplaySemiBoldFont(17)
        self.btnConfirm.titleLabel?.textColor = UIColor.white
    }
    @IBAction func btnAddNewHandler(_ sender: Any) {
        
        
        if self.detailsType == .car {
            
            var configuration = NBBottomSheetConfiguration(animationDuration: 0.4, sheetSize: .fixed(555))
            configuration.backgroundViewColor = UIColor.newBlackColor().withAlphaComponent(0.56)
            let bottomSheetController = NBBottomSheetController(configuration: configuration)
            let controler = AddCarDetailsVC(nibName: "AddCarDetailsVC", bundle: Bundle.resource)
            controler.carType  = .addNew
            controler.carSelected = { (car) in
                if self.dataHandlerView is MyBasketPlaceOrderVC {
                    let dataController : MyBasketPlaceOrderVC = self.dataHandlerView as! MyBasketPlaceOrderVC
                    if car != nil {
                        dataController.dataHandler.carList.append(car!)
                        dataController.dataHandler.selectedCar = car
                    }
                    dataController.checkouTableView.reloadData()
                }
                /* if self.dataHandlerView is MyBasketViewController {
                    let dataController : MyBasketViewController = self.dataHandlerView as! MyBasketViewController
                    if car != nil {
                        dataController.dataHandler.carList.append(car!)
                        dataController.dataHandler.selectedCar = car
                    }
                    dataController.reloadTableData()
                } */
            }
            
            controler.carUpdated = {  (car) in
                /*if self.dataHandlerView is MyBasketViewController {
                    let dataController : MyBasketViewController = self.dataHandlerView as! MyBasketViewController
                    if car != nil {
                   let index  =   dataController.dataHandler.carList.firstIndex { (carobj) -> Bool in
                            return carobj.dbId == car?.dbId
                        }
                        if index != nil {
                            dataController.dataHandler.carList[index!] = car!
                            dataController.dataHandler.selectedCar = car
                        }
                    }
                    dataController.reloadTableData()
                }*/
                
                
                
            }
            
            if let topVc = UIApplication.topViewController() {
                bottomSheetController.present(controler, on: topVc)
            }
            
            
            return
        }
        
        var configuration = NBBottomSheetConfiguration(animationDuration: 0.4, sheetSize: .fixed(378))
        configuration.backgroundViewColor = UIColor.newBlackColor().withAlphaComponent(0.56)
        let bottomSheetController = NBBottomSheetController(configuration: configuration)
        let controler = CartPickerAddDetails(nibName: "CartPickerAddDetails", bundle: Bundle.resource)
        controler.currentVc = dataHandlerView
        controler.collectorType  = .AddNewCollector
        controler.currentVc = self.dataHandlerView
        if let topVc = UIApplication.topViewController() {
            bottomSheetController.present(controler, on: topVc)
        }
        
        
        
    }
    @IBAction func btnCrossHandler(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func btnConfirmHandler(_ sender: Any) {
        
        if detailsType == .orderCollector {
            UserDefaults.setCurrentSelectedCollector(self.selectedCollector?.dbID ?? -1)
            if let clourse = self.collectorSelected {
                clourse( self.selectedCollector)
            }
        }else{
            UserDefaults.setCurrentSelectedCar(self.selectedCar?.dbId ?? -1)
            if let clourse = self.carSelected {
                clourse( self.selectedCar)
            }
        }
  
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension OrderCollectorDetailsVC : UITableViewDelegate , UITableViewDataSource {
    
    func deleteCollectorAt( _ index : Int) {
        
        let dbId = self.dataList[index].dbID
        
        ElGrocerApi.sharedInstance.deleteCollectorWithId(dbId) { (result) in
            switch result {
                case .success(let response):
                    let status = response["status"] as? String
                    if status ==  "success" {
                        self.dataList.remove(at: index)
                        let saveDbId = UserDefaults.getCurrentSelectedCollector()
                        if saveDbId == dbId {
                            UserDefaults.removeCurrentSelectedCollector()
                        }
                        if self.selectedCollector?.dbID == saveDbId {
                            self.selectedCollector = nil
                        }
                        if let clourse = self.collectorSelected {
                            clourse( self.selectedCollector)
                        }
                        /*
                        if self.dataHandlerView is MyBasketViewController {
                            let dataController : MyBasketViewController = self.dataHandlerView as! MyBasketViewController
                            dataController.dataHandler.collectorList.remove(at: index)
                            dataController.reloadTableData()
                        }*/
                        
                    }
                    DispatchQueue.main.async {
                        self.detailsTableView.reloadData()
                    }
                    
                case .failure(let error):
                    error.showErrorAlert()
            }
        }
        
    
        
    }
    
    func deleteCarAt( _ index : Int) {
        
        let dbId = self.carDataList[index].dbId
        
        ElGrocerApi.sharedInstance.deleteVehicleWithId(dbId) { (result) in
            switch result {
                case .success(let response):
                    let status = response["status"] as? String
                    if status ==  "success" {
                        self.carDataList.remove(at: index)
                        let saveDbId = UserDefaults.getCurrentSelectedCar()
                        if saveDbId == dbId {
                            UserDefaults.removeCurrentSelectedCar()
                        }
                        if self.selectedCar?.dbId == saveDbId {
                            self.selectedCar = nil
                        }
                        if let clouser = self.carDeleted {
                            clouser(dbId)
                        }
                        if let clouser = self.carSelected  {
                            clouser( self.selectedCar)
                        }
                        
                        if self.dataHandlerView is MyBasketViewController {
                            let dataController : MyBasketViewController = self.dataHandlerView as! MyBasketViewController
                            dataController.reloadTableData()
                        }
                    }
                    DispatchQueue.main.async {
                        self.detailsTableView.reloadData()
                    }
                case .failure(let error):
                    error.showErrorAlert()
            }
        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        var dbId = -1
        if detailsType == .orderCollector {
            dbId = self.dataList[indexPath.row].dbID
            if dbId == UserDefaults.getCurrentSelectedCollector() {
              //  return nil
            }
        }else{
            dbId = self.carDataList[indexPath.row].dbId
            if dbId == UserDefaults.getCurrentSelectedCar() {
               // return nil
            }
        }
        
        
        let more = UITableViewRowAction(style: .normal, title: localizedString("dashboard_location_delete_button", comment: "")) { action, index in
        
            let SDKManager: SDKManagerType! = sdkManager
            let _ = NotificationPopup.showNotificationPopupWithImage(image: UIImage(name: "MyBasket_Collector_Details") , header: "", detail: localizedString("remove_Collector_alert_message", comment: ""),localizedString("sign_out_alert_yes", comment: ""),localizedString("sign_out_alert_no", comment: "") , withView: SDKManager.window!) { (buttonIndex) in
                
                if buttonIndex == 0 {
                    if self.detailsType == .orderCollector {
                        self.deleteCollectorAt(index.row)
                    }else{
                        self.deleteCarAt(index.row)
                    }
                   
                }else{
                    SpinnerView.hideSpinnerView()
                }
            }

        }
        let edit = UITableViewRowAction(style: .normal, title: localizedString("dashboard_location_edit_button", comment: "")) { action, index in
            
            if self.detailsType == .orderCollector{
                let rowCollector = self.dataList[indexPath.row]
                
                var configuration = NBBottomSheetConfiguration(animationDuration: 0.4, sheetSize: .fixed(378))
                configuration.backgroundViewColor = UIColor.newBlackColor().withAlphaComponent(0.56)
                let bottomSheetController = NBBottomSheetController(configuration: configuration)
                let controler = CartPickerAddDetails(nibName: "CartPickerAddDetails", bundle: Bundle.resource)
                controler.currentVc = self.dataHandlerView
                controler.collectorType  = .OrderCollector
                controler.priviousCollectorData = rowCollector//self.dataList[indexPath.row]
                if let topVc = UIApplication.topViewController() {
                    bottomSheetController.present(controler, on: topVc)
                }
            }else{
                let rowCar = self.carDataList[indexPath.row]
                
                var configuration = NBBottomSheetConfiguration(animationDuration: 0.4, sheetSize: .fixed(555))
                configuration.backgroundViewColor = UIColor.newBlackColor().withAlphaComponent(0.56)
                let bottomSheetController = NBBottomSheetController(configuration: configuration)
                let controler = AddCarDetailsVC(nibName: "AddCarDetailsVC", bundle: Bundle.resource)
                controler.currentVc = self.dataHandlerView
                controler.carType  = .carDetails
                controler.priviousCarData = rowCar//self.carDataList[indexPath.row]
                controler.carUpdated = { (car) in
                   /* if self.dataHandlerView is MyBasketViewController {
                        let dataController : MyBasketViewController = self.dataHandlerView as! MyBasketViewController
                        if car != nil {
                            let index  =   dataController.dataHandler.carList.firstIndex { (carobj) -> Bool in
                                return carobj.dbId == car?.dbId
                            }
                            if index != nil {
                                dataController.dataHandler.carList[index!] = car!
                                dataController.dataHandler.selectedCar = car
                            }
                        }
                        dataController.reloadTableData()
                    } */
                }
                
                
                if let topVc = UIApplication.topViewController() {
                    bottomSheetController.present(controler, on: topVc)
                }
            }
            
            
           elDebugPrint("edit pressed")

        }
        more.backgroundColor = UIColor.textfieldErrorColor()
        return [ more , edit]
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if detailsType == .orderCollector {
            return self.dataList.count
        }
        return self.carDataList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "CollectorDetailCell", for: indexPath) as! CollectorDetailCell
        cell.assignValues(detailsType: detailsType)
        if detailsType == .orderCollector {
            let rowCollector = self.dataList[indexPath.row]
            cell.lblName.text = rowCollector.name
            cell.setRadioButtonFilled(setFilled: (rowCollector.dbID == self.selectedCollector?.dbID))
        }else{
            let rowCar = self.carDataList[indexPath.row]
            cell.lblName.text = rowCar.company + (rowCar.company.count > 0 ? ", " : "") + rowCar.plateNumber + ", " + (rowCar.color?.name ?? "")
            cell.setRadioButtonFilled(setFilled: (rowCar.dbId == self.selectedCar?.dbId))
            
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let _ = tableView.cellForRow(at: indexPath) as? CollectorDetailCell{
            if detailsType == .orderCollector {
                let rowCollector = self.dataList[indexPath.row]
                self.selectedCollector = rowCollector
             
            }else{
                let rowCollector = self.carDataList[indexPath.row]
                self.selectedCar = rowCollector
            }
        }
        tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
}


