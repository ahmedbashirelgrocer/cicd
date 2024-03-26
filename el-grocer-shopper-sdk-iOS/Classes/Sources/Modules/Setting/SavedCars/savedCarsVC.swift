//
//  savedCarsVC.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 14/04/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
import Adyen

enum savedType{
    case addNewCar
    case addNewCard
}

class savedCarsVC: UIViewController, NoStoreViewDelegate, NavigationBarProtocol {

    @IBOutlet var bottomBGView: AWView!{
        didSet{
            
            //MARK: For top shadow
            //bottomBGView.layer.masksToBounds = false
            bottomBGView.layer.shadowOffset = CGSize(width: 0, height: -2)
            bottomBGView.layer.shadowOpacity = 0.16
            bottomBGView.layer.shadowRadius = 1
            bottomBGView.layer.cornerRadius = 8
            bottomBGView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
    }
    @IBOutlet var tableView: UITableView!
    @IBOutlet var btnAddNewCar: AWButton!{
        didSet{
            btnAddNewCar.cornarRadius = 28
            btnAddNewCar.setButton2SemiBoldWhiteStyle()
            btnAddNewCar.setImage(UIImage(name: "addIconWhite"), for: UIControl.State())
            btnAddNewCar.backgroundColor = ApplicationTheme.currentTheme.buttonEnableBGColor
        }
    }
    
    var dataHandlerView : UIViewController?
    
    lazy var dataHandler : MyBasketCandCDataHandler = {
        let dataH = MyBasketCandCDataHandler()
        dataH.delegate = self
        return dataH
    }()
    
    lazy var NoDataView : NoStoreView = {
        let noStoreView = NoStoreView.loadFromNib()
        noStoreView?.delegate = self
        noStoreView?.configureNoSavedCar()
        return noStoreView!
    }()
    lazy var NoCardView : NoStoreView = {
        let noStoreView = NoStoreView.loadFromNib()
        noStoreView?.delegate = self
        noStoreView?.configureNoSavedCard()
        return noStoreView!
    }()
    func noDataButtonDelegateClick(_ state: actionState) {
       elDebugPrint("button clicked")
       
    }
    
    var saveType : savedType = .addNewCar
    
    //MARK: Saved Cards
    var creditCardA : [CreditCard] = []
    var selectedCreditCard: CreditCard?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setUpInitialAppearence()
        self.registerCells()
        self.setupNavigationAppearence()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationAppearence()
        SpinnerView.showSpinnerViewInView(self.view)
        if saveType == .addNewCar{
            self.dataHandler.getCardetails()
        }else{
            self.getAdyenPaymentMethods()
        }
        
    }
    
    func setUpInitialAppearence(){
        if saveType == .addNewCar{
            btnAddNewCar.setTitle(localizedString("lbl_add_new_car", comment: ""), for: UIControl.State())
        }else{
            btnAddNewCar.setTitle(localizedString("lbl_add_new_card", comment: ""), for: UIControl.State())
        }
        
    }

    @IBAction func btnAddNewCarHandler(_ sender: Any) {
        if saveType == .addNewCar{
            gotoAddCarDetails()
        }else{
            goToAddNewCardController()
        }
        
        
    }
    override func backButtonClick() {
        //self.navigationController?.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    func backButtonClickedHandler() {
        backButtonClick()
    }
    func setupNavigationAppearence(){
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(false)
        (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
        (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
        //self.addBackButton()
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.barTintColor = .navigationBarWhiteColor()

        if saveType == .addNewCar{
            self.title = localizedString("saved_cars_title", comment: "")
        }else{
            self.title = localizedString("payment_methods_title", comment: "")
        }
    }
    func registerCells(){
        let spaceTableViewCell = UINib(nibName: "savedCarCell", bundle: Bundle.resource)
        self.tableView.register(spaceTableViewCell, forCellReuseIdentifier: "savedCarCell")
        
        tableView.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
        tableView.separatorStyle = .none
        tableView.delegate = self
    }
    
    func editCarDetail(index : Int){
        let rowCar = self.dataHandler.carList[index]
        
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
            controler.modalPresentationStyle = .fullScreen
            //self.present(controler, animated: true, completion: nil)
            controler.isPushed = true
            self.navigationController?.pushViewController(controler, animated: true)
        }
        return
    }
    
    func gotoAddCarDetails(){
        let controler = AddCarDetailsVC(nibName: "AddCarDetailsVC", bundle: Bundle.resource)
        controler.carType  = .addNew
        controler.carSelected = { (car) in
            /*if self.dataHandlerView is MyBasketViewController {
                let dataController : MyBasketViewController = self.dataHandlerView as! MyBasketViewController
                if car != nil {
                    dataController.dataHandler.carList.append(car!)
                    dataController.dataHandler.selectedCar = car
                }
                dataController.reloadTableData()
            }*/
        }
        
        controler.carUpdated = {  (car) in
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
            }*/
            
            
            
        }
        controler.modalPresentationStyle = .overFullScreen
        //self.present(controler, animated: true, completion: nil)
        controler.isPushed = true
        self.navigationController?.pushViewController(controler, animated: true)
        
        
        return
    }

}
extension savedCarsVC{
    
