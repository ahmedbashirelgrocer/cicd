//
//  itemsOutOfStockQuestionare.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 28/07/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

class ItemsOutOfStockQuestionnaire: UITableViewCell {

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var lblIfItemsOutOfStock: UILabel!{
        didSet{
            lblIfItemsOutOfStock.text = NSLocalizedString("If_items_are_out_of_stock_unselected", comment: "")
            lblIfItemsOutOfStock.setH3SemiBoldDarkStyle()
        }
    }
    @IBOutlet var optionsTableView: UITableView!
    @IBOutlet var btnEdit: UIButton!{
        didSet{
            btnEdit.setTitle(NSLocalizedString("dashboard_location_edit_button", comment: ""), for: UIControl.State())
            btnEdit.setBody1BoldGreenStyle()
            btnEdit.setImage(UIImage(name: "arrowDown"), for: UIControl.State())
            btnEdit.semanticContentAttribute = .forceLeftToRight
            
        }
    }
    
    var questionsArray: [Reasons]  = []
    
    
    var editPressed: ((_ isEditPressed : Bool , _ index : Int , _ selectPreferenceKey : Int)->Void)?
    // var parentVC : MyBasketViewController!
    var isExpanded: Bool = false
    var selectedCellIndex : Int = -1
    var cancelationType : cancelationType = .cancelOrder
    
    override func awakeFromNib() {

        super.awakeFromNib()
        self.setDelegates()
        setAppearance()
    }
    
    private func registerCells() {
        
        let questionareCell = UINib(nibName: "QuestionareCell", bundle: Bundle(for: QuestionareCell.self))
        self.optionsTableView.register(questionareCell, forCellReuseIdentifier: "QuestionareCell")
    }
    
    func setAppearance() {
        
        btnEdit.semanticContentAttribute = .forceRightToLeft
        self.optionsTableView.separatorStyle = .none
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func btnEditPressed(_ sender: Any) {
        
        if let closure = editPressed{
            if isExpanded {
                self.isExpanded = false
                closure(true , self.selectedCellIndex, -1)
            }else{
                self.isExpanded = true
                closure(false , self.selectedCellIndex , -1)
            }
        }
    }
    
    private func setDelegates(){
        
        self.registerCells()
        self.optionsTableView.isScrollEnabled = false
        self.selectionStyle = .none
        optionsTableView.delegate = self
        optionsTableView.dataSource = self
     
    }
    
    func setQuestion(question : String){
        self.lblIfItemsOutOfStock.text = question
    }
    
    func configureWithAnimation() {
        
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        self.lblIfItemsOutOfStock.isHidden = true
        self.btnEdit.isHidden = true
        self.optionsTableView.isHidden = true
        
    }
    
    func configureCell( isSelected : Bool ,isExpanded : Bool, data : [Reasons] ,selectedIndex : Int , isEditHidden : Bool = false){
        
        
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()
        self.lblIfItemsOutOfStock.isHidden = false
        self.btnEdit.isHidden = false
        self.optionsTableView.isHidden = false
        
        self.isExpanded = isExpanded
        if selectedIndex != -1{
            self.selectedCellIndex = selectedIndex
        }
        
        if isEditHidden{
            self.btnEdit.visibility = .goneX
        }else{
            self.btnEdit.visibility = .visible
        }
        
        if data.count > 0{
            self.questionsArray = data
        }
        
        if isSelected{
            lblIfItemsOutOfStock.text = NSLocalizedString("If_items_are_out_of_stock_selected", comment: "")
            self.btnEdit.isHidden = false
        }else{
            lblIfItemsOutOfStock.text = NSLocalizedString("If_items_are_out_of_stock_unselected", comment: "")
            self.btnEdit.isHidden = true
        }
        self.optionsTableView.isUserInteractionEnabled = isExpanded
        if isExpanded{
            btnEdit.setImage(UIImage(name: "arrowUp"), for: UIControl.State())
        }else{
            btnEdit.setImage(UIImage(name: "arrowDown"), for: UIControl.State())
        }
        
        self.optionsTableView.reloadData()
    }

}
extension ItemsOutOfStockQuestionnaire : UITableViewDelegate , UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isExpanded {
            return questionsArray.count
        }else{
            return questionsArray.count > 0 ? 1 : 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionareCell") as! QuestionareCell
        
        //cell.lblOption.text = questionsArray[indexPath.row]
        if self.selectedCellIndex != -1{
            if isExpanded {
                if selectedCellIndex == indexPath.row{
                    cell.ConfigureCell(isSelected: true, text: questionsArray[selectedCellIndex].reasonString)
                }else{
                    cell.ConfigureCell(isSelected: false, text: questionsArray[indexPath.row].reasonString)
                }
            }else{
                if indexPath.row == 0 {
                    cell.ConfigureCell(isSelected: true, text: questionsArray[selectedCellIndex].reasonString)
                }else{
                    cell.ConfigureCell(isSelected: false, text: questionsArray[indexPath.row].reasonString)
                }
                
            }
            
            
        }else{
            cell.ConfigureCell(isSelected: false, text: questionsArray[indexPath.row].reasonString)
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.selectedCellIndex != -1{
            let cell = tableView.cellForRow(at: IndexPath(row: selectedCellIndex, section: 0)) as! QuestionareCell
            cell.ConfigureCell(isSelected: false, text: questionsArray[selectedCellIndex].reasonString)
        }
        
        
        let cell = tableView.cellForRow(at: indexPath) as! QuestionareCell
        
        let reason = questionsArray[indexPath.row]

        cell.ConfigureCell(isSelected: true, text: reason.reasonString)
        self.selectedCellIndex = indexPath.row
        
        if let closure = editPressed {
            if isExpanded{
                self.isExpanded = false
                closure(true , self.selectedCellIndex, reason.reasonKey.intValue)
            }else{
                self.isExpanded = true
                closure(false , self.selectedCellIndex, reason.reasonKey.intValue)
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
        //return QuestionareCellHeight
    }
    
    
    
}
