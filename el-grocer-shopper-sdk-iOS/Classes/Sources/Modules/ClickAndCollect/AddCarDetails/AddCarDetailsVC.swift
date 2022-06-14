//
//  AddCarDetailsVC.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 17/02/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

enum AddCarType {
    case addNew
    case carDetails
}


/*
 
 {
 company = dsfsfdsfsdfsd;
 id = 17;
 "plate_number" = 23423423432;
 "vehicle_color" =             {
 "color_code" = 000000;
 id = 2;
 name = Black;
 };
 "vehicle_model" =             {
 id = 1;
 name = Sedan;
 };
 }
 
 
 **/


class AddCarDetailsVC: UIViewController {

    @IBOutlet var backGroundView: UIView!
    @IBOutlet var lblHeading: UILabel!{
        didSet{
            lblHeading.setH3SemiBoldDarkStyle()
        }
    }
    @IBOutlet weak var subHeadingLabel: UILabel!{
        didSet{
            subHeadingLabel.setH4SemiBoldStyle()
        }
    }
    @IBOutlet var plateNumTextfield: ElgrocerTextField!{
        didSet{
            plateNumTextfield.placeholder = NSLocalizedString("placeholder_plate_num", comment: "")
            plateNumTextfield.layer.cornerRadius = 8
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                plateNumTextfield.textAlignment = .right
            }
            plateNumTextfield.setBody1RegStyle()
        }
    }
    @IBOutlet var carModelTextfield: ElgrocerTextField!{
        didSet{
            carModelTextfield.placeholder = NSLocalizedString("placeholder_Car_Model", comment: "")
            carModelTextfield.layer.cornerRadius = 8
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                carModelTextfield.textAlignment = .right
            }
            carModelTextfield.setBody1RegStyle()
        }
    }
    @IBOutlet var carBrandCollectionView: UICollectionView!
    @IBOutlet var carColorCollectionView: UICollectionView! {
        didSet {
            self.carColorCollectionView.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.carColorCollectionView.semanticContentAttribute = UISemanticContentAttribute.forceRightToLeft
        }
    }
    @IBOutlet var btnCheckBox: UIButton!
    @IBOutlet var lbl_Save_car_details: UILabel!{
        didSet{
            lbl_Save_car_details.text = NSLocalizedString("lbl_save_car_details", comment: "")
            lbl_Save_car_details.setBody3RegDarkStyle()
        }
    }
    @IBOutlet var btnAddCar: AWButton!{
        didSet{
            btnAddCar.setTitle(NSLocalizedString("btn_Add_Car", comment: ""), for: .normal)
            btnAddCar.setH4SemiBoldWhiteStyle()
        }
    }
    @IBOutlet var btnBack: UIButton!
    @IBOutlet var btnCross: UIButton!
    
    var carUpdated: ((_ car : Car?)->Void)?
    var carSelected: ((_ car : Car?)->Void)?
    //var currentTopVc : Any?
    var checked = false
    var carType : AddCarType = .addNew
    var colorlist : [vehicleColors] = []
    var modelList : [vehicleModels] = []
    var selectedColor : vehicleColors?
    var selectedModel : vehicleModels?
    var priviousCarData = Car()
    var currentVc : UIViewController?
    var isPushed: Bool = false
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return self.isDarkMode ? UIStatusBarStyle.lightContent :  UIStatusBarStyle.darkContent
        }else{
            return  UIStatusBarStyle.default
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        designBackGroundView()
        setupInitialAppearance()
        setupFontsAndColors()
        setCollectionViewDelegates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getVehicleAttributer()
        self.btnAddCar.setBackgroundColor(.disableButtonColor() , forState: UIControl.State())
        setUpTextFieldConstraints()
        
        if priviousCarData.dbId != -1{
            setPriviousCarDta()
        }
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.barTintColor = .navigationBarWhiteColor()
        //(self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
        //self.title = NSLocalizedString("saved_cars_title", comment: "")
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            self.btnBack.transform = CGAffineTransform(scaleX: -1, y: 1)
                self.carColorCollectionView.transform = CGAffineTransform(scaleX: -1, y: 1)
                self.carColorCollectionView.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
                self.carBrandCollectionView.transform = CGAffineTransform(scaleX: -1, y: 1)
                self.carBrandCollectionView.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
            
        }
        UIView.performWithoutAnimation {
            Thread.OnMainThread {
                self.carColorCollectionView.reloadData()
                self.carColorCollectionView.setContentOffset(CGPoint.zero, animated:false)
            }
            
        }

    }
    
    func setPriviousCarDta(){
        self.plateNumTextfield.text = priviousCarData.plateNumber
        self.carModelTextfield.text = priviousCarData.company
        self.selectedColor = priviousCarData.color
        self.selectedModel = priviousCarData.model
        
        self.carBrandCollectionView.reloadData()
        self.carColorCollectionView.reloadData()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK: Appearence
    func designBackGroundView(){
        backGroundView.backgroundColor = .tableViewBackgroundColor()
        if #available(iOS 11.0, *), !isPushed {
            backGroundView.layer.cornerRadius = 12.0
            backGroundView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
    }
    func setUpTextFieldConstraints() {
        self.carModelTextfield.topAnchor.constraint(equalTo: self.plateNumTextfield.lblError.bottomAnchor, constant: 16).isActive = true
    }
    func setupInitialAppearance(){
        switch carType {
        case .carDetails :
            self.title = NSLocalizedString("lbl_Car_Details", comment: "")
            self.lblHeading.text = NSLocalizedString("lbl_Car_Details", comment: "")
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                self.lblHeading.textAlignment = .right
            }else {
                self.lblHeading.textAlignment = .left
            }
            self.subHeadingLabel.text = NSLocalizedString("lbl_Car_Details", comment: "")
            self.btnBack.visibility = .goneX
        default:
            self.title = NSLocalizedString("lbl_New_car_Details", comment: "")
            self.lblHeading.text = NSLocalizedString("lbl_New_car_Details", comment: "")
            self.lblHeading.textAlignment = .center
            self.subHeadingLabel.text = NSLocalizedString("lbl_New_car_Details", comment: "")
            self.btnBack.visibility = .visible
        }
        self.subHeadingLabel.textAlignment = .natural
        //self.btnBack.visibility = .goneY
        lblHeading.superview?.isHidden = isPushed
        subHeadingLabel.superview?.isHidden = !isPushed
    }
    func setupFontsAndColors(){
        //Labels
        self.lblHeading.font = UIFont.SFProDisplaySemiBoldFont(20)
        self.lblHeading.textColor = UIColor.newBlackColor()
        self.lbl_Save_car_details.font = UIFont.SFProDisplayNormalFont(14)
        self.lbl_Save_car_details.textColor = UIColor.newBlackColor()
        self.subHeadingLabel.textColor = UIColor.newBlackColor()
        //textFields
        self.plateNumTextfield.font = UIFont.SFProDisplayNormalFont(17)
        self.plateNumTextfield.textColor = UIColor.newBlackColor()
        self.plateNumTextfield.dtLayer.backgroundColor = UIColor.navigationBarWhiteColor().cgColor
        self.carModelTextfield.font = UIFont.SFProDisplayNormalFont(17)
        self.carModelTextfield.textColor = UIColor.newBlackColor()
        self.carModelTextfield.dtLayer.backgroundColor = UIColor.navigationBarWhiteColor().cgColor
        // buttons
        self.btnAddCar.titleLabel?.font = UIFont.SFProDisplaySemiBoldFont(17)
        self.btnAddCar.titleLabel?.textColor = UIColor.white
    }
    //MARK: Collectionview delegates
    func setCollectionViewDelegates() {
        self.carBrandCollectionView.register(UINib.init(nibName: "CarBrandCollectionCell", bundle: nil), forCellWithReuseIdentifier: "CarBrandCollectionCell")
        carBrandCollectionView.delegate = self
        carBrandCollectionView.dataSource = self
        self.carColorCollectionView.register(UINib.init(nibName: "CarColorCollectionCell", bundle: nil), forCellWithReuseIdentifier: "CarColorCollectionCell")
        carColorCollectionView.delegate = self
        carColorCollectionView.dataSource = self
    }
    
    
    func getVehicleAttributer() {
        
        ElGrocerApi.sharedInstance.getVehicleAttributes { (result) in
            switch result {
                case .success(let responseData):
                   debugPrint(responseData)
                    let response  = responseData["data"] as? NSDictionary
                    if let vehicle_colors = response?["vehicle_colors"] as? [NSDictionary] {
                        self.colorlist = []
                        for colorDict in vehicle_colors {
                            let color = vehicleColors.init(color_code: (colorDict["color_code"] as? String) ?? "", name: (colorDict["name"] as? String) ?? "", dbId: (colorDict["id"] as? Int) ?? -1)
                            self.colorlist.append(color)
                        }
                    }
                    self.carColorCollectionView.reloadData()
                    if let vehicle_models = response?["vehicle_models"] as? [NSDictionary] {
                        self.modelList = []
                        for modelDict in vehicle_models {
                            let color = vehicleModels.init(name:(modelDict["name"] as? String) ?? "" , dbId: (modelDict["id"] as? Int) ?? -1 )
                            self.modelList.append(color)
                        }
                    }
                    self.carBrandCollectionView.reloadData()
                case .failure(let error):
                    error.showErrorAlert()
                    self.btnCrossHandler("")
            }
        }
        
        
    }
    
    
    @IBAction func btnCheckBoxHandler(_ sender: Any) {
        if checked{
            btnCheckBox.setImage(UIImage(named: "CheckboxUnfilled"), for: .normal)
            checked = false
            self.btnAddCar.setBackgroundColor(.disableButtonColor() , forState: UIControl.State())
        }else{
            btnCheckBox.setImage(UIImage(named: "CheckboxFilled"), for: .normal)
            checked = true
            self.btnAddCar.setBackgroundColor(.navigationBarColor() , forState: UIControl.State())
        }
        self.btnAddCar.isUserInteractionEnabled = checked
    }
    @IBAction func btnBackHandler(_ sender: Any) {
        if isPushed {
            self.navigationController?.popViewController(animated: true)
            return
        }
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func btnCrossHandler(_ sender: Any) {
        if isPushed {
            self.navigationController?.popViewController(animated: true)
            return
        }
        let isNeedTodissmisTwice =  self.presentingViewController is OrderCollectorDetailsVC
        if isNeedTodissmisTwice {
            self.presentingViewController?.presentingViewController?.presentedViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            return
        }
        self.presentingViewController?.dismiss(animated: false, completion: nil)
    }
    @IBAction func btnAddCarHandler(_ sender: Any) {
        
        guard self.plateNumTextfield.text?.count ?? 0 > 0 else {
            self.plateNumTextfield.showError(message: NSLocalizedString("error_enter_plateNum", comment: ""))
            return
        }
        
        guard self.selectedModel != nil else {
            self.selectedModel = self.modelList[0]
            self.carBrandCollectionView.reloadData()
            return
        }
        
        guard self.selectedColor != nil else {
            self.selectedColor = self.colorlist[0]
            self.carColorCollectionView.reloadData()
            return
        }
        
        if carType == .addNew{
            self.btnAddCar.showLoading()
            ElGrocerApi.sharedInstance.createNewCar(plate_number: self.plateNumTextfield.text ?? "", vehicle_model_id: self.selectedModel?.dbId ?? -1 , vehicle_color_id: self.selectedColor?.dbId ?? -1 , company: self.carModelTextfield.text ?? "" , isDeleted: !checked) { (result) in
                self.btnAddCar.hideLoading()
                switch result {
                    case .success(let response):
                        if let dbId = (response["data"] as? NSDictionary)?["id"] {
                            let carObj =  Car.init(company: self.carModelTextfield.text ?? "" , dbId: (dbId as? Int) ?? -1  , plateNumber: self.plateNumTextfield.text ?? "" , color: self.selectedColor, model: self.selectedModel)
                            self.carSelected?(carObj)
                            if self.checked {
                                UserDefaults.setCurrentSelectedCar(carObj.dbId)
                            }
                            self.btnCrossHandler("")
                        }
                        ElGrocerUtility.sharedInstance.showTopMessageView(NSLocalizedString("car_added", comment: ""), "", image: UIImage(named: "carBlack"), -1, false) { sender, index, isUndo in
                        }
                    case .failure(let error):
                        error.showErrorAlert()
               
                }
            }
        }else{
            let id = priviousCarData.dbId
            self.btnAddCar.showLoading()
            ElGrocerApi.sharedInstance.editCar(plate_number: self.plateNumTextfield.text ?? "", vehicle_model_id: self.selectedModel?.dbId ?? -1 , vehicle_color_id: self.selectedColor?.dbId ?? -1 , company: self.carModelTextfield.text ?? "" , id : id) { (result) in
                self.btnAddCar.hideLoading()
                switch result {
                    case .success(let response):
                        if let message = (response["data"] as? NSDictionary)?["message"] {
                            if let msg = message as? Int{
                                if msg == 1{
                                    let carObj =  Car.init(company: self.carModelTextfield.text ?? "" , dbId: self.priviousCarData.dbId   , plateNumber: self.plateNumTextfield.text ?? "" , color: self.selectedColor, model: self.selectedModel)
                                    if let clouser = self.carUpdated {
                                        clouser(carObj)
                                    }
                                    self.btnCrossHandler("")
                                }
                            }
                            
                        }
                    ElGrocerUtility.sharedInstance.showTopMessageView(NSLocalizedString("car_updated", comment: ""), "", image: UIImage(named: "carBlack"), -1, false) { sender, index, isUndo in
                    }
                    case .failure(let error):
                        error.showErrorAlert()
               
                }
            }
        }
        
    }

}