    //MARK: Saved Cars working
    
    @objc func deleteButtonHandler(sender : UIButton){
        let indx = sender.tag
        if indx >= 0{
            self.deleteCarAt(indx)
            ElGrocerUtility.sharedInstance.showTopMessageView(localizedString("car_removed", comment: ""), "", image: UIImage(name: "carBlack"), indx, false) { sender, index, isUndo in
            }
        }
        
    }
    @objc func editButtonHandler(sender : UIButton){
        if saveType == .addNewCar{
            let indx = sender.tag
            if indx >= 0{
               elDebugPrint(indx)
                self.editCarDetail(index: indx)
            }
        }else{
           elDebugPrint("delete card functionality")
            let indx = sender.tag
            if indx >= 0 {
                
                ElGrocerAlertView.createAlert(localizedString("card_title", comment: ""),
                                              description: localizedString("card_Delete_Message", comment: ""),
                                              positiveButton: localizedString("promo_code_alert_no", comment: "") ,
                                              negativeButton: localizedString("dashboard_location_delete_button", comment: "") ,
                                              buttonClickCallback: { (buttonIndex:Int) -> Void in
                    if buttonIndex == 1 {
                        self.deleteCardAt(indx)
                    }
                }).show()
            }
        }
        
        
    }
    
    //MARK: Delete Card
    
    func deleteCardAt( _ index : Int) {
        if index >= creditCardA.count { return }
        
        let card = self.creditCardA[index]
        
        AdyenApiManager().deleteCreditCard(recurringDetailReference: card.cardID) { (error, response) in
            if let error = error {
                error.showErrorAlert()
                return
            }else {
                if let data = response?["data"] as? NSDictionary {
                    if let responseData = data["response"] as? NSDictionary {
                        let status = response?["status"] as? String
                        if status ==  "success" {
                            self.creditCardA.remove(at: index)
                            let saveDbId = UserDefaults.getCardID(userID: UserDefaults.getLogInUserID())
                            if saveDbId == "\(card.cardID)" {
                                UserDefaults.removeCurrentSelectedCard(userID: UserDefaults.getLogInUserID())
                            }
                            if self.selectedCreditCard != nil {
                                if self.selectedCreditCard!.cardID.elementsEqual(saveDbId) {
                                    self.selectedCreditCard = nil
                                }
                            }
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            if self.creditCardA.count == 0 {
                                self.tableView.backgroundView = self.NoCardView
                            }
                        }
                    }
                }
            }
        }
//        ElGrocerApi.sharedInstance.delCreditCards(creditCard: card){ (result) in
//            switch result {
//                case .success(let response):
//                    let status = response["status"] as? String
//                    if status ==  "success" {
//                        self.creditCardA.remove(at: index)
//                        let saveDbId = UserDefaults.getCardID(userID: UserDefaults.getLogInUserID())
//                        if saveDbId == "\(card.cardID)" {
//                            UserDefaults.removeCurrentSelectedCard(userID: UserDefaults.getLogInUserID())
//                        }
//                        if self.selectedCreditCard != nil {
//                            if self.selectedCreditCard!.cardID.elementsEqual(saveDbId) {
//                                self.selectedCreditCard = nil
//                            }
//                        }
//
//                    }
//                    DispatchQueue.main.async {
//                        self.tableView.reloadData()
//                    }
//                case .failure(let error):
//                    error.showErrorAlert()
//            }
//        }
    }

//MARK: Delete Car
    func deleteCarAt( _ index : Int) {
        
        let dbId = dataHandler.carList[index].dbId
        
        ElGrocerApi.sharedInstance.deleteVehicleWithId(dbId) { (result) in
            switch result {
                case .success(let response):
                    let status = response["status"] as? String
                    if status ==  "success" {
                        self.dataHandler.carList.remove(at: index)
                        let saveDbId = UserDefaults.getCurrentSelectedCar()
                        if saveDbId == dbId {
                            UserDefaults.removeCurrentSelectedCar()
                        }
                        if self.dataHandler.selectedCar?.dbId == saveDbId {
                            self.dataHandler.selectedCar = nil
                        }
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                case .failure(let error):
                    error.showErrorAlert()
            }
        }
    }
    
}

extension savedCarsVC {
    //MARK: Manage Cards API Working
    
