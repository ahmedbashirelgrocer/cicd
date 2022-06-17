//
//  OrderCancelationVC.swift
//  ElGrocerShopper
//
//  Created by saboor Khan on 09/08/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit


protocol OrderCancelationVCAction {
    func startCancellationProcess (_ orderID : String ,  reason : NSNumber , improvement : String , reasonString : String)
}
extension OrderCancelationVCAction {
    func startCancellationProcess (_ orderID : String , reason : NSNumber , improvement : String , reasonString : String){}
}


enum cancelationType{
    case cancelOrder
    case deleteAccount
}

class OrderCancelationVC: UIViewController {
    
    @IBOutlet var tblView: UITableView!
    
    var cancelationType : cancelationType = .cancelOrder
    var questionsArray = [Reasons]()
    var numberOfOutOfStockOptions : CGFloat = 4
    var selectedOptionIndex : Int = -1
    var orderID : String = "-1"
    var improvementText : String = ""
    
    var isOrderCancelled : ((_ isCancelled : Bool)->Void)?
    var delegate : OrderCancelationVCAction?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        registerTableViewAndCells()
        setInitialAppearence()
        fetchReason()
        
    }
    func setInitialAppearence(){
        
        self.view.backgroundColor = .navigationBarWhiteColor()
        
        if self.navigationController is ElGrocerNavigationController{
            (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.hideSeparationLine()
            if cancelationType == .cancelOrder{
                (self.navigationController as? ElGrocerNavigationController)?.navigationBar.topItem?.title = localizedString("order_history_cancel_alert_title", comment: "")
            }else{
                (self.navigationController as? ElGrocerNavigationController)?.navigationBar.topItem?.title = localizedString("delete_account", comment: "")
            }
            self.addBackButton()
        }
        
        
    }
    
    func fetchReason(){
        OrderCancelationHandler.cancelOrderReasons { (response) in
            if response != ["":""]{
                print(response)
                self.saveReasonsAndReloadData(response: response)
            }
        }
    }
    
    func saveReasonsAndReloadData(response : NSDictionary) {
        print("save response called reasons = \(response)")
        
        if let data = response["data"] as? [NSDictionary]{
            for reason in data {
                let reasonKey = reason["key"] as? NSNumber ?? NSNumber(-1)
                let reasonString = reason["value"] as? String ?? ""
                
                let reason = Reasons(key: reasonKey, reason: reasonString)
                self.questionsArray.append(reason)
            }
            
            self.numberOfOutOfStockOptions = CGFloat(questionsArray.count)
            self.tblView.reloadDataOnMain()
        }
        
    }
    
    override func backButtonClick() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func registerTableViewAndCells(){
        self.tblView.delegate = self
        self.tblView.dataSource = self
        self.tblView.separatorStyle = .none
        self.tblView.estimatedRowHeight = UITableView.automaticDimension
        self.tblView.rowHeight = 44.0;
        
        
        let instructionCell = UINib(nibName: "instructionsTableCell", bundle: Bundle.resource)
        self.tblView.register(instructionCell, forCellReuseIdentifier: "instructionsTableCell")
        
        
        let titleTableViewCell = UINib(nibName: "TitleTableViewCell", bundle: Bundle.resource)
        self.tblView.register(titleTableViewCell, forCellReuseIdentifier: "TitleTableViewCell")
        
        let questionareCell = UINib(nibName: "QuestionareCell", bundle: Bundle.resource)
        self.tblView.register(questionareCell, forCellReuseIdentifier: "QuestionareCell")
        let subsitutionActionButtonTableViewCell = UINib(nibName: "SubsitutionActionButtonTableViewCell", bundle: Bundle.resource)
        self.tblView.register(subsitutionActionButtonTableViewCell, forCellReuseIdentifier: "SubsitutionActionButtonTableViewCell")
    
    }
    
    func cancelButtonPressed(indexPath : IndexPath , tableView : UITableView) {
        
        let insCell = tableView.cellForRow(at: IndexPath(row: indexPath.row - 1, section: indexPath.section)) as? instructionsTableCell
        
        if self.selectedOptionIndex > -1 {
            
            if self.questionsArray[self.selectedOptionIndex].reasonString.lowercased() == localizedString("cell_Title_Other", comment: "").lowercased() {
                
                if insCell?.txtNoteView.text.count ?? 0 == 0 {
                    insCell?.txtNoteView.becomeFirstResponder()
                    ElGrocerUtility.sharedInstance.showTopMessageView(localizedString("write_reason_alert", comment: "") , image: UIImage(name: "CancelOrderSnakeBar"), -1 , false) { (t1, t2, t3) in }
                }else{
                    self.delegate?.startCancellationProcess(self.orderID , reason: self.questionsArray[self.selectedOptionIndex].reasonKey , improvement: insCell?.txtNoteView.text ?? "" , reasonString : self.questionsArray[self.selectedOptionIndex].reasonString)
                }
                
            }else{
                self.delegate?.startCancellationProcess(self.orderID , reason: self.questionsArray[self.selectedOptionIndex].reasonKey , improvement: insCell?.txtNoteView.text ?? "", reasonString: self.questionsArray[self.selectedOptionIndex].reasonString)
            }
            
        }else{
            ElGrocerUtility.sharedInstance.showTopMessageView(localizedString("select_one_option", comment: "") , image: UIImage(name: "CancelOrderSnakeBar"), -1 , false) { (t1, t2, t3) in }
        }
    }
   
}
extension OrderCancelationVC : UITableViewDelegate , UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return questionsArray.count + 1
        }else{
            return 2
        }
       
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0{
            if indexPath.row == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "TitleTableViewCell") as! TitleTableViewCell
                    if cancelationType == .cancelOrder{
                        cell.configureTitle(title: localizedString("question_cancel_order", comment: ""))
                    }else{
                        cell.configureTitle(title: localizedString("question_delete_account", comment: ""))
                    }
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionareCell") as! QuestionareCell
            if questionsArray.count > 0{
                if selectedOptionIndex > -1{
                    if selectedOptionIndex == indexPath.row - 1{
                        cell.ConfigureCell(isSelected: true, text: questionsArray[indexPath.row - 1].reasonString)
                    }else{
                        cell.ConfigureCell(isSelected: false, text: questionsArray[indexPath.row - 1].reasonString)
                    }
                }else{
                    cell.ConfigureCell(isSelected: false, text: questionsArray[indexPath.row - 1].reasonString)
                }
            }
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            
            return cell
        }else{
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "instructionsTableCell", for: indexPath) as! instructionsTableCell
                if cancelationType == .cancelOrder{
                    cell.setData(tableView: tableView, placeHolder: localizedString("instruction_placeholder_order_cancelation", comment: ""))
                }else{
                    
                    cell.setData(tableView: tableView, placeHolder: localizedString("instruction_placeholder_delete_account", comment: ""))
                }
                return cell
            }else{
                let cell : SubsitutionActionButtonTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SubsitutionActionButtonTableViewCell" , for: indexPath) as! SubsitutionActionButtonTableViewCell
                cell.configure(true)
                if cancelationType == .cancelOrder{
                    cell.configureTitle(title: localizedString("Confirm_order_cancelation", comment: ""))
                }else{
                    cell.configureTitle(title: localizedString("confirm_deletion", comment: ""))
                }
                cell.buttonclicked = { [weak self] (isCancel) in
                    if isCancel{
                        if let self = self{
                            if self.orderID != "-1"{
                                self.cancelButtonPressed(indexPath: indexPath, tableView: tableView)
                            }
                            
                        }
                    }
                }
                return cell
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row > 0 {
                self.selectedOptionIndex = indexPath.row - 1
                self.tblView.reloadSections(IndexSet(integer: 0), with: .automatic)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
            return UITableView.automaticDimension

    }
    
}