extension AddCarDetailsVC: UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if collectionView == carBrandCollectionView{
            return self.modelList.count
        }else{
            return self.colorlist.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if collectionView == carBrandCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarBrandCollectionCell", for: indexPath) as! CarBrandCollectionCell
            let model = self.modelList[indexPath.row]
            cell.setValues(title: model.name)
            if model.dbId == self.selectedModel?.dbId {
                cell.setSelected()
            }else{
                cell.setDesSelected()
            }
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                cell.transform = CGAffineTransform(scaleX: -1, y: 1)
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarColorCollectionCell", for: indexPath) as! CarColorCollectionCell
            let color = self.colorlist[indexPath.row]
            cell.setValues(title: color.name , Color: UIColor.colorWithHexString(hexString: color.color_code))
            if color.dbId == self.selectedColor?.dbId {
                cell.setSelected()
            }else{
                cell.setDesSelected()
            }
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                cell.transform = CGAffineTransform(scaleX: -1, y: 1)
            }
            return cell
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == carBrandCollectionView{
            let model = self.modelList[indexPath.row]
            self.selectedModel = model
        }else{
            let color = self.colorlist[indexPath.row]
            self.selectedColor = color
        }
        collectionView.reloadData()
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == carBrandCollectionView{
            // dataArary is the managing array for your UICollectionView.
            let item = self.modelList[indexPath.row].name
            let itemSize = item.size(withAttributes: [
                NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(15)
            ])
            var size = itemSize.width + 32
            if size < 50 {
                size = 50
            }
            return CGSize(width: size  , height: 52)
        }else{
            return CGSize(width: 64, height: 69)
        }
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