    func goToAddNewCardController() {
        
        AdyenManager.sharedInstance.performZeroTokenization(controller: self)
        AdyenManager.sharedInstance.isNewCardAdded = { (error , response,adyenObj) in
            if error {
               //  print("error in authorization")
                if let resultCode = response["resultCode"] as? String {
                    let message = response["refusalReason"] as? String ?? resultCode
                    AdyenManager.showErrorAlert(descr: message)
                }
            }else{
                self.getAdyenPaymentMethods()
                
                // Logging segment event for card added
                SegmentAnalyticsEngine.instance.logEvent(event: CardAddedEvent())
            }
        }
    }
    
    private func makeCardSelected (_ card : CreditCard?) {
        
        guard card != nil else {
            return
        }
        guard let id = UserDefaults.getLogInUserID() as? String else {
            return
        }
        
        ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("user_selected_card")
        FireBaseEventsLogger.trackPaymentMethod(false , true)
        FireBaseEventsLogger.addPaymentInfo("PayCreditCard")
        UserDefaults.setCardID(cardID: "\(String(describing: card?.cardID ?? ""))"  , userID: id)
        self.selectedCreditCard = card
    }
    
    func getAdyenPaymentMethods() {
        
        
        let userId = UserDefaults.getLogInUserID()
        let _ = SpinnerView.showSpinnerViewInView(self.view)
        let amount = AdyenManager.createAmount(amount: 0.0)
        AdyenApiManager().getPaymentMethods(amount: amount) { error, paymentMethods in
            
            SpinnerView.hideSpinnerView()
            if let error = error{
                error.showErrorAlert()
                return
            }
            self.creditCardA.removeAll()
            
            if let paymentMethod = paymentMethods {
               elDebugPrint(paymentMethods)
                for method in paymentMethod.stored {
                    if method is StoredCardPaymentMethod {
                        
                        if let cardAdyen = method as? StoredCardPaymentMethod {
                            var card = CreditCard()
                            card.cardID = cardAdyen.identifier
                            card.last4 = cardAdyen.lastFour
                            if cardAdyen.brand.elementsEqual("mc") {
                                card.cardType = .MASTER_CARD
                            }else if cardAdyen.brand.elementsEqual("visa") {
                                card.cardType = .VISA
                            }else{
                                card.cardType = .unKnown
                            }
                            
                            card.adyenPaymentMethod = cardAdyen
                            if cardAdyen.brand.contains("applepay") {
                                
                            }else{
                                self.creditCardA.append(card)
                            }
                            
                        }
                    }
                }
                DispatchQueue.main.async {
                    let cardID = UserDefaults.getCardID(userID: userId)
                    if cardID.count > 0 {
                        let cardSelected =  self.creditCardA.filter { (card) -> Bool in
                            return "\(card.cardID)" == cardID
                        }
                        if cardSelected.count > 0 {
                            self.selectedCreditCard = cardSelected[0]
                            //self.setViewAccordingToSelectedCreditCard(card: self.selectedCreditCard!)
                            self.tableView.backgroundView = UIView()
                            self.tableView.reloadData()
                            return
                        }
                    }
                    if self.creditCardA.count > 0 {
                        self.selectedCreditCard = self.creditCardA[0]
                        self.tableView.backgroundView = UIView()
                        self.tableView.reloadData()
                        //self.setViewAccordingToSelectedCreditCard(card: self.selectedCreditCard!)
                    }else{
                       elDebugPrint("no card")
                        self.tableView.reloadData()
                        self.tableView.backgroundView = self.NoCardView
                    }
                }
                
            }
            
            
        }
    }
    
