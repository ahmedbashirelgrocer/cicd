//
//  AccountDeletionReasonsVC.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 24/06/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit

class AccountDeletionReasonsVC: UIViewController, NavigationBarProtocol {
    func backButtonClickedHandler() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBOutlet var tblView: UITableView!
    
    var questionsArray = [Reasons]()
    var numberOfOutOfStockOptions : CGFloat = 4
    var selectedOptionIndex : Int = -1
    var improvementText : String = ""
    let extraFeedBackString: String = "ExtraFeedBack:"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerTableViewAndCells()
        setInitialAppearence()
        fetchReason()
        // Do any additional setup after loading the view.
    }
    //MARK: Appearence
    func setInitialAppearence(){
        
        self.view.backgroundColor = .navigationBarWhiteColor()
        
        if self.navigationController is ElGrocerNavigationController{
            (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.hideSeparationLine()
            (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
            (self.navigationController as? ElGrocerNavigationController)?.navigationBar.topItem?.title = localizedString("delete_account", comment: "")
            self.title = localizedString("delete_account", comment: "")
            self.addBackButton(isGreen: false)
        }
        
        
    }
    func registerTableViewAndCells(){
        self.tblView.delegate = self
        self.tblView.dataSource = self
        self.tblView.separatorStyle = .none
        self.tblView.estimatedRowHeight = UITableView.automaticDimension
        self.tblView.rowHeight = 44.0;
        
        
        let instructionCell = UINib(nibName: "instructionsTableCell", bundle: .resource)
        self.tblView.register(instructionCell, forCellReuseIdentifier: "instructionsTableCell")
        
        let warningAlertCell = UINib(nibName: "warningAlertCell", bundle: .resource)
        self.tblView.register(warningAlertCell, forCellReuseIdentifier: "warningAlertCell")
        let titleTableViewCell = UINib(nibName: "TitleTableViewCell", bundle: .resource)
        self.tblView.register(titleTableViewCell, forCellReuseIdentifier: "TitleTableViewCell")
        
        let questionareCell = UINib(nibName: "QuestionareCell", bundle: .resource)
        self.tblView.register(questionareCell, forCellReuseIdentifier: "QuestionareCell")
        let subsitutionActionButtonTableViewCell = UINib(nibName: "SubsitutionActionButtonTableViewCell", bundle: .resource)
        self.tblView.register(subsitutionActionButtonTableViewCell, forCellReuseIdentifier: "SubsitutionActionButtonTableViewCell")
    
    }
    override func backButtonClick() {
        self.backButtonClickedHandler()
    }
    
    func fetchReason(){
        AccountDeletionManager.deleteAccountReasons { (response) in
            if response != ["":""]{
               elDebugPrint(response)
                self.saveReasonsAndReloadData(response: response)
            }
        }
    }
    func saveReasonsAndReloadData(response : NSDictionary) {
       elDebugPrint("save response called reasons = \(response)")
        
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
    func navigateToEnterPhoneNum(reason: String) {
        let reasonString: String
        let vc = ElGrocerViewControllers.getDeleteAccountAddNumberVC()
        if self.improvementText != "" {
            reasonString = reason + extraFeedBackString + improvementText
        }else {
            reasonString = reason
        }
        self.navigationController?.pushViewController(vc, animated: true)
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
extension AccountDeletionReasonsVC : UITableViewDelegate , UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return questionsArray.count + 2
        }else{
            return 2
        }
       
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0{
            if indexPath.row == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "warningAlertCell", for: indexPath) as! warningAlertCell
                let text = localizedString("lbl_warning_acount_deletion", comment: "")
                cell.ConfigureCell(text: text, highlightedText: "")
                return cell
            }else if indexPath.row == 1{
                let cell = tableView.dequeueReusableCell(withIdentifier: "TitleTableViewCell") as! TitleTableViewCell
                cell.lblTitle.setH4SemiBoldStyle()
                cell.configureTitle(title: localizedString("question_delete_account", comment: ""))
                    
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionareCell") as! QuestionareCell
            if questionsArray.count > 0{
                if selectedOptionIndex > -1{
                    if selectedOptionIndex == indexPath.row - 2{
                        cell.ConfigureCell(isSelected: true, text: questionsArray[indexPath.row - 2].reasonString)
                    }else{
                        cell.ConfigureCell(isSelected: false, text: questionsArray[indexPath.row - 2].reasonString)
                    }
                }else{
                    cell.ConfigureCell(isSelected: false, text: questionsArray[indexPath.row - 2].reasonString)
                }
            }
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            
            return cell
        }else{
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "instructionsTableCell", for: indexPath) as! instructionsTableCell
                cell.superBGView.backgroundColor = .tableViewBackgroundColor()
                cell.setData(tableView: tableView, placeHolder: localizedString("delete_account_placeholder_instructions", comment: ""))
                self.improvementText = cell.txtNoteView.text ?? ""
                return cell
            }else{
                let cell : SubsitutionActionButtonTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SubsitutionActionButtonTableViewCell" , for: indexPath) as! SubsitutionActionButtonTableViewCell
                cell.configure(true)
                cell.configureTitle(title: localizedString("confirm_deletion", comment: ""))
                cell.buttonclicked = { [weak self] (isCancel) in
                    if isCancel{
                        if let self = self {
                            if self.selectedOptionIndex != -1 {
                                self.navigateToEnterPhoneNum(reason: self.questionsArray[self.selectedOptionIndex].reasonString)
                            }else {
                                self.navigateToEnterPhoneNum(reason: "")
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
                self.selectedOptionIndex = indexPath.row - 2
                self.tblView.reloadSections(IndexSet(integer: 0), with: .automatic)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
            return UITableView.automaticDimension

    }
    
}