    func getCardsList() {
        //MARK: now using adyen payment
        /*
        let userId = UserDefaults.getLogInUserID()
        let _ = SpinnerView.showSpinnerViewInView(self.view)
        ElGrocerUtility.sharedInstance.delay(0) {
            ElGrocerApi.sharedInstance.getAllCreditCards { (result) in
                SpinnerView.hideSpinnerView()
                switch result {
                    case .success(let response):
                        if let responsedata = response["data"] as? NSDictionary {
                            let responsedataA = responsedata["credit_cards"] as! [ NSDictionary ]
                            self.creditCardA.removeAll()
                            
                            self.selectedCreditCard = nil
                            for creDicts in responsedataA {
                                self.creditCardA.append(CreditCard.init(cardDict: creDicts as! Dictionary<String, Any>))
                            }
                            DispatchQueue.main.async {
                                let cardID = UserDefaults.getCardID(userID: userId)
                                if cardID.count > 0 {
                                    let cardSelected =  self.creditCardA.filter { (card) -> Bool in
                                        return "\(card.cardID)" == cardID
                                    }
                                    if cardSelected.count > 0 {
                                        self.selectedCreditCard = cardSelected[0]
                                        //self.setViewAccordingToSelectedCreditCard(card: self.selectedCreditCard!)
                                        self.tableView.backgroundView = UIView()
                                        self.tableView.reloadData()
                                        return
                                    }
                                }
                                if self.creditCardA.count > 0 {
                                    self.selectedCreditCard = self.creditCardA[0]
                                    self.tableView.backgroundView = UIView()
                                    self.tableView.reloadData()
                                    //self.setViewAccordingToSelectedCreditCard(card: self.selectedCreditCard!)
                                }else{
                                   elDebugPrint("no card")
                                    self.tableView.reloadData()
                                    self.tableView.backgroundView = self.NoCardView
                                }
                            }
                    }
                    case .failure( _): break
                    // error.showErrorAlert()
                }
            }
        }
        */
    }
    
    func makeDefaultCard(index : Int){
        guard let card = self.creditCardA[index] as? CreditCard else{
            return
        }
        
        guard let id = UserDefaults.getLogInUserID() as? String else{
            return
        }
        
        UserDefaults.setCardID(cardID: "\(card.cardID)", userID: id)
        self.selectedCreditCard = card
        self.tableView.reloadData()
    }
    
}

extension savedCarsVC : UITableViewDelegate , UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kSavedCarCellHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if saveType == .addNewCar{
            return dataHandler.carList.count
        }else{
            return creditCardA.count
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "savedCarCell") as! savedCarCell
        if saveType == .addNewCar{
            if dataHandler.carList.count > 0{
                
                cell.btnEdit.tag = indexPath.row
                cell.btnEdit.addTarget(self, action: #selector(editButtonHandler(sender:)), for: .touchUpInside)
                cell.btnDelete.tag = indexPath.row
                cell.btnDelete.addTarget(self, action: #selector(deleteButtonHandler(sender:)), for: .touchUpInside)
                
                if dataHandler.selectedCar?.dbId == dataHandler.carList[indexPath.row].dbId{
                    cell.ConfigureCarCell(data: dataHandler.carList[indexPath.row] , isDefault: true)
                }else{
                    cell.ConfigureCarCell(data: dataHandler.carList[indexPath.row] , isDefault: false)
                }
                
            }
        }else{
            if creditCardA.count > 0{
                cell.saveType = .addNewCard
                cell.setupInitialAppearence()
                cell.btnEdit.tag = indexPath.row
                cell.btnEdit.addTarget(self, action: #selector(editButtonHandler(sender:)), for: .touchUpInside)
                
                if selectedCreditCard?.cardID == self.creditCardA[indexPath.row].cardID{
                    cell.ConfigureCardCell(data: self.creditCardA[indexPath.row], isDefault: true)
                }else{
                    cell.ConfigureCardCell(data: self.creditCardA[indexPath.row], isDefault: false)
                }
            }
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if saveType == .addNewCar{
            if let cell = tableView.cellForRow(at: indexPath) as? savedCarCell{
                if dataHandler.carList.count > 0{
                    dataHandler.makeDefaultCar(car: dataHandler.carList[indexPath.row])
                    cell.configureSelected(true)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                }
            }
        }else{
           elDebugPrint("card selected")
            if let cell = tableView.cellForRow(at: indexPath) as? savedCarCell{
                if self.creditCardA.count > 0{
                    self.makeCardSelected(creditCardA[indexPath.row])
                    cell.configureSelected(true)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                }
            }

        }
    }
}
extension savedCarsVC : MyBasketCandCDataHandlerDelegate{
    func carDataLoaded() {
        SpinnerView.hideSpinnerView()
        
        if dataHandler.carList.count == 0 {
            
            self.tableView.backgroundView = NoDataView
            self.tableView.reloadData()
            return
        }
        
        if dataHandler.carList.count > 0 && dataHandler.selectedCar == nil{
            dataHandler.selectedCar = dataHandler.carList[0]
        }
        self.tableView.backgroundView = UIView()
        self.tableView.reloadData()
    }
}
